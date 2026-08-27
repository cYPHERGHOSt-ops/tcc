import 'package:flutter/material.dart';

import '../../repositories/auth_repository.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final AuthRepository _repository = AuthRepository();

  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _carregando = false;
  bool _mostrarSenha = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();

    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _carregando = true;
    });

    final sucesso = await _repository.cadastrar(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      senha: _senhaController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _carregando = false;
    });

    if (!sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este e-mail já está cadastrado.')),
      );

      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Crie sua conta no Cortex',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Digite seu nome.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Digite seu e-mail.';
                        }

                        if (!value.contains('@')) {
                          return 'Digite um e-mail válido.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _senhaController,
                      obscureText: !_mostrarSenha,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _mostrarSenha = !_mostrarSenha;
                            });
                          },
                          icon: Icon(
                            _mostrarSenha
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite uma senha.';
                        }

                        if (value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: _carregando ? null : _cadastrar,
                        child: _carregando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Criar conta'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
