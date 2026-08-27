import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pergunta.dart';

class PerguntaStorage {
  static const String _chavePerguntas = 'perguntas';

  // ============================================================
  // LISTAR
  // ============================================================

  Future<List<Pergunta>> listar() async {
    final preferences = await SharedPreferences.getInstance();

    final dados = preferences.getString(_chavePerguntas);

    if (dados == null || dados.isEmpty) {
      return [];
    }

    final List<dynamic> json = jsonDecode(dados);

    return json
        .map((item) => Pergunta.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  // ============================================================
  // SALVAR
  // ============================================================

  Future<void> salvar(Pergunta pergunta) async {
    final preferences = await SharedPreferences.getInstance();

    final perguntas = await listar();

    final novoId = perguntas.isEmpty
        ? 1
        : perguntas
                  .map((pergunta) => pergunta.id ?? 0)
                  .reduce((a, b) => a > b ? a : b) +
              1;

    final novaPergunta = Pergunta(
      id: novoId,
      userId: pergunta.userId,
      titulo: pergunta.titulo,
      descricao: pergunta.descricao,
      materiaId: pergunta.materiaId,
    );

    perguntas.add(novaPergunta);

    await _salvarLista(perguntas);
  }

  // ============================================================
  // EDITAR
  // ============================================================

  Future<void> editar(Pergunta pergunta) async {
    final perguntas = await listar();

    final index = perguntas.indexWhere((item) => item.id == pergunta.id);

    if (index == -1) {
      throw Exception('Pergunta não encontrada.');
    }

    perguntas[index] = pergunta;

    await _salvarLista(perguntas);
  }

  // ============================================================
  // EXCLUIR
  // ============================================================

  Future<void> excluir(int id) async {
    final perguntas = await listar();

    perguntas.removeWhere((pergunta) => pergunta.id == id);

    await _salvarLista(perguntas);
  }

  // ============================================================
  // SALVAR LISTA
  // ============================================================

  Future<void> _salvarLista(List<Pergunta> perguntas) async {
    final preferences = await SharedPreferences.getInstance();

    final dados = perguntas.map((pergunta) => pergunta.toMap()).toList();

    await preferences.setString(_chavePerguntas, jsonEncode(dados));
  }
}
