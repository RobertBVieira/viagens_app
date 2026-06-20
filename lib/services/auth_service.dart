import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../db/database_helper.dart';
import '../models/usuario.dart';

/// Regras de autenticação. Mantém o usuário logado em memória.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _db = DatabaseHelper.instance;
  Usuario? usuarioLogado;

  static String _hash(String senha) =>
      sha256.convert(utf8.encode(senha)).toString();

  /// Retorna mensagem de erro, ou null em caso de sucesso.
  Future<String?> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    if (await _db.emailExiste(email)) {
      return 'Este e-mail já está cadastrado.';
    }
    await _db.inserirUsuario(Usuario(
      nome: nome,
      email: email,
      senha: _hash(senha),
    ));
    return null;
  }

  /// Retorna true se o login deu certo.
  Future<bool> login(String email, String senha) async {
    final u = await _db.buscarLogin(email, _hash(senha));
    if (u == null) return false;
    usuarioLogado = u;
    return true;
  }

  void logout() => usuarioLogado = null;
}
