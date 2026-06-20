class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String senha; // hash SHA-256

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'email': email,
        'senha': senha,
      };

  factory Usuario.fromMap(Map<String, dynamic> m) => Usuario(
        id: m['id'] as int?,
        nome: m['nome'] as String,
        email: m['email'] as String,
        senha: m['senha'] as String,
      );
}
