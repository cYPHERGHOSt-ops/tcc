import '../models/usuario.dart';
import '../services/auth_storage.dart';

class AuthRepository {
  final AuthStorage _storage = AuthStorage();

  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final usuarioExistente = await _storage.buscarPorEmail(email);

    if (usuarioExistente != null) {
      return false;
    }

    final usuarios = await _storage.listarUsuarios();

    final novoId = usuarios.isEmpty
        ? 1
        : usuarios
                  .map((usuario) => usuario.id)
                  .reduce((a, b) => a > b ? a : b) +
              1;

    final usuario = Usuario(id: novoId, nome: nome, email: email, senha: senha);

    await _storage.salvarUsuario(usuario);

    await _storage.salvarSessao(usuario);

    return true;
  }

  Future<Usuario?> login({required String email, required String senha}) async {
    final usuario = await _storage.buscarPorEmail(email);

    if (usuario == null) {
      return null;
    }

    if (usuario.senha != senha) {
      return null;
    }

    await _storage.salvarSessao(usuario);

    return usuario;
  }

  Future<Usuario?> usuarioLogado() async {
    return await _storage.usuarioLogado();
  }

  Future<void> logout() async {
    await _storage.logout();
  }
}
