import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/api_client.dart';
import 'package:flutter_application_1/models/list_compras.dart';
import 'package:flutter_application_1/models/produto.dart';
import 'package:flutter_application_1/novo_produto_modal.dart';
import 'package:flutter_application_1/theme/theme.dart'; // Mantido centralizado

class ListaDetalhesScreen extends StatefulWidget {
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
      backgroundColor: AppColors.canvasSoft, // Fundo levemente acinzentado/creme para destacar os cards brancos
      appBar: AppBar(title: Text(widget.lista.titulo), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarPopupNovoItem(context),
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
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: categoriasAgrupadas.keys.length,
              itemBuilder: (context, index) {
                String nomeCategoria = categoriasAgrupadas.keys.elementAt(index);
                List<Produto> itensDaCategoria = categoriasAgrupadas[nomeCategoria]!;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Cabeçalho da Categoria (Centralizado com linhas laterais)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Row(
                          children: [
                            Expanded(child: Divider(color: AppColors.mute.withValues(alpha: 0.25), thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              child: Text(
                                nomeCategoria.toUpperCase(),
                                style: AppTextStyles.eyebrowUppercase.copyWith(
                                  color: AppColors.mute,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: AppColors.mute.withValues(alpha: 0.25), thickness: 1)),
                          ],
                        ),
                      ),

                      // 2. Bloco agrupado de itens
                      Card(
                        elevation: 0,
                        color: AppColors.canvas, // Branco quente do DS
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                        child: Column(
                          children: itensDaCategoria.asMap().entries.map((entry) {
                            final int idx = entry.key;
                            final Produto produto = entry.value;
                            final bool isLast = idx == itensDaCategoria.length - 1;

                            return Column(
                              children: [
                                Dismissible(
                                  key: ValueKey('${produto.nome}_${produto.categoria}'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: isLast && idx == 0
                                          ? AppRadius.mdAll
                                          : BorderRadius.zero, // Arredonda o fundo vermelho se for o único item
                                    ),
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
                                      SnackBar(
                                        content: Text('${produto.nome} removido.'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: ProdutoListItem(
                                    produto: produto,
                                    listaId: int.tryParse(widget.lista.listaId.toString()) ?? 0,
                                  ),
                                ),
                                // Adiciona um divisor sutil entre os itens, exceto no último
                                if (!isLast)
                                  const Divider(
                                    height: 1,
                                    color: AppColors.canvasSoft,
                                    indent: 56,
                                  ), // Indent alinha a linha com o texto
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
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
    // Substituímos o CheckboxListTile rígido por um InkWell + Row customizável
    return InkWell(
      onTap: () => _onCheckboxChanged(!widget.produto.isChecked),
      borderRadius: AppRadius.mdAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        child: Row(
          children: [
            // Checkbox circular customizado
            Checkbox(
              value: widget.produto.isChecked,
              onChanged: _onCheckboxChanged,
              shape: const CircleBorder(), // Transforma o quadrado em círculo
              activeColor: AppColors.primary,
              checkColor: AppColors.onPrimary,
              side: const BorderSide(color: AppColors.mute, width: 1.5), // Borda cinza quando vazio
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                widget.produto.nome,
                style: AppTextStyles.bodyMd.copyWith(
                  decoration: widget.produto.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                  color: widget.produto.isChecked ? AppColors.bodyMid : AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
