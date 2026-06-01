class Produto {
  String nome;
  String categoria;
  int check;

  Produto({required this.nome, required this.categoria, required this.check});

  bool get isChecked => check == 1;
  set isChecked(bool value) => check = value ? 1 : 2;

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      nome: json['nome'] ?? '',
      categoria: json['categoria'] ?? 'Sem Categoria',
      check: json['check'] ?? 2,
    );
  }
}
