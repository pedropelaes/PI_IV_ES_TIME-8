class Presenca {
  final String alunoId;
  final bool presente;

  const Presenca({
    required this.alunoId,
    required this.presente,
  });

  factory Presenca.fromJson(Map<String, dynamic> json){
    return Presenca(
      alunoId: json["alunoId"] as String, 
      presente: json["presente"] as bool
    );
  }
}