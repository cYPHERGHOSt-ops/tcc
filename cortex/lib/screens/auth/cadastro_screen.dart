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

  static const Color _fundo = Color(0xFF000000);
  static const Color _card = Color(0xFF16181C);
  static const Color _campo = Color(0xFF0D0F12);
  static const Color _borda = Color(0xFF2F3336);
  static const Color _azul = Color(0xFF1D9BF0);

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();

    super.dispose();
  }

  // ============================================================
  // CADASTRAR
  // ============================================================

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
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
          SnackBar(
            content: const Text('Este e-mail já está cadastrado.'),
            backgroundColor: _card,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Não foi possível criar sua conta.'),
          backgroundColor: _card,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
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
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Criar conta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ==================================================
                    // LOGO
                    // ==================================================

                    const Center(
                      child: Text(
                        'Cortex',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Faça parte da comunidade.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF71767B), fontSize: 15),
                    ),

                    const SizedBox(height: 36),

                    // ==================================================
                    // CARD
                    // ==================================================
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _borda),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Criar sua conta',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            'Preencha os dados abaixo para começar.',
                            style: TextStyle(
                              color: Color(0xFF71767B),
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // ==================================================
                          // NOME
                          // ==================================================
                          TextFormField(
                            controller: _nomeController,
                            textCapitalization: TextCapitalization.words,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              label: 'Nome',
                              hint: 'Como devemos chamar você?',
                              icon: Icons.person_outline,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Digite seu nome.';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // ==================================================
                          // E-MAIL
                          // ==================================================
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              label: 'E-mail',
                              hint: 'Digite seu e-mail',
                              icon: Icons.email_outlined,
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

                          // ==================================================
                          // SENHA
                          // ==================================================
                          TextFormField(
                            controller: _senhaController,
                            obscureText: !_mostrarSenha,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              label: 'Senha',
                              hint: 'Crie uma senha',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _mostrarSenha = !_mostrarSenha;
                                  });
                                },
                                icon: Icon(
                                  _mostrarSenha
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF71767B),
                                ),
                              ),
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

                          const SizedBox(height: 10),

                          const Text(
                            'A senha deve ter pelo menos 6 caracteres.',
                            style: TextStyle(
                              color: Color(0xFF71767B),
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // BOTÃO
                          // ==================================================
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: _carregando ? null : _cadastrar,
                              style: FilledButton.styleFrom(
                                backgroundColor: _azul,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: _azul.withOpacity(
                                  0.45,
                                ),
                                disabledForegroundColor: Colors.white70,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _carregando
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Criar conta',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // VOLTAR PARA LOGIN
                    // ==================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Já possui uma conta?',
                          style: TextStyle(
                            color: Color(0xFF71767B),
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(foregroundColor: _azul),
                          child: const Text(
                            'Entrar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

      prefixIcon: Icon(icon, color: const Color(0xFF71767B)),

      suffixIcon: suffix,

      labelStyle: const TextStyle(color: Color(0xFF71767B)),

      hintStyle: const TextStyle(color: Color(0xFF536069)),

      filled: true,
      fillColor: _campo,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),

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
        borderSide: const BorderSide(color: _azul, width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),

      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}
