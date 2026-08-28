import 'package:flutter/material.dart';

import '../../models/pergunta.dart';
import '../../repositories/pergunta_repository.dart';

class EditarPerguntaScreen extends StatefulWidget {
  final Pergunta pergunta;

  const EditarPerguntaScreen({super.key, required this.pergunta});

  @override
  State<EditarPerguntaScreen> createState() => _EditarPerguntaScreenState();
}

class _EditarPerguntaScreenState extends State<EditarPerguntaScreen> {
  final PerguntaRepository _repository = PerguntaRepository();

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;

  bool _salvando = false;

  static const Color _azul = Color(0xFF1D9BF0);
  static const Color _fundoCampo = Color(0xFF16181C);
  static const Color _borda = Color(0xFF2F3336);
  static const Color _cinza = Color(0xFF71767B);

  @override
  void initState() {
    super.initState();

    _tituloController = TextEditingController(text: widget.pergunta.titulo);

    _descricaoController = TextEditingController(
      text: widget.pergunta.descricao,
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  // ============================================================
  // SALVAR
  // ============================================================

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.pergunta.id == null) {
      _mostrarMensagem('Erro: essa pergunta não possui ID.');
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final perguntaAtualizada = Pergunta(
        id: widget.pergunta.id,
        userId: widget.pergunta.userId,
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        materiaId: widget.pergunta.materiaId,
      );

      debugPrint('EDITANDO PERGUNTA ID: ${perguntaAtualizada.id}');

      debugPrint('NOVO TITULO: ${perguntaAtualizada.titulo}');

      await _repository.editar(perguntaAtualizada);

      if (!mounted) {
        return;
      }

      _mostrarMensagem('Pergunta alterada com sucesso!');

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) {
        return;
      }

      Navigator.pop(context, perguntaAtualizada);
    } catch (e) {
      debugPrint('ERRO AO EDITAR PERGUNTA: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _salvando = false;
      });

      _mostrarMensagem('Erro ao alterar pergunta: $e');
    }
  }

  // ============================================================
  // MENSAGEM
  // ============================================================

  void _mostrarMensagem(String mensagem) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), behavior: SnackBarBehavior.floating),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Editar pergunta',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _borda),
        ),
      ),

      // ========================================================
      // FORMULÁRIO
      // ========================================================
      body: Form(
        key: _formKey,

        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 30),

          children: [
            // ==================================================
            // CABEÇALHO
            // ==================================================

            const Text(
              'Editar pergunta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Altere o título ou os detalhes da sua pergunta.',
              style: TextStyle(color: _cinza, fontSize: 15, height: 1.4),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // TÍTULO
            // ==================================================
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

              textCapitalization: TextCapitalization.sentences,

              style: const TextStyle(color: Colors.white, fontSize: 16),

              cursorColor: _azul,

              maxLength: 255,

              decoration: InputDecoration(
                hintText: 'Digite o título',
                hintStyle: const TextStyle(color: _cinza),

                filled: true,
                fillColor: _fundoCampo,

                counterStyle: const TextStyle(color: _cinza),

                prefixIcon: const Icon(Icons.help_outline, color: _cinza),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),

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
                  return 'Digite o título.';
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            // ==================================================
            // DESCRIÇÃO
            // ==================================================
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

              textCapitalization: TextCapitalization.sentences,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),

              cursorColor: _azul,

              minLines: 6,
              maxLines: 10,

              decoration: InputDecoration(
                hintText: 'Explique sua dúvida...',
                hintStyle: const TextStyle(color: _cinza),

                filled: true,
                fillColor: _fundoCampo,

                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 90),
                  child: Icon(Icons.description_outlined, color: _cinza),
                ),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),

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
                  return 'Digite a descrição.';
                }

                return null;
              },
            ),

            const SizedBox(height: 28),

            // ==================================================
            // BOTÃO SALVAR
            // ==================================================
            SizedBox(
              height: 52,

              child: FilledButton.icon(
                onPressed: _salvando ? null : _salvar,

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
                    : const Icon(Icons.save_outlined, size: 20),

                label: Text(
                  _salvando ? 'Salvando...' : 'Salvar alterações',

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // AVISO
            // ==================================================
            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: _fundoCampo,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _borda),
              ),

              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: _azul, size: 20),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'As alterações serão salvas imediatamente '
                      'e a pergunta continuará disponível no feed.',
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
