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

  Map<String, dynamic> toJson() {
    return {
      'alunoId': alunoId,
      'nome': nome,
      'presente': presente,
    };
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