class Presenca {
  final String alunoId;
  final String nome;
  final bool presente;

  const Presenca({
    required this.alunoId,
    required this.nome,
  required this.presente,
  });

  factory Presenca.fromJson(Map<String, dynamic> json){
    return Presenca(
      alunoId: json["alunoId"] as String,
      nome: json["nome"] as String, 
      presente: json["presente"] as bool
    );
  }

  Presenca copyWith({
    String? alunoId,
    String? nome,
    bool? presente,
  }) {
    return Presenca(
      alunoId: alunoId ?? this.alunoId,
      nome: nome ?? this.nome,
      presente: presente ?? this.presente,
    );
  }
}