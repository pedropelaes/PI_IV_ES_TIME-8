import 'dart:ffi';

import 'package:vocattio/models/user.dart';

class Turma {
  final String objectId;
  final String nome;
  final String descricao;
  final String professorId;
  final String codigo;
  final List<String> alunos;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  const Turma({
    required this.objectId, 
    required this.nome, 
    required this.descricao, 
    required this.professorId, 
    required this.codigo, 
    required this.alunos, 
    required this.criadoEm, 
    required this.atualizadoEm, 
  });

    factory Turma.fromJson(Map<String, dynamic> json) {
    return Turma(
      objectId: json['_id'] ?? '',
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      professorId: json['professorId'] ?? '',
      codigo: json['codigo'] ?? '',
      alunos: List<String>.from(json['alunos'] ?? []),
      criadoEm: DateTime.tryParse(json['criadoEm'] ?? '') ?? DateTime.now(),
      atualizadoEm: DateTime.tryParse(json['atualizadoEm'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  String toString(){
    return "Turma: {$nome, $descricao, $professorId, $codigo, $alunos, $criadoEm, $atualizadoEm}";
  }
}