import 'package:vocattio/models/faltas_do_dia.dart';
import 'package:vocattio/models/relatorio_aluno.dart';

class RelatorioTurma {
  final List<RelatorioAluno> alunosInfo;
  final List<FaltasDoDia> diasInfo;
  final int totalDeFaltas;
  final int totalDeAulas;
  final double mediaDaTurma;

  const RelatorioTurma({
    required this.alunosInfo,
    required this.diasInfo,
    required this.totalDeAulas,
    required this.totalDeFaltas,
    required this.mediaDaTurma,
  });

 factory RelatorioTurma.fromJson(Map<String, dynamic> json) {
    return RelatorioTurma(
      alunosInfo: (json['alunosInfo'] as List)
          .map((item) => RelatorioAluno.fromJson(item))
          .toList(),
      diasInfo: (json['diasInfo'] as List)
          .map((item) => FaltasDoDia.fromJson(item))
          .toList(),
      totalDeFaltas: json['totalDeFaltas'],
      totalDeAulas: json['totalDeAulas'],
      mediaDaTurma: (json['mediaDaTurma'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alunosInfo': alunosInfo.map((a) => a.toJson()).toList(),
      'diasInfo': diasInfo.map((d) => d.toJson()).toList(),
      'totalDeFaltas': totalDeFaltas,
      'totalDeAulas': totalDeAulas,
      'mediaDaTurma': mediaDaTurma,
    };
  }
}