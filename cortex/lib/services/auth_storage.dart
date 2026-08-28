import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';

class AuthStorage {
  static const String _chaveUsuarios = 'usuarios';
  static const String _chaveUsuarioLogado = 'usuario_logado';

  Future<List<Usuario>> listarUsuarios() async {
    final preferences = await SharedPreferences.getInstance();

    final dados = preferences.getString(_chaveUsuarios);

    if (dados == null || dados.isEmpty) {
      return [];
    }

    final List<dynamic> json = jsonDecode(dados);

    return json
        .map((item) => Usuario.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> salvarUsuario(Usuario usuario) async {
    final preferences = await SharedPreferences.getInstance();

    final usuarios = await listarUsuarios();

    usuarios.add(usuario);

    await preferences.setString(
      _chaveUsuarios,
      jsonEncode(usuarios.map((usuario) => usuario.toMap()).toList()),
    );
  }

  Future<Usuario?> buscarPorEmail(String email) async {
    final usuarios = await listarUsuarios();

    for (final usuario in usuarios) {
      if (usuario.email.toLowerCase() == email.toLowerCase()) {
        return usuario;
      }
    }

    return null;
  }

  Future<void> salvarSessao(Usuario usuario) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _chaveUsuarioLogado,
      jsonEncode(usuario.toMap()),
    );
  }

  Future<Usuario?> usuarioLogado() async {
    final preferences = await SharedPreferences.getInstance();

    final dados = preferences.getString(_chaveUsuarioLogado);

    if (dados == null || dados.isEmpty) {
      return null;
    }

    return Usuario.fromMap(Map<String, dynamic>.from(jsonDecode(dados)));
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_chaveUsuarioLogado);
  }

  Future<void> limparDados() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();

    print('DADOS DO APP APAGADOS!');
  }
}
