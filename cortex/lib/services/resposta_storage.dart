import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/resposta.dart';

class RespostaStorage {
  static const String _chave = 'respostas';

  Future<List<Resposta>> listar() async {
    final preferences = await SharedPreferences.getInstance();

    final dados = preferences.getString(_chave);

    if (dados == null || dados.isEmpty) {
      return [];
    }

    final List<dynamic> lista = jsonDecode(dados);

    return lista
        .map((item) => Resposta.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> salvar(Resposta resposta) async {
    final respostas = await listar();

    respostas.add(resposta);

    await _salvarLista(respostas);
  }

  Future<List<Resposta>> listarPorPergunta(int perguntaId) async {
    final respostas = await listar();

    return respostas
        .where((resposta) => resposta.perguntaId == perguntaId)
        .toList();
  }

  Future<void> atualizar(Resposta resposta) async {
    final respostas = await listar();

    final index = respostas.indexWhere((item) => item.id == resposta.id);

    if (index == -1) {
      return;
    }

    respostas[index] = resposta;

    await _salvarLista(respostas);
  }

  Future<void> excluir(int id) async {
    final respostas = await listar();

    respostas.removeWhere((resposta) => resposta.id == id);

    await _salvarLista(respostas);
  }

  Future<void> _salvarLista(List<Resposta> respostas) async {
    final preferences = await SharedPreferences.getInstance();

    final lista = respostas.map((resposta) => resposta.toMap()).toList();

    await preferences.setString(_chave, jsonEncode(lista));
  }
}
