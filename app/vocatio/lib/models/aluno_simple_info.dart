class AlunoSimpleInfo {
  final String nome;
  final String email;

  const AlunoSimpleInfo({
    required this.nome,
    required this.email
  });

  factory AlunoSimpleInfo.fromJson(Map<String, dynamic> json){
    return AlunoSimpleInfo(
      nome: json['nome'] as String, 
      email: json['email'] as String,
    );
  }
}