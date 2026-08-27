class Usuario {
  final int id;
  final String nome;
  final String email;
  final String senha;
  final String? bio;
  final String? foto;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    this.bio,
    this.foto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'bio': bio,
      'foto': foto,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int,
      nome: map['nome'] as String,
      email: map['email'] as String,
      senha: map['senha'] as String,
      bio: map['bio'] as String?,
      foto: map['foto'] as String?,
    );
  }
}
