import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // A Base URL agora vem direto das variáveis de ambiente de forma centralizada
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? 'FALLBACK_URL_SEGURA',
      headers: {'User-Agent': 'Flutter-App/1.0', 'Accept': 'application/json'},
    ),
  );

  final _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          final expiryStr = await _storage.read(key: 'token_expiry');

          if (token != null && expiryStr != null) {
            final expiry = DateTime.parse(expiryStr);
            final stringTimeWithBuffer = expiry.subtract(const Duration(seconds: 15));

            if (DateTime.now().isAfter(stringTimeWithBuffer)) {
              final refreshed = await _refreshToken();

              if (refreshed) {
                final newToken = await _storage.read(key: 'access_token');
                options.headers['Authorization'] = 'Bearer $newToken';
              } else {
                _forceLogout();
                return handler.reject(
                  DioException(requestOptions: options, error: "Sessão expirada. Não foi possível renovar o token."),
                );
              }
            } else {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } else if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
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
    // Uso de path relativo
    const String path = "/apiListadella_desafio/LoginUsuario";

    final Map<String, dynamic> corpoJson = {
      "sdtUsuarios": {"UsuarioEmail": email, "UsuarioSenha": senha},
    };

    try {
      final response = await _dio.post(
        path,
        data: corpoJson,
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200) {
        final List<dynamic> messages = response.data['Messages'] ?? [];
        final String usuarioNome = response.data['UsuarioNome'];
        final String usuarioId = response.data['UsuarioId'].toString();

        bool logadoComSucesso = messages.any((msg) => msg['Id'] == 'Sucesso');

        if (logadoComSucesso) {
          await _storage.write(key: "UsuarioNome", value: usuarioNome);
          await _storage.write(key: "UsuarioId", value: usuarioId);

          // SALVANDO CREDENCIAIS NO COFRE para o refreshToken conseguir usar depois
          await _storage.write(key: "user_email", value: email);
          await _storage.write(key: "user_password", value: senha);

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
    const String path = "/apiListadella_desafio/InsertUsuario";

    final Map<String, dynamic> corpoJson = {
      "sdtUsuarios": {"UsuarioNome": nome, "UsuarioEmail": email, "UsuarioSenha": senha},
    };

    try {
      final response = await _dio.post(
        path,
        data: corpoJson,
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200) {
        final List<dynamic> messages = response.data['Messages'] ?? [];
        final String usuarioNome = response.data['UsuarioNome'];

        bool logadoComSucesso = messages.any((msg) => msg['Id'] == 'Sucesso');

        if (logadoComSucesso) {
          await _storage.write(key: "UsuarioNome", value: usuarioNome);

          // SALVANDO CREDENCIAIS NO COFRE caso o cadastro já logue o usuário automaticamente
          await _storage.write(key: "user_email", value: email);
          await _storage.write(key: "user_password", value: senha);

          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          String mensagemErro = "Não foi possível realizar o registro. Verifique os dados.";

          for (var msg in messages) {
            if (msg['Id'] == 'Erro' && msg['Description'] != null) {
              mensagemErro = msg['Description'];
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
    const String path = "/apiListadella_desafio/Listasusuario";

    try {
      final String? usuarioId = await _storage.read(key: "UsuarioId");

      if (usuarioId == null || usuarioId.isEmpty) {
        onError("Usuário não identificado. Identificação local expirou.");
        return null;
      }

      final response = await _dio.get(path, queryParameters: {"UsuarioId": usuarioId});

      if (response.statusCode == 200) {
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
    const String path = "/apiListadella_desafio/NovaLista";

    final int? idUsuarioInt = int.tryParse(usuarioId);

    if (idUsuarioInt == null) {
      onError("Identificador do usuário inválido.");
      return false;
    }

    final Map<String, dynamic> corpoJson = {
      "sdtNovaLista": {"UsuarioId": idUsuarioInt, "ListaNome": listaNome},
    };

    try {
      final response = await _dio.post(
        path,
        data: corpoJson,
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200) {
        final List<dynamic> messages = response.data['Messages'] ?? [];
        bool cadastradoComSucesso = messages.any((msg) => msg['Id'] == 'Sucesso');

        if (cadastradoComSucesso) {
          return true;
        } else {
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
    required String token, // Se não for mais usar nos headers locais, pode remover
    required int listaId,
    required String nomeProduto,
    required int novoEstadoCheck,
  }) async {
    const String path = '/apiListadella_desafio/AlterarEstadoProduto';

    final body = {
      "sdtReceberEstadoProdutoLista": {
        "UsuarioListaId": listaId,
        "UsuarioListaProdutosNome": nomeProduto,
        "UsuarioListaProdutoCheck": novoEstadoCheck,
      },
    };

    try {
      final response = await _dio.post(
        path,
        data: body,
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = response.data;
        if (jsonResponse['Messages'] != null && jsonResponse['Messages'][0]['Id'] == 'Sucesso') {
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Erro na requisição: $e');
      return false;
    }
  }

  Future<Map<String, List<String>>> listarProdutos() async {
    const String path = '/apiListadella_desafio/SelecionarCategoriaProdutos';
    final String? usuarioId = await _storage.read(key: "UsuarioId");

    try {
      final response = await _dio.get(path, queryParameters: {"UsuarioId": usuarioId});

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse.containsKey('ValorProdutoCategoria')) {
          final String categoriasString = jsonResponse['ValorProdutoCategoria'];
          final Map<String, dynamic> categoriasMapDecoded = jsonDecode(categoriasString);

          final Map<String, List<String>> resultadoFinal = {};
          categoriasMapDecoded.forEach((nomeCategoria, listaProdutos) {
            resultadoFinal[nomeCategoria] = List<String>.from(listaProdutos);
          });

          return resultadoFinal;
        }

        return {};
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
    Function(String)? onError,
  }) async {
    const String path = '/apiListadella_desafio/AdicionaProdutoLista';

    final body = jsonEncode({
      "sdtNovoProdutoLista": {
        "UsuarioListaId": listaId,
        "CategoriaProdutoId": categoriaId,
        "UsuarioListaProdutosNome": nomeProduto,
      },
    });

    try {
      final response = await _dio.post(
        path,
        data: body,
        options: Options(contentType: Headers.jsonContentType, responseType: ResponseType.plain),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.data);

        if (jsonResponse['Messages'] != null && jsonResponse['Messages'].isNotEmpty) {
          final String messageId = jsonResponse['Messages'][0]['Id'];
          final String description = jsonResponse['Messages'][0]['Description'];

          if (messageId == 'Sucesso') {
            return true;
          } else if (messageId == 'Error') {
            if (onError != null) {
              if (description.contains('já existe')) {
                onError('Produto já cadastrado');
              } else {
                onError(description);
              }
            }
            return false;
          }
        }
      }

      if (onError != null) onError('Falha ao adicionar o produto.');
      return false;
    } catch (e) {
      debugPrint('Erro na requisição adicionarProdutoLista: $e');
      if (onError != null) onError('Erro de conexão com o servidor.');
      return false;
    }
  }

  Future<bool> removerProdutoLista({required int listaId, required String nomeProduto}) async {
    const String path = '/apiListadella_desafio/RemoveProdutoLista';

    final body = {"UsuarioListaId": listaId, "UsuarioListaProdutosNome": nomeProduto};

    try {
      final response = await _dio.post(
        path,
        data: body,
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200 && response.data != null && response.data!.isNotEmpty) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.data!);
        if (jsonResponse['Messages'] != null && jsonResponse['Messages'].isNotEmpty) {
          final messageId = jsonResponse['Messages'][0]['Id'];
          if (messageId == 'Sucesso') {
            return true;
          }
        }
      }

      debugPrint('Falha ao remover. Status: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('Erro na requisição removerProdutoLista: $e');
      return false;
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final String? clientId = dotenv.env['CLIENT_ID'];
      final String? username = await _storage.read(key: 'user_email');
      final String? password = await _storage.read(key: 'user_password');

      if (username == null || password == null || clientId == null) {
        debugPrint('Credenciais ausentes no armazenamento seguro.');
        return false;
      }

      final Map<String, dynamic> dadosDoLogin = {
        'grant_type': 'password',
        'username': username,
        'password': password,
        'client_id': clientId,
        'scope': 'FullControl',
      };

      // Como o Dio principal já tem a BaseURL embutida, podemos reusá-lo
      // Caso a rota de auth seja em um servidor diferente, mantenha a instância separada.
      final response = await _dio.post(
        "/oauth/access_token",
        data: dadosDoLogin,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        final dynamic expiresInRaw = response.data['expires_in'] ?? 3600;
        final int expiresInSeconds = int.parse(expiresInRaw.toString());
        final DateTime calculatedExpiry = DateTime.now().add(Duration(seconds: expiresInSeconds));

        await _storage.write(key: 'access_token', value: newAccessToken);
        await _storage.write(key: 'token_expiry', value: calculatedExpiry.toIso8601String());

        return true;
      }
    } catch (e) {
      debugPrint('Falha ao tentar renovar o token: $e');
      return false;
    }
    return false;
  }

  void _forceLogout() {
    // Garante que TODOS os dados sensíveis sejam apagados no logout
    _storage.deleteAll();
    // Exemplo de navegação para a tela inicial
    // navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
