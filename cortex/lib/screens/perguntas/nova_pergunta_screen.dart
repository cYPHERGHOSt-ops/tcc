import 'package:flutter/material.dart';

import '../../models/pergunta.dart';
import '../../models/usuario.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/pergunta_repository.dart';

class NovaPerguntaScreen extends StatefulWidget {
  const NovaPerguntaScreen({super.key});

  @override
  State<NovaPerguntaScreen> createState() => _NovaPerguntaScreenState();
}

class _NovaPerguntaScreenState extends State<NovaPerguntaScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  final PerguntaRepository _repository = PerguntaRepository();
  final AuthRepository _authRepository = AuthRepository();

  Usuario? _usuario;

  bool _carregando = true;
  bool _salvando = false;

  // Azul principal do Cortex
  static const Color _azul = Color(0xFF1D9BF0);

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final usuario = await _authRepository.usuarioLogado();

    if (!mounted) return;

    setState(() {
      _usuario = usuario;
      _carregando = false;
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarPergunta() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum usuário está logado.')),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final pergunta = Pergunta(
        userId: _usuario!.id,
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        materiaId: null,
      );

      await _repository.criar(pergunta);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _salvando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível publicar a pergunta.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: _azul)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Nova pergunta',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF2F3336)),
        ),
      ),

      // ============================================================
      // FORMULÁRIO
      // ============================================================
      body: Form(
        key: _formKey,

        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 30),

          children: [
            // ======================================================
            // CABEÇALHO
            // ======================================================

            const Text(
              'Faça uma pergunta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Compartilhe sua dúvida e deixe a comunidade ajudar.',
              style: TextStyle(
                color: Color(0xFF71767B),
                fontSize: 15,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 28),

            // ======================================================
            // TÍTULO
            // ======================================================
            const Text(
              'Título',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            TextFormField(
              controller: _tituloController,

              style: const TextStyle(color: Colors.white, fontSize: 16),

              cursorColor: _azul,

              maxLength: 255,

              decoration: InputDecoration(
                hintText: 'Qual é a sua dúvida?',
                hintStyle: const TextStyle(color: Color(0xFF71767B)),

                filled: true,
                fillColor: const Color(0xFF16181C),

                counterStyle: const TextStyle(color: Color(0xFF71767B)),

                prefixIcon: const Icon(
                  Icons.help_outline,
                  color: Color(0xFF71767B),
                ),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF2F3336)),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF2F3336)),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _azul, width: 1.5),
                ),

                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),

                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                    width: 1.5,
                  ),
                ),
              ),

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite o título da pergunta.';
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            // ======================================================
            // DESCRIÇÃO
            // ======================================================
            const Text(
              'Descrição',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            TextFormField(
              controller: _descricaoController,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),

              cursorColor: _azul,

              minLines: 6,
              maxLines: 10,

              textCapitalization: TextCapitalization.sentences,

              decoration: InputDecoration(
                hintText: 'Explique sua dúvida com detalhes...',
                hintStyle: const TextStyle(color: Color(0xFF71767B)),

                filled: true,
                fillColor: const Color(0xFF16181C),

                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 90),
                  child: Icon(
                    Icons.description_outlined,
                    color: Color(0xFF71767B),
                  ),
                ),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF2F3336)),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF2F3336)),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _azul, width: 1.5),
                ),

                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),

                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                    width: 1.5,
                  ),
                ),
              ),

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite a descrição da pergunta.';
                }

                return null;
              },
            ),

            const SizedBox(height: 28),

            // ======================================================
            // BOTÃO PUBLICAR
            // ======================================================
            SizedBox(
              height: 52,

              child: FilledButton.icon(
                onPressed: _salvando ? null : _salvarPergunta,

                style: FilledButton.styleFrom(
                  backgroundColor: _azul,
                  foregroundColor: Colors.white,

                  disabledBackgroundColor: const Color(0xFF1D4F70),

                  disabledForegroundColor: const Color(0xFFB8D9EA),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),

                icon: _salvando
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_outlined, size: 20),

                label: Text(
                  _salvando ? 'Publicando...' : 'Publicar pergunta',

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ======================================================
            // DICA
            // ======================================================
            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: const Color(0xFF16181C),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2F3336)),
              ),

              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: _azul, size: 20),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'Dica: quanto mais detalhes você colocar, '
                      'mais fácil será para outras pessoas ajudarem.',
                      style: TextStyle(
                        color: Color(0xFF9AA0A6),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
