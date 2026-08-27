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

      if (!mounted) {
        return;
      }

      setState(() {
        _respostas = respostas;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

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

    if (perguntaId == null) {
      return;
    }

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
    if (!_ehDono) {
      return;
    }

    final resultado = await Navigator.push<Pergunta>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return EditarPerguntaScreen(pergunta: widget.pergunta);
        },
      ),
    );

    if (!mounted || resultado == null) {
      return;
    }

    Navigator.pop(context, resultado);
  }

  // ============================================================
  // EXCLUIR PERGUNTA
  // ============================================================

  Future<void> _excluir() async {
    if (!_ehDono || _excluindo) {
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.delete_outline, size: 42),
          title: const Text('Excluir pergunta?'),
          content: const Text(
            'Essa pergunta será removida do Cortex. '
            'Essa ação não poderá ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
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

    if (confirmar != true) {
      return;
    }

    final perguntaId = widget.pergunta.id;

    if (perguntaId == null) {
      return;
    }

    setState(() {
      _excluindo = true;
    });

    try {
      await _perguntaRepository.excluir(perguntaId);

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), behavior: SnackBarBehavior.floating),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: tema.colorScheme.surface,

      appBar: AppBar(
        title: const Text(
          'Pergunta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _carregarRespostas,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
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
    final tema = Theme.of(context);
    final corPrincipal = tema.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tema.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tema.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------
          // AUTOR
          // ------------------------------------------------------

          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: corPrincipal.withOpacity(0.12),
                child: Icon(Icons.person_outline, color: corPrincipal),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuário #${widget.pergunta.userId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      _ehDono
                          ? 'Você publicou esta pergunta'
                          : 'Pergunta da comunidade',
                      style: TextStyle(
                        color: tema.colorScheme.onSurfaceVariant,
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
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: corPrincipal.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Você',
                    style: TextStyle(
                      color: corPrincipal,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // ------------------------------------------------------
          // TÍTULO
          // ------------------------------------------------------
          Text(
            widget.pergunta.titulo,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 14),

          // ------------------------------------------------------
          // DESCRIÇÃO
          // ------------------------------------------------------
          Text(
            widget.pergunta.descricao,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: tema.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------------
          // INFORMAÇÕES
          // ------------------------------------------------------
          Row(
            children: [
              Icon(
                Icons.question_answer_outlined,
                size: 18,
                color: tema.colorScheme.onSurfaceVariant,
              ),

              const SizedBox(width: 6),

              Text(
                '${_respostas.length} '
                'resposta'
                '${_respostas.length == 1 ? '' : 's'}',
                style: TextStyle(
                  color: tema.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // ------------------------------------------------------
          // BOTÕES DO DONO
          // ------------------------------------------------------
          if (_ehDono) ...[
            const SizedBox(height: 22),

            Divider(color: tema.colorScheme.outlineVariant),

            const SizedBox(height: 14),

            Row(
              children: [
                // EDITAR
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _editar,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                ),

                const SizedBox(width: 12),

                // EXCLUIR
                Expanded(
                  child: OutlinedButton.icon(
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
      child: Divider(height: 1),
    );
  }

  // ============================================================
  // TÍTULO DAS RESPOSTAS
  // ============================================================

  Widget _buildTituloRespostas() {
    final tema = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.forum_outlined),

          const SizedBox(width: 10),

          const Text(
            'Respostas',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),

          if (_respostas.isNotEmpty) ...[
            const SizedBox(width: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: tema.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_respostas.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: tema.colorScheme.onPrimaryContainer,
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
        child: Center(child: CircularProgressIndicator()),
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
    final tema = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: tema.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 42,
            color: tema.colorScheme.onSurfaceVariant,
          ),

          const SizedBox(height: 12),

          const Text(
            'Ainda não existem respostas.',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),

          const SizedBox(height: 6),

          Text(
            'Se você souber a resposta, '
            'seja o primeiro a ajudar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: tema.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARD DA RESPOSTA
  // ============================================================

  Widget _buildRespostaCard(Resposta resposta) {
    final tema = Theme.of(context);

    final ehMinhaResposta = resposta.userId == widget.usuarioAtualId;

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: resposta.melhorResposta
            ? tema.colorScheme.primaryContainer.withOpacity(0.35)
            : tema.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: resposta.melhorResposta
              ? tema.colorScheme.primary
              : tema.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: tema.colorScheme.secondaryContainer,
            child: Icon(
              Icons.person_outline,
              color: tema.colorScheme.onSecondaryContainer,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ehMinhaResposta
                            ? 'Você'
                            : 'Usuário #${resposta.userId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    if (resposta.melhorResposta) _buildMelhorResposta(),
                  ],
                ),

                const SizedBox(height: 9),

                Text(
                  resposta.texto,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MELHOR RESPOSTA
  // ============================================================

  Widget _buildMelhorResposta() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: Colors.green),

          SizedBox(width: 4),

          Text(
            'Melhor resposta',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.green,
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
    final tema = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tema.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tema.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_outlined, size: 20),

              SizedBox(width: 8),

              Text(
                'Sua resposta',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _respostaController,
            minLines: 3,
            maxLines: 7,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Ajude respondendo essa pergunta...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _enviandoResposta ? null : _responder,
              icon: _enviandoResposta
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
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
