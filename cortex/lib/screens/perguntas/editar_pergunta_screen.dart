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

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar pergunta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Form(
        key: _formKey,

        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [
            // ==================================================
            // TÍTULO
            // ==================================================

            TextFormField(
              controller: _tituloController,

              textCapitalization: TextCapitalization.sentences,

              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Digite o título',
                prefixIcon: Icon(Icons.title_outlined),
                border: OutlineInputBorder(),
              ),

              maxLength: 255,

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite o título.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // ==================================================
            // DESCRIÇÃO
            // ==================================================
            TextFormField(
              controller: _descricaoController,

              textCapitalization: TextCapitalization.sentences,

              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Explique sua dúvida...',
                prefixIcon: Icon(Icons.description_outlined),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),

              minLines: 5,
              maxLines: 10,

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite a descrição.';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            // ==================================================
            // BOTÃO
            // ==================================================
            SizedBox(
              height: 52,

              child: FilledButton.icon(
                onPressed: _salvando ? null : _salvar,

                icon: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),

                label: Text(_salvando ? 'Salvando...' : 'Salvar alterações'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
