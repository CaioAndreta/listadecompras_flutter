import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/api_client.dart';
import 'package:flutter_application_1/models/list_compras.dart';
import 'package:flutter_application_1/models/produto.dart';
import 'package:flutter_application_1/novo_produto_modal.dart';
import 'package:flutter_application_1/theme/app_colors.dart';
import 'package:flutter_application_1/theme/app_constants.dart';
import 'package:flutter_application_1/theme/app_text_styles.dart';

class ListaDetalhesScreen extends StatefulWidget {
  // Recebe o objeto completo da lista
  final ListaCompras lista;

  const ListaDetalhesScreen({super.key, required this.lista});

  @override
  State<ListaDetalhesScreen> createState() => _ListaDetalhesScreenState();
}

class _ListaDetalhesScreenState extends State<ListaDetalhesScreen> {
  late List<Produto> _produtos;

  @override
  void initState() {
    super.initState();
    // Carrega os produtos vindos do objeto completo
    _produtos = List.from(widget.lista.produtos);
  }

  Map<String, List<Produto>> get _produtosAgrupados {
    final mapa = <String, List<Produto>>{};
    for (var produto in _produtos) {
      if (!mapa.containsKey(produto.categoria)) {
        mapa[produto.categoria] = [];
      }
      mapa[produto.categoria]!.add(produto);
    }
    return mapa;
  }

  void _mostrarPopupNovoItem(BuildContext context) async {
    final dynamic resultado = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return NovoProdutoDialog(listaId: int.tryParse(widget.lista.listaId.toString()) ?? 0);
      },
    );

    if (resultado != null && resultado is Map && mounted) {
      setState(() {
        _produtos.add(Produto(nome: resultado['nome'], categoria: resultado['categoria'], check: 2));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAgrupadas = _produtosAgrupados;
    final ApiClient apiClient = ApiClient();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lista.titulo),
        // Cores removidas: O AppTheme assume o controle via ColorScheme
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarPopupNovoItem(context),
        // Cores removidas: O floatingActionButtonTheme do AppTheme já aplica o Laranja Primário e Ícone Branco
        child: const Icon(Icons.add),
      ),
      body: categoriasAgrupadas.isEmpty
          ? Center(
              child: Text(
                'Nenhum produto nesta lista.',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.bodyMid),
              ),
            )
          : ListView.builder(
              itemCount: categoriasAgrupadas.keys.length,
              itemBuilder: (context, index) {
                String nomeCategoria = categoriasAgrupadas.keys.elementAt(index);
                List<Produto> itensDaCategoria = categoriasAgrupadas[nomeCategoria]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      color: AppColors.canvasSoft,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                      child: Text(
                        nomeCategoria.toUpperCase(),
                        style: AppTextStyles.eyebrowUppercase.copyWith(color: AppColors.body),
                      ),
                    ),
                    ...itensDaCategoria.map((produto) {
                      return Dismissible(
                        key: ValueKey('${produto.nome}_${produto.categoria}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: AppColors.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppSpacing.xl),
                          child: const Icon(Icons.delete_outline, color: AppColors.onError, size: 28),
                        ),
                        onDismissed: (direction) {
                          setState(() {
                            _produtos.remove(produto);
                          });

                          apiClient.removerProdutoLista(
                            listaId: int.parse(widget.lista.listaId),
                            nomeProduto: produto.nome,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${produto.nome} removido.'), duration: const Duration(seconds: 2)),
                          );
                        },
                        child: ProdutoListItem(
                          produto: produto,
                          listaId: int.tryParse(widget.lista.listaId.toString()) ?? 0,
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
    );
  }
}

class ProdutoListItem extends StatefulWidget {
  final Produto produto;
  final int listaId;

  const ProdutoListItem({super.key, required this.produto, required this.listaId});

  @override
  State<ProdutoListItem> createState() => _ProdutoListItemState();
}

class _ProdutoListItemState extends State<ProdutoListItem> {
  Timer? _debounce;
  final ApiClient apiClient = ApiClient();

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onCheckboxChanged(bool? newValue) {
    final bool marcarComoComprado = newValue ?? false;
    final int checkStatusDaAPI = marcarComoComprado ? 1 : 2;

    setState(() {
      widget.produto.isChecked = marcarComoComprado;
    });

    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final sucesso = await apiClient.alterarEstadoProduto(
        token: 'SEU_TOKEN_SALVO',
        listaId: widget.listaId,
        nomeProduto: widget.produto.nome,
        novoEstadoCheck: checkStatusDaAPI,
      );

      if (!sucesso && mounted) {
        setState(() {
          widget.produto.isChecked = !marcarComoComprado;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao atualizar "${widget.produto.nome}".'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      // ActiveColor removido. Ele puxará o AppColors.primary automaticamente pelo tema.
      title: Text(
        widget.produto.nome,
        style: AppTextStyles.bodyMd.copyWith(
          decoration: widget.produto.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
          color: widget.produto.isChecked ? AppColors.bodyMid : AppColors.ink,
        ),
      ),
      value: widget.produto.isChecked,
      onChanged: _onCheckboxChanged,
    );
  }
}
