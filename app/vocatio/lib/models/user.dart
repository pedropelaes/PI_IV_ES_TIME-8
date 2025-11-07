class User{
  final String? objectId;
  final String uid;
  final String nome;
  final String email;
  final String tipo;
  final String codigo;
  final List<String>? turmas;

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

  List<String>? getTurmas(){
    return turmas;
  }

  User copyWith({
    String? objectId,
    String? uid,
    String? nome,
    String? email,
    String? tipo,
    String? codigo,
    List<String>? turmas
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
      turmas: json['turmas'] != null 
                            ? List<String>.from(json['turmas']) 
                            : null
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

class AlunoResumo {
  final String objectId;
  final String nome;

  const AlunoResumo({
    required this.objectId,
    required this.nome,
  });

  factory AlunoResumo.fromJson(Map<String, dynamic> json) {
    return AlunoResumo(
      objectId: json['_id'],
      nome: json['nome'],
    );
  }
}