import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/api_client.dart';
import 'package:flutter_application_1/theme/app_colors.dart';
import 'package:flutter_application_1/theme/app_constants.dart';
import 'package:flutter_application_1/theme/app_text_styles.dart';

class NovoProdutoDialog extends StatefulWidget {
  final int listaId;

  const NovoProdutoDialog({super.key, required this.listaId});

  @override
  State<NovoProdutoDialog> createState() => _NovoProdutoDialogState();
}

class _NovoProdutoDialogState extends State<NovoProdutoDialog> {
  bool _isLoading = true; // Controla o carregamento inicial das categorias
  bool _isSaving = false; // Controla o carregamento do botão cadastrar
  String _erro = '';
  Map<String, List<String>> _categoriasEProdutos = {};
  ApiClient apiClient = ApiClient();

  String? _categoriaSelecionada;
  String? _produtoSelecionado;

  @override
  void initState() {
    super.initState();
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
    final bool podeCadastrar =
        !_isLoading && !_isSaving && _categoriaSelecionada != null && _produtoSelecionado != null;

    return AlertDialog(
      title: const Text('Adicionar Novo Produto'),
      content: _buildContent(),
      actions: [
        // BOTÃO CANCELAR
        TextButton(
          onPressed: (_isLoading || _isSaving) ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: AppColors.error), // Uso semântico do vermelho de erro
          child: const Text('Cancelar'),
        ),

        // BOTÃO CADASTRAR
        ElevatedButton(
          onPressed: !podeCadastrar
              ? null
              : () async {
                  setState(() {
                    _isSaving = true;
                    _erro = '';
                  });

                  final listaCategorias = _categoriasEProdutos.keys.toList();
                  final int categoriaId = listaCategorias.indexOf(_categoriaSelecionada!) + 1;

                  String? mensagemDeErroDaAPI;

                  final sucesso = await apiClient.adicionarProdutoLista(
                    listaId: widget.listaId,
                    categoriaId: categoriaId,
                    nomeProduto: _produtoSelecionado!,
                    onError: (mensagem) {
                      mensagemDeErroDaAPI = mensagem;
                    },
                  );

                  if (!mounted) return;

                  if (sucesso) {
                    Navigator.of(context).pop({'nome': _produtoSelecionado!, 'categoria': _categoriaSelecionada!});

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Produto adicionado com sucesso!'),
                        // Deixamos o background herdar o padrão neutro escuro do tema
                      ),
                    );
                  } else {
                    setState(() {
                      _isSaving = false;
                      _erro = mensagemDeErroDaAPI ?? 'Falha ao cadastrar o produto.';
                    });
                  }
                },
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimary, // Contraste perfeito sobre o laranja
                  ),
                )
              : const Text('Cadastrar'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.lg),
          Text('Carregando categorias...'),
        ],
      );
    }

    if (_erro.isNotEmpty) {
      return Text(_erro, style: AppTextStyles.caption.copyWith(color: AppColors.error));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- DROPDOWN 1: CATEGORIA ---
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Categoria'),
          value: _categoriaSelecionada,
          hint: const Text('Selecione uma categoria'),
          isExpanded: true,
          items: _categoriasEProdutos.keys.map((String categoria) {
            return DropdownMenuItem<String>(
              value: categoria,
              child: Text(categoria, style: AppTextStyles.bodyMd),
            );
          }).toList(),
          onChanged: _isSaving
              ? null // Bloqueia interação enquanto salva
              : (String? novaCategoria) {
                  setState(() {
                    _categoriaSelecionada = novaCategoria;
                    _produtoSelecionado = null;
                  });
                },
        ),

        const SizedBox(height: AppSpacing.lg), // 16px padronizado
        // --- DROPDOWN 2: PRODUTO ---
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Produto'),
          value: _produtoSelecionado,
          hint: const Text('Selecione um produto'),
          isExpanded: true,
          items: _categoriaSelecionada == null
              ? []
              : _categoriasEProdutos[_categoriaSelecionada]!.map((String produto) {
                  return DropdownMenuItem<String>(
                    value: produto,
                    child: Text(produto, style: AppTextStyles.bodyMd),
                  );
                }).toList(),
          onChanged: (_categoriaSelecionada == null || _isSaving)
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
