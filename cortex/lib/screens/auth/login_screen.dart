import 'package:flutter/material.dart';

import '../../repositories/auth_repository.dart';
import 'cadastro_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLogin;

  const LoginScreen({super.key, this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthRepository _repository = AuthRepository();

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _carregando = false;
  bool _mostrarSenha = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();

    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _carregando = true;
    });

    final usuario = await _repository.login(
      email: _emailController.text.trim(),
      senha: _senhaController.text,
    );

    if (!mounted) {
      return;
    }

    if (usuario == null) {
      setState(() {
        _carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail ou senha incorretos.')),
      );

      return;
    }

    widget.onLogin?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    const Icon(Icons.psychology_outlined, size: 70),

                    const SizedBox(height: 16),

                    const Text(
                      'Cortex',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Entre na sua conta',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

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
                          return 'Digite sua senha.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: _carregando ? null : _entrar,
                        child: _carregando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Entrar'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const CadastroScreen();
                            },
                          ),
                        );
                      },
                      child: const Text('Ainda não tenho uma conta'),
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
