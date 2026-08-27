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
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  final PerguntaRepository _repository = PerguntaRepository();

  bool _salvando = false;

  @override
  void initState() {
    super.initState();

    _tituloController.text = widget.pergunta.titulo;
    _descricaoController.text = widget.pergunta.descricao;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();

    super.dispose();
  }

  // ============================================================
  // SALVAR ALTERAÇÕES
  // ============================================================

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.pergunta.id == null) {
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final perguntaAtualizada = Pergunta(
        id: widget.pergunta.id,

        // IMPORTANTE:
        // mantém o dono original da pergunta.
        userId: widget.pergunta.userId,

        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),

        // Mantém a matéria caso exista.
        materiaId: widget.pergunta.materiaId,
      );

      await _repository.editar(perguntaAtualizada);

      if (!mounted) {
        return;
      }

      Navigator.pop(context, perguntaAtualizada);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _salvando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar as alterações.')),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

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
            // ====================================================
            // TÍTULO
            // ====================================================

            TextFormField(
              controller: _tituloController,

              textCapitalization: TextCapitalization.sentences,

              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Digite o título da pergunta',
                prefixIcon: Icon(Icons.title_outlined),
                border: OutlineInputBorder(),
              ),

              maxLength: 255,

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite o título da pergunta.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // ====================================================
            // DESCRIÇÃO
            // ====================================================
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
                  return 'Digite a descrição da pergunta.';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            // ====================================================
            // BOTÃO SALVAR
            // ====================================================
            SizedBox(
              height: 50,

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
