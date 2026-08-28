import 'package:flutter/material.dart';

import '../../models/pergunta.dart';
import '../../models/resposta.dart';
import '../../repositories/pergunta_repository.dart';
import '../../repositories/resposta_repository.dart';
import 'editar_pergunta_screen.dart';

class PerguntaDetalhesScreen extends StatefulWidget {
  final Pergunta pergunta;
  final int usuarioAtualId;

  const PerguntaDetalhesScreen({
    super.key,
    required this.pergunta,
    required this.usuarioAtualId,
  });

  @override
  State<PerguntaDetalhesScreen> createState() => _PerguntaDetalhesScreenState();
}

class _PerguntaDetalhesScreenState extends State<PerguntaDetalhesScreen> {
  final PerguntaRepository _perguntaRepository = PerguntaRepository();
  final RespostaRepository _respostaRepository = RespostaRepository();
  final TextEditingController _respostaController = TextEditingController();

  List<Resposta> _respostas = [];

  bool _carregando = true;
  bool _enviandoResposta = false;
  bool _excluindo = false;

  // ============================================================
  // CORES
  // ============================================================

  static const Color _fundo = Color(0xFF000000);
  static const Color _card = Color(0xFF16181C);
  static const Color _cardMaisEscuro = Color(0xFF101214);
  static const Color _borda = Color(0xFF2F3336);
  static const Color _azul = Color(0xFF1D9BF0);
  static const Color _texto = Color(0xFFE7E9EA);
  static const Color _textoSecundario = Color(0xFF71767B);

  bool get _ehDono {
    return widget.pergunta.userId == widget.usuarioAtualId;
  }

  @override
  void initState() {
    super.initState();
    _carregarRespostas();
  }

  @override
  void dispose() {
    _respostaController.dispose();
    super.dispose();
  }

  // ============================================================
  // CARREGAR RESPOSTAS
  // ============================================================

  Future<void> _carregarRespostas() async {
    final perguntaId = widget.pergunta.id;

    if (perguntaId == null) {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
      return;
    }

    try {
      final respostas = await _respostaRepository.listarPorPergunta(perguntaId);

      if (!mounted) return;

      setState(() {
        _respostas = respostas;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregando = false;
      });

      _mostrarMensagem('Não foi possível carregar as respostas.');
    }
  }

  // ============================================================
  // RESPONDER
  // ============================================================

  Future<void> _responder() async {
    final texto = _respostaController.text.trim();

    if (texto.isEmpty) {
      _mostrarMensagem('Digite uma resposta antes de enviar.');
      return;
    }

    final perguntaId = widget.pergunta.id;

    if (perguntaId == null) return;

    setState(() {
      _enviandoResposta = true;
    });

    try {
      final resposta = Resposta(
        id: DateTime.now().millisecondsSinceEpoch,
        perguntaId: perguntaId,
        userId: widget.usuarioAtualId,
        texto: texto,
      );

      await _respostaRepository.criar(resposta);

      _respostaController.clear();

      await _carregarRespostas();
    } catch (e) {
      if (mounted) {
        _mostrarMensagem('Não foi possível enviar a resposta.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _enviandoResposta = false;
        });
      }
    }
  }

  // ============================================================
  // EDITAR PERGUNTA
  // ============================================================

  Future<void> _editar() async {
    if (!_ehDono) return;

    final resultado = await Navigator.push<Pergunta>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return EditarPerguntaScreen(pergunta: widget.pergunta);
        },
      ),
    );

    if (!mounted || resultado == null) return;

    Navigator.pop(context, resultado);
  }

  // ============================================================
  // EXCLUIR PERGUNTA
  // ============================================================

  Future<void> _excluir() async {
    if (!_ehDono || _excluindo) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _card,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Excluir pergunta?',
            style: TextStyle(color: _texto),
          ),
          content: const Text(
            'Essa pergunta será removida do Cortex. '
            'Essa ação não poderá ser desfeita.',
            style: TextStyle(color: _textoSecundario),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: _textoSecundario),
              ),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    final perguntaId = widget.pergunta.id;

    if (perguntaId == null) return;

    setState(() {
      _excluindo = true;
    });

    try {
      await _perguntaRepository.excluir(perguntaId);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _excluindo = false;
      });

      _mostrarMensagem('Não foi possível excluir a pergunta.');
    }
  }

  // ============================================================
  // MENSAGEM
  // ============================================================

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _card,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fundo,

      appBar: AppBar(
        backgroundColor: _fundo,
        foregroundColor: _texto,
        elevation: 0,
        title: const Text(
          'Pergunta',
          style: TextStyle(fontWeight: FontWeight.bold, color: _texto),
        ),
      ),

      body: RefreshIndicator(
        color: _azul,
        backgroundColor: _card,
        onRefresh: _carregarRespostas,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 40),
          children: [
            _buildPergunta(),

            const SizedBox(height: 28),

            _buildSeparador(),

            const SizedBox(height: 24),

            _buildTituloRespostas(),

            const SizedBox(height: 16),

            _buildRespostas(),

            const SizedBox(height: 28),

            _buildCampoResposta(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CARD DA PERGUNTA
  // ============================================================

  Widget _buildPergunta() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AUTOR

          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _azul.withOpacity(0.15),
                ),
                child: const Icon(Icons.person_outline, color: _azul),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _ehDono ? 'Você' : 'Usuário #${widget.pergunta.userId}',
                      style: const TextStyle(
                        color: _texto,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      _ehDono
                          ? 'Você publicou esta pergunta'
                          : 'Pergunta da comunidade',
                      style: const TextStyle(
                        color: _textoSecundario,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              if (_ehDono)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _azul.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Você',
                    style: TextStyle(
                      color: _azul,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // TÍTULO
          Text(
            widget.pergunta.titulo,
            style: const TextStyle(
              color: _texto,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 14),

          // DESCRIÇÃO
          Text(
            widget.pergunta.descricao,
            style: const TextStyle(color: _texto, fontSize: 16, height: 1.55),
          ),

          const SizedBox(height: 20),

          // CONTADOR
          Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: _textoSecundario,
              ),

              const SizedBox(width: 6),

              Text(
                '${_respostas.length} '
                'resposta'
                '${_respostas.length == 1 ? '' : 's'}',
                style: const TextStyle(color: _textoSecundario, fontSize: 13),
              ),
            ],
          ),

          // BOTÕES DO DONO
          if (_ehDono) ...[
            const SizedBox(height: 20),

            const Divider(color: _borda),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _azul,
                      side: const BorderSide(color: _borda),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _editar,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: _borda),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _excluindo ? null : _excluir,
                    icon: _excluindo
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline),
                    label: Text(_excluindo ? 'Excluindo...' : 'Excluir'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // SEPARADOR
  // ============================================================

  Widget _buildSeparador() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: _borda, height: 1),
    );
  }

  // ============================================================
  // TÍTULO DAS RESPOSTAS
  // ============================================================

  Widget _buildTituloRespostas() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.forum_outlined, color: _azul),

          const SizedBox(width: 10),

          const Text(
            'Respostas',
            style: TextStyle(
              color: _texto,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (_respostas.isNotEmpty) ...[
            const SizedBox(width: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: _azul.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_respostas.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _azul,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // RESPOSTAS
  // ============================================================

  Widget _buildRespostas() {
    if (_carregando) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(child: CircularProgressIndicator(color: _azul)),
      );
    }

    if (_respostas.isEmpty) {
      return _buildSemRespostas();
    }

    return Column(
      children: _respostas.map((resposta) {
        return _buildRespostaCard(resposta);
      }).toList(),
    );
  }

  // ============================================================
  // SEM RESPOSTAS
  // ============================================================

  Widget _buildSemRespostas() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: _cardMaisEscuro,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borda),
      ),
      child: const Column(
        children: [
          Icon(Icons.chat_bubble_outline, size: 42, color: _textoSecundario),

          SizedBox(height: 12),

          Text(
            'Ainda não existem respostas.',
            style: TextStyle(
              color: _texto,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),

          SizedBox(height: 6),

          Text(
            'Se você souber a resposta, '
            'seja o primeiro a ajudar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textoSecundario),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARD DA RESPOSTA
  // ============================================================

  Widget _buildRespostaCard(Resposta resposta) {
    final ehMinhaResposta = resposta.userId == widget.usuarioAtualId;

    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borda),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _azul.withOpacity(0.12),
            ),
            child: const Icon(Icons.person_outline, color: _azul, size: 21),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ehMinhaResposta ? 'Você' : 'Usuário #${resposta.userId}',
                  style: const TextStyle(
                    color: _texto,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  resposta.texto,
                  style: const TextStyle(
                    color: _texto,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CAMPO DE RESPOSTA
  // ============================================================

  Widget _buildCampoResposta() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_outlined, size: 20, color: _azul),

              SizedBox(width: 8),

              Text(
                'Sua resposta',
                style: TextStyle(
                  color: _texto,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _respostaController,
            minLines: 3,
            maxLines: 7,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(color: _texto),
            decoration: InputDecoration(
              hintText: 'Ajude respondendo essa pergunta...',
              hintStyle: const TextStyle(color: _textoSecundario),
              filled: true,
              fillColor: _cardMaisEscuro,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _borda),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _borda),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _azul, width: 1.5),
              ),
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _azul,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _enviandoResposta ? null : _responder,
              icon: _enviandoResposta
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(
                _enviandoResposta ? 'Enviando...' : 'Enviar resposta',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
