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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nova pergunta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Digite sua pergunta',
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

            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Explique sua dúvida...',
                prefixIcon: Icon(Icons.description_outlined),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 5,
              maxLines: 8,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite a descrição da pergunta.';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _salvando ? null : _salvarPergunta,
                icon: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(_salvando ? 'Publicando...' : 'Publicar pergunta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
