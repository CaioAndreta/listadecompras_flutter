import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/api_client.dart';
import 'package:flutter_application_1/models/list_compras.dart';
import 'package:flutter_application_1/models/produto.dart';
import 'package:flutter_application_1/novo_produto_modal.dart';

class ListaDetalhesScreen extends StatefulWidget {
  // Recebe o objeto completo da lista
  final ListaCompras lista;

  const ListaDetalhesScreen({super.key, required this.lista});

  @override
  State<ListaDetalhesScreen> createState() => _ListaDetalhesScreenState();
}

class _ListaDetalhesScreenState extends State<ListaDetalhesScreen> {
  late List<Produto> _produtos;
  bool _hasChange = false;

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
    // 1. O 'await' faz o código pausar aqui até o modal ser fechado.
    // O resultado captura o que foi passado dentro do Navigator.pop lá no modal.
    final dynamic resultado = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return NovoProdutoDialog(listaId: int.tryParse(widget.lista.listaId.toString()) ?? 0);
      },
    );

    // 2. Se o resultado não for nulo (ou seja, fechou no botão "Cadastrar" e não no "Cancelar")
    // e o widget ainda estiver na tela (mounted)
    if (resultado != null && resultado is Map && mounted) {
      // 3. Atualiza a tela instantaneamente com o novo dado
      setState(() {
        _produtos.add(
          Produto(
            nome: resultado['nome'],
            categoria: resultado['categoria'],
            // Como é um produto novo, ele entra como desmarcado.
            // Ajuste a propriedade abaixo para bater com o que existe no seu modelo Produto (ex: isChecked: false ou check: 2)
            check: 2,
          ),
        );
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
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarPopupNovoItem(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: categoriasAgrupadas.isEmpty
          ? const Center(
              child: Text('Nenhum produto nesta lista.', style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                      color: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        nomeCategoria.toUpperCase(),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                      ),
                    ),
                    ...itensDaCategoria.map((produto) {
                      return Dismissible(
                        key: ValueKey('${produto.nome}_${produto.categoria}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red.shade400,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
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

                        // Chamamos o novo componente passando o produto e o ID da lista
                        child: ProdutoListItem(
                          produto: produto,
                          // Converte o ID da lista para inteiro (ajuste se seu modelo já for int)
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
    // Cancela o timer se o widget for destruído (ex: usuário fez scroll rápido)
    _debounce?.cancel();
    super.dispose();
  }

  void _onCheckboxChanged(bool? newValue) {
    final bool marcarComoComprado = newValue ?? false;
    final int checkStatusDaAPI = marcarComoComprado ? 1 : 2;

    // 1. ATUALIZAÇÃO OTIMISTA: Muda a UI na hora
    setState(() {
      widget.produto.isChecked = marcarComoComprado;
    });

    // 2. DEBOUNCE: Cancela o timer anterior se houver novos cliques rápidos
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    // 3. Inicia um novo Timer de 500ms
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final sucesso = await apiClient.alterarEstadoProduto(
        token: 'SEU_TOKEN_SALVO',
        listaId: widget.listaId,
        nomeProduto: widget.produto.nome,
        novoEstadoCheck: checkStatusDaAPI,
      );

      // 4. ROLLBACK: Se a API falhar, desfaz a alteração visual
      if (!sucesso && mounted) {
        setState(() {
          widget.produto.isChecked = !marcarComoComprado;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao atualizar "${widget.produto.nome}".'),
            backgroundColor: Colors.red.shade600,
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
      activeColor: Colors.green,
      title: Text(
        widget.produto.nome,
        style: TextStyle(
          fontSize: 16,
          decoration: widget.produto.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
          color: widget.produto.isChecked ? Colors.grey : Colors.black87,
        ),
      ),
      value: widget.produto.isChecked,
      onChanged: _onCheckboxChanged,
    );
  }
}
