import '../models/resposta.dart';

import '../services/resposta_storage.dart';

class RespostaRepository {
  final RespostaStorage _storage = RespostaStorage();

  Future<void> criar(Resposta resposta) async {
    await _storage.salvar(resposta);
  }

  Future<List<Resposta>> listarPorPergunta(int perguntaId) async {
    return await _storage.listarPorPergunta(perguntaId);
  }

  Future<void> atualizar(Resposta resposta) async {
    await _storage.atualizar(resposta);
  }

  Future<void> excluir(int id) async {
    await _storage.excluir(id);
  }
}
