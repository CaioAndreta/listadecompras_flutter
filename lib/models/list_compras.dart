import 'package:flutter_application_1/models/produto.dart';

class ListaCompras {
  String listaId;
  int tipoLista;
  String titulo;
  int atual;
  int total;
  List<Produto> produtos;

  ListaCompras({
    required this.listaId,
    required this.tipoLista,
    required this.titulo,
    required this.atual,
    required this.total,
    required this.produtos,
  });

  factory ListaCompras.fromJson(Map<String, dynamic> json) {
    return ListaCompras(
      listaId: json['ListaId'] ?? '',
      tipoLista: json['TipoLista'] ?? 0,
      titulo: json['Titulo'] ?? '',
      atual: json['atual'] ?? 0,
      total: json['total'] ?? 0,
      produtos: json['produto'] != null ? (json['produto'] as List).map((i) => Produto.fromJson(i)).toList() : [],
    );
  }
}
