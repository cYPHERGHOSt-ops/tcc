import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pergunta.dart';

import 'package:flutter/foundation.dart';

class PerguntaStorage {
  static const String _chavePerguntas = 'perguntas';

  // ============================================================
  // LISTAR
  // ============================================================

  Future<List<Pergunta>> listar() async {
    final preferences = await SharedPreferences.getInstance();

    final dados = preferences.getString(_chavePerguntas);

    if (dados == null || dados.isEmpty) {
      debugPrint('LISTAR: nenhuma pergunta encontrada.');
      return [];
    }

    final List<dynamic> json = jsonDecode(dados);

    final perguntas = json
        .map((item) => Pergunta.fromMap(Map<String, dynamic>.from(item)))
        .toList();

    debugPrint('LISTAR: ${perguntas.length} perguntas encontradas.');

    for (final pergunta in perguntas) {
      debugPrint(
        '  ID: ${pergunta.id} | '
        'USER: ${pergunta.userId} | '
        'TITULO: ${pergunta.titulo}',
      );
    }

    return perguntas;
  }

  // ============================================================
  // SALVAR
  // ============================================================

  Future<void> salvar(Pergunta pergunta) async {
    final perguntas = await listar();

    final novoId = perguntas.isEmpty
        ? 1
        : perguntas.map((p) => p.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;

    final novaPergunta = Pergunta(
      id: novoId,
      userId: pergunta.userId,
      titulo: pergunta.titulo,
      descricao: pergunta.descricao,
      materiaId: pergunta.materiaId,
    );

    perguntas.add(novaPergunta);

    await _salvarLista(perguntas);

    debugPrint('SALVAR: pergunta criada com ID $novoId');
  }

  // ============================================================
  // EDITAR
  // ============================================================

  Future<void> editar(Pergunta pergunta) async {
    if (pergunta.id == null) {
      throw Exception('Não é possível editar uma pergunta sem ID.');
    }

    final perguntas = await listar();

    debugPrint('EDITAR: procurando pergunta com ID ${pergunta.id}');

    debugPrint(
      'EDITAR: IDs existentes: '
      '${perguntas.map((p) => p.id).toList()}',
    );

    final index = perguntas.indexWhere((item) => item.id == pergunta.id);

    if (index == -1) {
      throw Exception(
        'Pergunta com ID ${pergunta.id} não encontrada. '
        'IDs existentes: ${perguntas.map((p) => p.id).toList()}',
      );
    }

    perguntas[index] = Pergunta(
      id: pergunta.id,
      userId: pergunta.userId,
      titulo: pergunta.titulo,
      descricao: pergunta.descricao,
      materiaId: pergunta.materiaId,
    );

    await _salvarLista(perguntas);

    debugPrint('EDITAR: pergunta ${pergunta.id} alterada com sucesso.');
  }

  // ============================================================
  // EXCLUIR
  // ============================================================

  Future<void> excluir(int id) async {
    final perguntas = await listar();

    final quantidadeAntes = perguntas.length;

    perguntas.removeWhere((pergunta) => pergunta.id == id);

    if (perguntas.length == quantidadeAntes) {
      throw Exception('Pergunta com ID $id não encontrada.');
    }

    await _salvarLista(perguntas);

    debugPrint('EXCLUIR: pergunta $id excluída com sucesso.');
  }

  // ============================================================
  // SALVAR LISTA
  // ============================================================

  Future<void> _salvarLista(List<Pergunta> perguntas) async {
    final preferences = await SharedPreferences.getInstance();

    final dados = perguntas.map((pergunta) => pergunta.toMap()).toList();

    final sucesso = await preferences.setString(
      _chavePerguntas,
      jsonEncode(dados),
    );

    if (!sucesso) {
      throw Exception('Não foi possível salvar as perguntas.');
    }

    debugPrint('SALVAR LISTA: ${perguntas.length} perguntas salvas.');
  }

  // ============================================================
  // LIMPAR TODAS
  // ============================================================

  Future<void> limparTodas() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_chavePerguntas);

    debugPrint('LIMPAR: todas as perguntas foram removidas.');
  }
}
