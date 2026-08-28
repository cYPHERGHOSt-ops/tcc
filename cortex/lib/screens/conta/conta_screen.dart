import 'package:flutter/material.dart';

import '../../models/usuario.dart';
import '../../repositories/auth_repository.dart';

class ContaScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ContaScreen({super.key, required this.onLogout});

  @override
  State<ContaScreen> createState() => _ContaScreenState();
}

class _ContaScreenState extends State<ContaScreen> {
  final AuthRepository _authRepository = AuthRepository();

  Usuario? _usuario;
  bool _carregando = true;

  static const Color _azul = Color(0xFF1677FF);
  static const Color _fundo = Color(0xFF000000);
  static const Color _card = Color(0xFF111111);
  static const Color _borda = Color(0xFF242424);
  static const Color _textoSecundario = Color(0xFF8A8A8A);

  @override
  void initState() {
    super.initState();

    _carregarUsuario();
  }

  // ============================================================
  // CARREGAR USUÁRIO
  // ============================================================

  Future<void> _carregarUsuario() async {
    try {
      final usuario = await _authRepository.usuarioLogado();

      if (!mounted) {
        return;
      }

      setState(() {
        _usuario = usuario;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _carregando = false;
      });
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Sair da conta',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Tem certeza que deseja sair da sua conta?',
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
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(backgroundColor: _azul),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    await _authRepository.logout();

    if (!mounted) {
      return;
    }

    widget.onLogout();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        backgroundColor: _fundo,
        body: Center(child: CircularProgressIndicator(color: _azul)),
      );
    }

    if (_usuario == null) {
      return const Scaffold(
        backgroundColor: _fundo,
        body: Center(
          child: Text(
            'Nenhum usuário conectado.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _fundo,
      appBar: AppBar(
        backgroundColor: _fundo,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Minha conta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        children: [
          _buildCabecalho(),

          const SizedBox(height: 28),

          _buildInformacoes(),

          const SizedBox(height: 16),

          _buildPerguntasSalvas(),

          const SizedBox(height: 28),

          _buildLogoutButton(),
        ],
      ),
    );
  }

  // ============================================================
  // CABEÇALHO
  // ============================================================

  Widget _buildCabecalho() {
    final nome = _usuario!.nome;

    final inicial = nome.isNotEmpty ? nome.substring(0, 1).toUpperCase() : '?';

    return Column(
      children: [
        // AVATAR
        Container(
          width: 94,
          height: 94,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _azul.withOpacity(0.12),
            border: Border.all(color: _azul.withOpacity(0.35), width: 2),
          ),
          child: Center(
            child: Text(
              inicial,
              style: const TextStyle(
                color: _azul,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // NOME
        Text(
          _usuario!.nome,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        // USUÁRIO
        Text(
          '@${_usuario!.email.split('@').first}',
          style: const TextStyle(color: _textoSecundario, fontSize: 14),
        ),

        const SizedBox(height: 16),

        // EDITAR
        OutlinedButton.icon(
          onPressed: () {
            // Implementaremos a edição do perfil depois.
          },
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Editar perfil'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: _borda),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFORMAÇÕES
  // ============================================================

  Widget _buildInformacoes() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          _buildInfoItem(
            icon: Icons.person_outline,
            titulo: 'Nome',
            valor: _usuario!.nome,
          ),

          const SizedBox(height: 18),

          _buildInfoItem(
            icon: Icons.email_outlined,
            titulo: 'E-mail',
            valor: _usuario!.email,
          ),

          if (_usuario!.bio != null && _usuario!.bio!.trim().isNotEmpty) ...[
            const SizedBox(height: 18),

            _buildInfoItem(
              icon: Icons.description_outlined,
              titulo: 'Bio',
              valor: _usuario!.bio!,
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // ITEM DE INFORMAÇÃO
  // ============================================================

  Widget _buildInfoItem({
    required IconData icon,
    required String titulo,
    required String valor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _azul.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _azul, size: 21),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(color: _textoSecundario, fontSize: 12),
              ),

              const SizedBox(height: 4),

              Text(
                valor,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PERGUNTAS SALVAS
  // ============================================================

  Widget _buildPerguntasSalvas() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Tela de perguntas salvas será implementada aqui.
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _borda),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _azul.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.bookmark_outline,
                  color: _azul,
                  size: 24,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perguntas salvas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Veja as perguntas que você salvou.',
                      style: TextStyle(color: _textoSecundario, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: _textoSecundario),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: _logout,
      icon: const Icon(Icons.logout, size: 19),
      label: const Text('Sair da conta'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFFF5C5C),
        side: BorderSide(color: const Color(0xFFFF5C5C).withOpacity(0.35)),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
