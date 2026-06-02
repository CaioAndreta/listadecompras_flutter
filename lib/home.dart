import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/api_client.dart';
import 'package:flutter_application_1/models/list_compras.dart';
import 'package:flutter_application_1/models/produto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiClient apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();
  List<dynamic> _listas = [];
  bool _isLoading = true;
  String? _erroMensagem;

  @override
  void initState() {
    super.initState();
    // Garante que o contexto está pronto antes de rodar a requisição
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarListas();
    });
  }

  Future<void> _carregarListas() async {
    setState(() {
      _isLoading = true;
      _erroMensagem = null;
    });

    final resultado = await apiClient.buscarListasUsuario(
      context: context,
      onError: (mensagem) {
        setState(() {
          _erroMensagem = mensagem;
          _isLoading = false;
        });
      },
    );

    if (resultado != null) {
      setState(() {
        _listas = resultado;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Minhas Listas'), centerTitle: true),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: _mostrarPopupNovaLista,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // 1. Estado de Carregamento
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Estado de Erro
    if (_erroMensagem != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _erroMensagem!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _carregarListas, child: const Text('Tentar Novamente')),
            ],
          ),
        ),
      );
    }

    // 3. Estado de Lista Vazia
    if (_listas.isEmpty) {
      return const Center(child: Text('Nenhuma lista encontrada.'));
    }

    // 4. Exibição dos dados com Cards contendo apenas o Título
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: _listas.length,
      itemBuilder: (context, index) {
        final ListaCompras lista = ListaCompras.fromJson(_listas[index]);
        final String titulo = lista.titulo;
        final List<Produto> itens = lista.produtos;
        final String subtext = itens.map((item) => item.nome).join(', ');

        return InkWell(
          onTap: () async {
            await Navigator.pushNamed(context, '/detalhes', arguments: lista);
            if (mounted) {
              _carregarListas();
            }
          },
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            child: ListTile(
              title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              subtitle: Text(subtext, style: const TextStyle(fontSize: 14)),
              leading: const Icon(Icons.list_alt, color: Colors.blue),
            ),
          ),
        );
      },
    );
  }

  void _mostrarPopupNovaLista() {
    final TextEditingController nomeListaController = TextEditingController();
    bool salvando = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Impede fechar clicando fora enquanto salva
      builder: (context) {
        // O StatefulBuilder serve para atualizarmos o estado do botão (carregando) apenas dentro do popup
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Nova Lista'),
              content: TextField(
                controller: nomeListaController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nome da Lista',
                  hintText: 'Ex: Compras do Mês',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: salvando ? null : () => {Navigator.pop(dialogContext)},
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: salvando
                      ? null
                      : () async {
                          final String nome = nomeListaController.text.trim();

                          if (nome.isEmpty) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(const SnackBar(content: Text('Por favor, digite um nome.')));
                            return;
                          }

                          // Ativa o loading no botão
                          setDialogState(() => salvando = true);

                          // 1. Busca o ID do usuário no storage
                          final String? usuarioId = await _storage.read(key: "UsuarioId");

                          if (usuarioId != null) {
                            // 2. Chama a função de criar lista criada no passo anterior
                            bool sucesso = await apiClient.criarLista(
                              usuarioId: usuarioId,
                              listaNome: nome,
                              onError: (mensagemErro) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(mensagemErro), backgroundColor: Colors.red));
                              },
                            );

                            if (sucesso) {
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext); // Fecha o popup
                                _carregarListas(); // Recarrega as listas para mostrar a nova
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(const SnackBar(content: Text('Erro ao recuperar usuário.')));
                          }

                          // Desativa o loading caso dê algum erro
                          setDialogState(() => salvando = false);
                        },
                  child: salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Criar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
