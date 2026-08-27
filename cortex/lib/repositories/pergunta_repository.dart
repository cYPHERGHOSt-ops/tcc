import '../models/pergunta.dart';
import '../services/pergunta_storage.dart';

class PerguntaRepository {
  final PerguntaStorage _storage = PerguntaStorage();

  // ============================================================
  // CRIAR
  // ============================================================

  Future<void> criar(Pergunta pergunta) async {
    await _storage.salvar(pergunta);
  }

  // ============================================================
  // LISTAR
  // ============================================================

  Future<List<Pergunta>> listar() async {
    return await _storage.listar();
  }

  // ============================================================
  // EDITAR
  // ============================================================

  Future<void> editar(Pergunta pergunta) async {
    await _storage.editar(pergunta);
  }

  // ============================================================
  // EXCLUIR
  // ============================================================

  Future<void> excluir(int id) async {
    await _storage.excluir(id);
  }
}
