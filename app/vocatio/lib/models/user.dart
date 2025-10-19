class User{
  final String uid;
  final String nome;
  final String email;
  final String tipo;
  final String codigo;

  const User({
    required this.uid,
    required this.nome,
    required this.email,
    required this.tipo,
    required this.codigo,
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

  User copyWith({
    String? uid,
    String? nome,
    String? email,
    String? tipo,
    String? codigo,
  }) {
    return User(
      uid: uid ?? this.uid,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      tipo: tipo ?? this.tipo,
      codigo: codigo ?? this.codigo,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      tipo: json['tipo'] ?? '',
      codigo: json['codigo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'tipo': tipo,
      'codigo': codigo,
    };
  }

  @override
  String toString(){
    return 'User{uid: $uid, name: $nome, email: $email, tipo: $tipo, codigo: $codigo}';
  }

}