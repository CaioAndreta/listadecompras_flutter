import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/api_client.dart';
import 'package:flutter_application_1/models/list_compras.dart';
import 'package:flutter_application_1/models/produto.dart';
import 'package:flutter_application_1/theme/app_colors.dart';
import 'package:flutter_application_1/theme/app_constants.dart';
import 'package:flutter_application_1/theme/app_text_styles.dart';
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
          _erroMensagem = messageIdToUserMessage(mensagem); // Tratamento amigável
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

  // Método auxiliar para traduzir mensagens brutas se necessário
  String messageIdToUserMessage(String message) {
    if (message.contains('Error')) return 'Falha ao carregar listas do servidor.';
    return message;
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
          // Cores manuais removidas: herdadas do floatingActionButtonTheme do seu AppTheme
          child: const Icon(Icons.add),
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
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _erroMensagem!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(onPressed: _carregarListas, child: const Text('Tentar Novamente')),
            ],
          ),
        ),
      );
    }

    // 3. Estado de Lista Vazia
    if (_listas.isEmpty) {
      return Center(
        child: Text('Nenhuma lista encontrada.', style: AppTextStyles.bodyMd.copyWith(color: AppColors.bodyMid)),
      );
    }

    // 4. Exibição dos dados com Cards contendo apenas o Título
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _listas.length,
      itemBuilder: (context, index) {
        final ListaCompras lista = ListaCompras.fromJson(_listas[index]);
        final String titulo = lista.titulo;
        final List<Produto> itens = lista.produtos;
        final String subtext = itens.isEmpty ? 'Nenhum produto cadastrado' : itens.map((item) => item.nome).join(', ');

        return InkWell(
          onTap: () async {
            await Navigator.pushNamed(context, '/detalhes', arguments: lista);
            if (mounted) {
              _carregarListas();
            }
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            // Opcional: Se quiser reforçar a cor de card do seu design system:
            color: AppColors.canvasSoft,
            elevation: 0, // Zapier DS foca em flats/bordas sutis em vez de sombras pesadas
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
            child: ListTile(
              title: Text(
                titulo,
                style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
              subtitle: Text(
                subtext,
                style: AppTextStyles.caption, // Já configurado para 14px e AppColors.bodyMid
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              leading: const Icon(Icons.list_alt, color: AppColors.primary),
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
      barrierDismissible: false,
      builder: (context) {
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
                  // Borda removida daqui: O inputDecorationTheme do seu AppTheme já cuida do OutlineInputBorder global
                ),
              ),
              actions: [
                TextButton(
                  onPressed: salvando ? null : () => Navigator.pop(dialogContext),
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

                          setDialogState(() => salvando = true);

                          final String? usuarioId = await _storage.read(key: "UsuarioId");

                          if (usuarioId != null) {
                            bool sucesso = await apiClient.criarLista(
                              usuarioId: usuarioId,
                              listaNome: nome,
                              onError: (mensagemErro) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(mensagemErro), backgroundColor: AppColors.error));
                              },
                            );

                            if (sucesso) {
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                                _carregarListas();
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(const SnackBar(content: Text('Erro ao recuperar usuário.')));
                          }

                          setDialogState(() => salvando = false);
                        },
                  child: salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary, // Contraste correto sobre o botão laranja
                          ),
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
