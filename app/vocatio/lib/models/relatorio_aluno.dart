class RelatorioAluno {
  final String alunoId;
  final String alunoNome;
  final int totalDeFaltas;
  final int totalDeAulas;
  final double porcentagemPresenca;

  const RelatorioAluno({
    required this.alunoId,
    required this.alunoNome,
    required this.totalDeAulas,
    required this.totalDeFaltas,
    required this.porcentagemPresenca,
  });

  factory RelatorioAluno.fromJson(Map<String, dynamic> json) {
    return RelatorioAluno(
      alunoId: json['alunoId'],
      alunoNome: json['alunoNome'],
      totalDeAulas: json['totalDeAulas'],
      totalDeFaltas: json['totalDeFaltas'],
      porcentagemPresenca: (json['porcentagemPresenca'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alunoId': alunoId,
      'alunoNome': alunoNome,
      'totalDeAulas': totalDeAulas,
      'totalDeFaltas': totalDeFaltas,
      'porcentagemPresenca': porcentagemPresenca,
    };
  }
}