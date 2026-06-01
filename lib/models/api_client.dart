import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://listadella.azurewebsites.net",
      headers: {'User-Agent': 'Flutter-App/1.0', 'Accept': 'application/json'},
    ),
  );
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1. Busca o token e a data de expiração salvos
          final token = await _storage.read(key: 'access_token');
          final expiryStr = await _storage.read(key: 'token_expiry');

          if (token != null && expiryStr != null) {
            final expiry = DateTime.parse(expiryStr);

            // Adicionamos uma margem de segurança de 15 segundos para evitar que o token
            // expire no meio do caminho entre o app e o servidor
            final stringTimeWithBuffer = expiry.subtract(const Duration(seconds: 15));

            if (DateTime.now().isAfter(stringTimeWithBuffer)) {
              // O token expirou ou está prestes a expirar! Renova proativamente.
              final refreshed = await _refreshToken();

              if (refreshed) {
                final newToken = await _storage.read(key: 'access_token');
                options.headers['Authorization'] = 'Bearer $newToken';
              } else {
                // Se falhar na renovação proativa, força o logout e rejeita a requisição
                _forceLogout();
                return handler.reject(
                  DioException(requestOptions: options, error: "Sessão expirada. Não foi possível renovar o token."),
                );
              }
            } else {
              // Token ainda é válido, segue o fluxo normal
              options.headers['Authorization'] = 'Bearer $token';
            }
          } else if (token != null) {
            // Caso tenha o token mas não a data (ex: vindo de uma versão antiga do app)
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // 2. Se por acaso ainda der erro 401 (ex: token revogado no servidor antes do tempo)
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            final refreshed = await _refreshToken();

            if (refreshed) {
              final token = await _storage.read(key: 'access_token');
              e.requestOptions.headers['Authorization'] = 'Bearer $token';

              final cloneReq = await _dio.request(
                e.requestOptions.path,
                options: Options(method: e.requestOptions.method, headers: e.requestOptions.headers),
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
              );
              return handler.resolve(cloneReq);
            } else {
              _forceLogout();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<void> login({
    required String email,
    required String senha,
    required BuildContext context,
    required Function(String) onError,
  }) async {
    final String url = "https://listadella.azurewebsites.net/apiListadella_desafio/LoginUsuario";

    final Map<String, dynamic> corpoJson = {
      "sdtUsuarios": {"UsuarioEmail": email, "UsuarioSenha": senha},
    };

    try {
      final response = await _dio.post(
        url,
        data: corpoJson,
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200) {
        final List<dynamic> messages = response.data['Messages'] ?? [];
        final String usuarioNome = response.data['UsuarioNome'];

        bool logadoComSucesso = messages.any((msg) => msg['Id'] == 'Sucesso');

        if (logadoComSucesso) {
          await _storage.write(key: "UsuarioNome", value: usuarioNome);

          // Dica: Se o seu endpoint de login também retornasse o token original aqui,
          // você deveria salvar o 'access_token' e o 'token_expiry' aqui igual faz no refresh.

          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          onError("Não foi possível realizar o login. Verifique os dados.");
        }
      }
    } on DioException catch (e) {
      String mensagem = e.message ?? "Ocorreu um erro inesperado. Tente novamente.";
      if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
        mensagem = "Usuário ou senha inválidos.";
      } else if (e.type == DioExceptionType.connectionTimeout) {
        mensagem = "Conexão expirada. Verifique sua internet.";
      }
      onError(mensagem);
    } catch (e) {
      onError("Erro inesperado: $e");
    }
  }

  Future<void> signUp({
    required String nome,
    required String email,
    required String senha,
    required BuildContext context,
    required Function(String) onError,
  }) async {
    final String url = "https://listadella.azurewebsites.net/apiListadella_desafio/InsertUsuario";

    final Map<String, dynamic> corpoJson = {
      "sdtUsuarios": {"UsuarioNome": nome, "UsuarioEmail": email, "UsuarioSenha": senha},
    };

    try {
      final response = await _dio.post(
        url,
        data: corpoJson,
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200) {
        final List<dynamic> messages = response.data['Messages'] ?? [];
        final String usuarioNome = response.data['UsuarioNome'];

        bool logadoComSucesso = messages.any((msg) => msg['Id'] == 'Sucesso');

        if (logadoComSucesso) {
          await _storage.write(key: "UsuarioNome", value: usuarioNome);

          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          String mensagemErro = "Não foi possível realizar o registro. Verifique os dados.";

          for (var msg in messages) {
            if (msg['Id'] == 'Erro' && msg['Description'] != null) {
              mensagemErro = msg['Description']; // Captura o "Email já cadastrado!"
              break;
            }
          }

          onError(mensagemErro);
        }
      }
    } on DioException catch (e) {
      String mensagem = e.message ?? "Ocorreu um erro inesperado. Tente novamente.";
      if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
        mensagem = "Usuário ou senha inválidos.";
      } else if (e.type == DioExceptionType.connectionTimeout) {
        mensagem = "Conexão expirada. Verifique sua internet.";
      }
      onError(mensagem);
    } catch (e) {
      onError("Erro inesperado: $e");
    }
  }

  Future<List<dynamic>?> buscarListasUsuario({required BuildContext context, required Function(String) onError}) async {
    final String url = "https://listadella.azurewebsites.net/apiListadella_desafio/Listasusuario";

    try {
      // 1. Resgata o UsuarioId armazenado no FlutterSecureStorage
      // final String? usuarioId = await _storage.read(key: "UsuarioId");
      final String usuarioId = "56";

      // Validação caso o ID não exista localmente (ex: deslogado ou limpo)
      if (usuarioId == null || usuarioId.isEmpty) {
        onError("Usuário não identificado. Identificação local expirou.");
        return null;
      }

      // 2. Realiza a requisição GET passando o UsuarioId como query parameter
      final response = await _dio.get(
        url,
        queryParameters: {
          "UsuarioId": 56, // O Dio injeta automaticamente como ?UsuarioId=valor
        },
      );

      if (response.statusCode == 200) {
        // Retorne DIRETAMENTE a lista interna do JSON aqui
        return response.data['sdtListasUsuario'] as List<dynamic>;
      } else {
        onError("Não foi possível carregar as listas. Erro no servidor.");
        return null;
      }
    } on DioException catch (e) {
      String mensagem = e.message ?? "Ocorreu um erro inesperado. Tente novamente.";

      if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
        mensagem = "Dados não encontrados ou requisição inválida.";
      } else if (e.type == DioExceptionType.connectionTimeout) {
        mensagem = "Conexão expirada. Verifique sua internet.";
      }

      onError(mensagem);
      return null;
    } catch (e) {
      onError("Erro inesperado: $e");
      return null;
    }
  }

  Future<bool> criarLista({
    required String usuarioId,
    required String listaNome,
    required Function(String) onError,
  }) async {
    final String url = "https://listadella.azurewebsites.net/apiListadella_desafio/NovaLista";

    // Converte o ID de String (vindo do SecureStorage) para int,
    // já que a API espera um valor numérico conforme o Postman
    final int? idUsuarioInt = int.tryParse(usuarioId);

    if (idUsuarioInt == null) {
      onError("Identificador do usuário inválido.");
      return false;
    }

    // Monta o corpo seguindo a estrutura exata do seu print
    final Map<String, dynamic> corpoJson = {
      "sdtNovaLista": {"UsuarioId": idUsuarioInt, "ListaNome": listaNome},
    };

    try {
      final response = await _dio.post(
        url,
        data: corpoJson,
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200) {
        final List<dynamic> messages = response.data['Messages'] ?? [];

        // Valida se dentro da lista de mensagens existe o Id "Sucesso"
        bool cadastradoComSucesso = messages.any((msg) => msg['Id'] == 'Sucesso');

        if (cadastradoComSucesso) {
          return true; // Retorna true para a tela saber que deu certo e atualizar a listagem
        } else {
          // Caso a API retorne 200 mas com alguma mensagem de erro interna
          final String erroApi = messages.isNotEmpty
              ? messages.first['Description']
              : "Não foi possível criar a lista.";
          onError(erroApi);
          return false;
        }
      }

      return false;
    } on DioException catch (e) {
      String mensagem = e.message ?? "Ocorreu um erro inesperado. Tente novamente.";

      if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
        mensagem = "Erro nos dados enviados. Não foi possível cadastrar a lista.";
      } else if (e.type == DioExceptionType.connectionTimeout) {
        mensagem = "Conexão expirada. Verifique sua internet.";
      }

      onError(mensagem);
      return false;
    } catch (e) {
      onError("Erro inesperado: $e");
      return false;
    }
  }

  Future<bool> alterarEstadoProduto({
    required String token, // O Token JWT obtido no Login
    required int listaId,
    required String nomeProduto,
    required int novoEstadoCheck, // 1 (comprado) ou 2 (não comprado)
  }) async {
    final url = 'https://listadella.azurewebsites.net/apiListadella_desafio/AlterarEstadoProduto';

    // Estrutura exata exigida pelo seu print do Postman
    final body = {
      "sdtReceberEstadoProdutoLista": {
        "UsuarioListaId": listaId,
        "UsuarioListaProdutosNome": nomeProduto,
        "UsuarioListaProdutoCheck": novoEstadoCheck,
      },
    };

    try {
      final response = await _dio.post(
        url,
        data: body,
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = response.data;

        // Valida se a mensagem retornada foi "Sucesso" (conforme sua imagem)
        if (jsonResponse['Messages'] != null && jsonResponse['Messages'][0]['Id'] == 'Sucesso') {
          return true;
        }
      }
      return false; // Retorna falso se o status code não for sucesso ou a mensagem for diferente
    } catch (e) {
      debugPrint('Erro na requisição: $e');
      return false;
    }
  }

  Future<Map<String, List<String>>> listarProdutos() async {
    final url = 'https://listadella.azurewebsites.net/apiListadella_desafio/SelecionarCategoriaProdutos';

    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          "UsuarioId": 56, // O Dio injeta automaticamente como ?UsuarioId=valor
        },
      );

      if (response.statusCode == 200) {
        // 1. Decodifica o JSON raiz da resposta
        final Map<String, dynamic> jsonResponse = response.data;

        // 2. Verifica se a chave existe para evitar erros
        if (jsonResponse.containsKey('ValorProdutoCategoria')) {
          // Extrai a string que contém o JSON "escapado"
          final String categoriasString = jsonResponse['ValorProdutoCategoria'];

          // 3. Faz um NOVO decode apenas dessa string para transformá-la em um Map
          final Map<String, dynamic> categoriasMapDecoded = jsonDecode(categoriasString);
          // 4. Converte para um tipo forte (Map<String, List<String>>)
          // para facilitar o uso nos seus Dropdowns (Selects)
          final Map<String, List<String>> resultadoFinal = {};

          categoriasMapDecoded.forEach((nomeCategoria, listaProdutos) {
            // O List.from garante que o Flutter entenda os itens como Strings
            resultadoFinal[nomeCategoria] = List<String>.from(listaProdutos);
          });

          return resultadoFinal;
        }

        return {}; // Retorna vazio se não vier a chave esperada
      } else {
        debugPrint('Falha ao buscar produtos. Status: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      debugPrint('Erro na requisição listarProdutos: $e');
      return {};
    }
  }

  Future<bool> adicionarProdutoLista({
    required int listaId,
    required int categoriaId,
    required String nomeProduto,
  }) async {
    final url = 'https://listadella.azurewebsites.net/apiListadella_desafio/AdicionaProdutoLista';
    final body = jsonEncode({
      "sdtNovoProdutoLista": {
        "UsuarioListaId": listaId,
        "CategoriaProdutoId": categoriaId,
        "UsuarioListaProdutosNome": nomeProduto,
      },
    });

    try {
      final response = await _dio.post(
        url,
        data: body,
        options: Options(contentType: Headers.jsonContentType, responseType: ResponseType.plain),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.data);

        // Valida se a mensagem retornada foi "Sucesso" (conforme sua imagem)
        //TODO: Tratar erro de produto já cadastrado
        if (jsonResponse['Messages'] != null &&
            jsonResponse['Messages'][0]['Id'] == 'Sucesso' &&
            jsonResponse['Messages'][0]['Description'] == "Cadastro realizado com sucesso!") {
          return true;
        }
      }

      debugPrint('Falha ao adicionar. Status: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('Erro na requisição adicionarProdutoLista: $e');
      return false;
    }
  }

  Future<bool> _refreshToken() async {
    final Dio dioRefreshInstance = Dio(BaseOptions(baseUrl: "https://listadella.azurewebsites.net"));
    try {
      final String url = "https://listadella.azurewebsites.net/oauth/access_token";

      final Map<String, dynamic> dadosDoLogin = {
        'grant_type': 'password',
        'username': "caioandreta@gmail.com",
        'password': "password",
        'client_id': 'ts4l43A46xtUhLogTO8L92DmuWbbtQ7Ht81vVRbv',
        'scope': 'FullControl',
      };

      final response = await dioRefreshInstance.post(
        url,
        data: dadosDoLogin,
        options: Options(contentType: Headers.formUrlEncodedContentType, headers: {'User-Agent': 'Flutter-App/1.0'}),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];

        // 1. Captura o valor de expires_in (geralmente int em segundos, ex: 3600)
        // Usamos int.parse para garantir a conversão caso a API retorne como String
        final dynamic expiresInRaw = response.data['expires_in'] ?? 3600;
        final int expiresInSeconds = int.parse(expiresInRaw.toString());

        // 2. Calcula o momento exato em que o token vai expirar
        final DateTime calculatedExpiry = DateTime.now().add(Duration(seconds: expiresInSeconds));

        // 3. Salva ambos no armazenamento seguro do celular
        await _storage.write(key: 'access_token', value: newAccessToken);
        await _storage.write(key: 'token_expiry', value: calculatedExpiry.toIso8601String());

        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  void _forceLogout() {
    _storage.deleteAll();
    // Adicione aqui a navegação programática para a tela de login se necessário
  }
}
