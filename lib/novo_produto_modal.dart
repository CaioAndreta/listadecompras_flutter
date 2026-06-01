import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/api_client.dart';

class NovoProdutoDialog extends StatefulWidget {
  final int listaId;

  const NovoProdutoDialog({super.key, required this.listaId});

  @override
  State<NovoProdutoDialog> createState() => _NovoProdutoDialogState();
}

class _NovoProdutoDialogState extends State<NovoProdutoDialog> {
  // Estados do Modal
  bool _isLoading = true;
  String _erro = '';
  Map<String, List<String>> _categoriasEProdutos = {};
  ApiClient apiClient = ApiClient();

  String? _categoriaSelecionada;
  String? _produtoSelecionado;

  @override
  void initState() {
    super.initState();
    // Dispara a requisição GET assim que o modal é construído
    _buscarCategoriasEProdutos();
  }

  Future<void> _buscarCategoriasEProdutos() async {
    try {
      final dados = await apiClient.listarProdutos();

      if (mounted) {
        setState(() {
          _categoriasEProdutos = dados;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = 'Falha ao carregar produtos. Tente novamente.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Novo Produto'),
      content: _buildContent(), // Separei o miolo do dialog para ficar limpo
      actions: [
        // BOTÃO CANCELAR
        TextButton(
          // Desabilita o botão se estiver carregando
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
        ),

        // BOTÃO CADASTRAR
        ElevatedButton(
          onPressed: (_isLoading || _categoriaSelecionada == null || _produtoSelecionado == null)
              ? null
              : () async {
                  // 1. Inicia o loading no modal para o usuário aguardar
                  setState(() {
                    _isLoading = true;
                  });

                  // 2. Descobre o ID numérico da Categoria selecionada
                  // Pega todas as chaves (nomes das categorias) em forma de lista
                  final listaCategorias = _categoriasEProdutos.keys.toList();
                  // Acha a posição da categoria selecionada e soma 1 (pois o index começa em 0)
                  final int categoriaId = listaCategorias.indexOf(_categoriaSelecionada!) + 1;

                  // 4. Faz a chamada POST
                  final sucesso = await apiClient.adicionarProdutoLista(
                    listaId: widget.listaId,
                    categoriaId: categoriaId,
                    nomeProduto: _produtoSelecionado!,
                  );


                  // 5. Trata o resultado
                  if (!mounted) return;

                  if (sucesso) {
                    Navigator.of(context).pop({
                      'nome': _produtoSelecionado!,
                      'categoria': _categoriaSelecionada!,
                    }); // Fecha o modal avisando que deu certo

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Produto adicionado com sucesso!'), backgroundColor: Colors.green),
                    );

                    // Dica: Na sua tela principal, você pode usar um .then() após o showDialog
                    // para recarregar a lista caso a inserção tenha dado certo!
                  } else {
                    setState(() {
                      _isLoading = false;
                      _erro = 'Falha ao cadastrar o produto.';
                    });
                  }
                },
          child: const Text('Cadastrar'),
        ),
      ],
    );
  }

  // Define o que aparece no meio do modal baseado no estado (Carregando, Erro ou Formulário)
  Widget _buildContent() {
    if (_isLoading) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Carregando categorias...')],
      );
    }

    if (_erro.isNotEmpty) {
      return Text(_erro, style: const TextStyle(color: Colors.red));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- DROPDOWN 1: CATEGORIA ---
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
          value: _categoriaSelecionada,
          hint: const Text('Selecione uma categoria'),
          isExpanded: true,
          items: _categoriasEProdutos.keys.map((String categoria) {
            return DropdownMenuItem<String>(value: categoria, child: Text(categoria));
          }).toList(),
          onChanged: (String? novaCategoria) {
            setState(() {
              _categoriaSelecionada = novaCategoria;
              _produtoSelecionado = null; // Reseta o produto ao mudar a categoria
            });
          },
        ),

        const SizedBox(height: 16),

        // --- DROPDOWN 2: PRODUTO ---
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Produto', border: OutlineInputBorder()),
          value: _produtoSelecionado,
          hint: const Text('Selecione um produto'),
          isExpanded: true,
          items: _categoriaSelecionada == null
              ? []
              : _categoriasEProdutos[_categoriaSelecionada]!.map((String produto) {
                  return DropdownMenuItem<String>(value: produto, child: Text(produto));
                }).toList(),
          onChanged: _categoriaSelecionada == null
              ? null
              : (String? novoProduto) {
                  setState(() {
                    _produtoSelecionado = novoProduto;
                  });
                },
        ),
      ],
    );
  }
}
