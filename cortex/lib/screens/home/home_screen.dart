import 'package:flutter/material.dart';

import 'package:cortex/widgets/bottom_navegation.dart';

import '../buscar/buscar_screen.dart';
import '../conta/conta_screen.dart';
import '../perguntas/nova_pergunta_screen.dart';
import '../perguntas/pergunta_detalhes_screen.dart';

import '../../models/pergunta.dart';
import '../../models/usuario.dart';

import '../../repositories/auth_repository.dart';
import '../../repositories/pergunta_repository.dart';

import '../../widgets/pergunta_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const FeedContent(),
      const BuscarScreen(),
      ContaScreen(onLogout: widget.onLogout),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: CortexBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
      ),
    );
  }
}

// ============================================================
// FEED
// ============================================================

class FeedContent extends StatefulWidget {
  const FeedContent({super.key});

  @override
  State<FeedContent> createState() => _FeedContentState();
}

class _FeedContentState extends State<FeedContent> {
  final PerguntaRepository _repository = PerguntaRepository();
  final AuthRepository _authRepository = AuthRepository();

  List<Pergunta> _perguntas = [];
  Usuario? _usuario;

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  // ============================================================
  // INICIALIZAR
  // ============================================================

  Future<void> _inicializar() async {
    try {
      final usuario = await _authRepository.usuarioLogado();

      if (!mounted) {
        return;
      }

      setState(() {
        _usuario = usuario;
      });

      await _carregarPerguntas();
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _carregando = false;
      });

      _mostrarMensagem('Não foi possível inicializar o feed.');
    }
  }

  // ============================================================
  // CARREGAR PERGUNTAS
  // ============================================================

  Future<void> _carregarPerguntas() async {
    try {
      final perguntas = await _repository.listar();

      if (!mounted) {
        return;
      }

      setState(() {
        _perguntas = perguntas;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _carregando = false;
      });

      _mostrarMensagem('Não foi possível carregar as perguntas.');
    }
  }

  // ============================================================
  // NOVA PERGUNTA
  // ============================================================

  Future<void> _abrirNovaPergunta() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const NovaPerguntaScreen();
        },
      ),
    );

    if (!mounted) {
      return;
    }

    if (resultado == true) {
      await _carregarPerguntas();
    }
  }

  // ============================================================
  // ABRIR PERGUNTA
  // ============================================================

  Future<void> _abrirPergunta(Pergunta pergunta) async {
    if (_usuario == null) {
      _mostrarMensagem('Nenhum usuário está logado.');
      return;
    }

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PerguntaDetalhesScreen(
            pergunta: pergunta,
            usuarioAtualId: _usuario!.id,
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    // ==========================================================
    // PERGUNTA EXCLUÍDA
    // ==========================================================

    if (resultado == true) {
      await _carregarPerguntas();
      return;
    }

    // ==========================================================
    // PERGUNTA EDITADA
    // ==========================================================

    if (resultado is Pergunta) {
      setState(() {
        final index = _perguntas.indexWhere((item) => item.id == resultado.id);

        if (index != -1) {
          _perguntas[index] = resultado;
        }
      });

      // Recarrega do SharedPreferences para garantir
      // que a interface esteja sincronizada com os dados salvos.
      await _carregarPerguntas();
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
      appBar: AppBar(
        title: const Text(
          'Cortex',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirNovaPergunta,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_usuario == null || _carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_perguntas.isEmpty) {
      return RefreshIndicator(
        onRefresh: _carregarPerguntas,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 250),
            Center(
              child: Text(
                'Nenhuma pergunta ainda.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarPerguntas,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _perguntas.length,
        itemBuilder: (context, index) {
          final pergunta = _perguntas[index];

          return PerguntaCard(
            pergunta: pergunta,
            onTap: () => _abrirPergunta(pergunta),
          );
        },
      ),
    );
  }
}
