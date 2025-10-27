import 'package:bson/bson.dart';

class User{
  final String? objectId;
  final String uid;
  final String nome;
  final String email;
  final String tipo;
  final String codigo;
  final List<Map<String, dynamic>>? turmas;

  const User({
    this.objectId,
    required this.uid,
    required this.nome,
    required this.email,
    required this.tipo,
    required this.codigo,
    this.turmas
  });

  String getUid(){
    return uid;
  }

  String getNome(){
    return nome;
  }

  String getEmail(){
    return email;
  }

  String getTipo(){
    return tipo;
  }

  String getCodigo(){
    return codigo;
  }

  List<Map<String, dynamic>>? getTurmas(){
    return turmas;
  }

  User copyWith({
    String? objectId,
    String? uid,
    String? nome,
    String? email,
    String? tipo,
    String? codigo,
    List<Map<String, dynamic>>? turmas
  }) {
    return User(
      objectId: objectId ?? this.objectId,
      uid: uid ?? this.uid,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      tipo: tipo ?? this.tipo,
      codigo: codigo ?? this.codigo,
      turmas: turmas ?? this.turmas
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      objectId: json['_id'] ?? '',
      uid: json['uid'] ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      tipo: json['tipo'] ?? '',
      codigo: json['codigo'] ?? '',
      turmas: json['turmas'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': objectId,
      'uid': uid,
      'nome': nome,
      'email': email,
      'tipo': tipo,
      'codigo': codigo,
      'turmas': turmas
    };
  }

  @override
  String toString(){
    return 'User{_id: $objectId, $uid, name: $nome, email: $email, tipo: $tipo, codigo: $codigo, turmas: $turmas}';
  }

}