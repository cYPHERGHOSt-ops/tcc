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

  @override
  void initState() {
    super.initState();

    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final usuario = await _authRepository.usuarioLogado();

    if (!mounted) {
      return;
    }

    setState(() {
      _usuario = usuario;
      _carregando = false;
    });
  }

  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sair da conta'),
          content: const Text('Tem certeza que deseja sair da sua conta?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
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

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_usuario == null) {
      return const Scaffold(
        body: Center(child: Text('Nenhum usuário conectado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minha conta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCabecalho(),

          const SizedBox(height: 24),

          _buildInformacoes(),

          const SizedBox(height: 28),

          _buildPerguntasSalvas(),

          const SizedBox(height: 28),

          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildCabecalho() {
    final nome = _usuario!.nome;

    final inicial = nome.isNotEmpty ? nome.substring(0, 1).toUpperCase() : '?';

    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          child: Text(
            inicial,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          _usuario!.nome,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),

        Text(
          '@${_usuario!.email.split('@').first}',
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 16),

        OutlinedButton.icon(
          onPressed: () {
            // Vamos implementar a edição do perfil depois.
          },
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Editar perfil'),
        ),
      ],
    );
  }

  Widget _buildInformacoes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 18),

            _buildInfoItem(
              icon: Icons.person_outline,
              titulo: 'Nome',
              valor: _usuario!.nome,
            ),

            const SizedBox(height: 16),

            _buildInfoItem(
              icon: Icons.email_outlined,
              titulo: 'E-mail',
              valor: _usuario!.email,
            ),

            if (_usuario!.bio != null && _usuario!.bio!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),

              _buildInfoItem(
                icon: Icons.description_outlined,
                titulo: 'Bio',
                valor: _usuario!.bio!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String titulo,
    required String valor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 2),

              Text(valor, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerguntasSalvas() {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Vamos criar essa tela depois.
        },
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(Icons.bookmark_outline, size: 28),

              SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perguntas salvas',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text('Veja as perguntas que você salvou.'),
                  ],
                ),
              ),

              Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: _logout,
      icon: const Icon(Icons.logout),
      label: const Text('Sair da conta'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}
