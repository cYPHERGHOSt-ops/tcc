import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/resposta.dart';

class RespostaStorage {
  static const String _chave = 'respostas';

  // ============================================================
  // LISTAR TODAS
  // ============================================================

  Future<List<Resposta>> listar() async {
    final preferences = await SharedPreferences.getInstance();

    final dados = preferences.getString(_chave);

    if (dados == null || dados.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(dados);

      if (decoded is! List) {
        return [];
      }

      final respostas = <Resposta>[];

      for (final item in decoded) {
        try {
          if (item is Map) {
            respostas.add(Resposta.fromMap(Map<String, dynamic>.from(item)));
          }
        } catch (e) {
          debugPrint('RESPOSTA STORAGE: resposta inválida ignorada: $e');
        }
      }

      return respostas;
    } catch (e) {
      debugPrint('RESPOSTA STORAGE: erro ao ler respostas: $e');

      return [];
    }
  }

  // ============================================================
  // SALVAR NOVA RESPOSTA
  // ============================================================

  Future<void> salvar(Resposta resposta) async {
    final respostas = await listar();

    // Evita cadastrar a mesma resposta duas vezes.
    final existe = respostas.any((item) => item.id == resposta.id);

    if (existe) {
      debugPrint('RESPOSTA STORAGE: resposta ${resposta.id} já existe.');
      return;
    }

    respostas.add(resposta);

    await _salvarLista(respostas);

    debugPrint(
      'RESPOSTA STORAGE: resposta salva '
      'ID=${resposta.id} '
      'PERGUNTA=${resposta.perguntaId} '
      'USER=${resposta.userId} '
      'TEXTO="${resposta.texto}"',
    );
  }

  // ============================================================
  // LISTAR POR PERGUNTA
  // ============================================================

  Future<List<Resposta>> listarPorPergunta(int perguntaId) async {
    final respostas = await listar();

    final resultado = respostas
        .where((resposta) => resposta.perguntaId == perguntaId)
        .toList();

    debugPrint(
      'RESPOSTA STORAGE: pergunta $perguntaId '
      'possui ${resultado.length} respostas.',
    );

    for (final resposta in resultado) {
      debugPrint(
        '  RESPOSTA ID=${resposta.id} '
        '| USER=${resposta.userId} '
        '| TEXTO=${resposta.texto}',
      );
    }

    return resultado;
  }

  // ============================================================
  // ATUALIZAR
  // ============================================================

  Future<void> atualizar(Resposta resposta) async {
    final respostas = await listar();

    final index = respostas.indexWhere((item) => item.id == resposta.id);

    if (index == -1) {
      debugPrint('RESPOSTA STORAGE: resposta ${resposta.id} não encontrada.');
      return;
    }

    respostas[index] = resposta;

    await _salvarLista(respostas);

    debugPrint('RESPOSTA STORAGE: resposta ${resposta.id} atualizada.');
  }

  // ============================================================
  // EXCLUIR UMA RESPOSTA
  // ============================================================

  Future<void> excluir(int id) async {
    final respostas = await listar();

    final quantidadeAntes = respostas.length;

    respostas.removeWhere((resposta) => resposta.id == id);

    await _salvarLista(respostas);

    final removida = quantidadeAntes != respostas.length;

    debugPrint(
      removida
          ? 'RESPOSTA STORAGE: resposta $id excluída.'
          : 'RESPOSTA STORAGE: resposta $id não encontrada.',
    );
  }

  // ============================================================
  // EXCLUIR TODAS AS RESPOSTAS DE UMA PERGUNTA
  // ============================================================

  Future<void> excluirPorPergunta(int perguntaId) async {
    final respostas = await listar();

    final antes = respostas.length;

    respostas.removeWhere((resposta) => resposta.perguntaId == perguntaId);

    await _salvarLista(respostas);

    final removidas = antes - respostas.length;

    debugPrint(
      'RESPOSTA STORAGE: '
      '$removidas respostas removidas da pergunta $perguntaId.',
    );
  }

  // ============================================================
  // LIMPAR TODAS AS RESPOSTAS
  //
  // USE APENAS PARA LIMPAR OS DADOS DOS TESTES ANTIGOS.
  // ============================================================

  Future<void> limparTodas() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_chave);

    debugPrint('RESPOSTA STORAGE: TODAS AS RESPOSTAS FORAM APAGADAS.');
  }

  // ============================================================
  // SALVAR LISTA
  // ============================================================

  Future<void> _salvarLista(List<Resposta> respostas) async {
    final preferences = await SharedPreferences.getInstance();

    final lista = respostas.map((resposta) => resposta.toMap()).toList();

    await preferences.setString(_chave, jsonEncode(lista));

    debugPrint('RESPOSTA STORAGE: ${respostas.length} respostas salvas.');
  }
}
