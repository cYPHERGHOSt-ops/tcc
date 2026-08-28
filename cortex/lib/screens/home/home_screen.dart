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
      backgroundColor: const Color(0xFF000000),
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

  // ==========================================================
  // MAPA DOS AUTORES
  // chave = ID do usuário
  // valor = usuário
  // ==========================================================

  final Map<int, Usuario> _autores = {};

  Usuario? _usuario;

  bool _carregando = true;

  // ============================================================
  // CORES DO CORTEX
  // ============================================================

  static const Color _fundo = Color(0xFF000000);
  static const Color _fundoCard = Color(0xFF111111);
  static const Color _azul = Color(0xFF1D9BF0);
  static const Color _textoPrincipal = Color(0xFFF5F5F5);
  static const Color _textoSecundario = Color(0xFF8E8E93);
  static const Color _divisor = Color(0xFF262626);

  // ============================================================
  // INIT
  // ============================================================

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

      // Busca todos os usuários cadastrados.
      final usuarios = await _authRepository.listarUsuarios();

      // Cria o mapa:
      //
      // ID DO USUÁRIO -> USUÁRIO
      //
      // Assim podemos encontrar o verdadeiro autor
      // através do pergunta.userId.

      final autores = <int, Usuario>{};

      for (final usuario in usuarios) {
        autores[usuario.id] = usuario;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _perguntas = perguntas;

        _autores
          ..clear()
          ..addAll(autores);

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
      SnackBar(
        content: Text(
          mensagem,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF202020),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fundo,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: _fundo,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          'Cortex',
          style: TextStyle(
            color: _textoPrincipal,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),

        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: SizedBox(height: 1, child: ColoredBox(color: _divisor)),
        ),
      ),

      body: _buildBody(),

      // ========================================================
      // BOTÃO NOVA PERGUNTA
      // ========================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNovaPergunta,
        backgroundColor: _azul,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.add, size: 24),
        label: const Text(
          'Perguntar',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_usuario == null || _carregando) {
      return const Center(
        child: CircularProgressIndicator(color: _azul, strokeWidth: 2.5),
      );
    }

    if (_perguntas.isEmpty) {
      return RefreshIndicator(
        color: _azul,
        backgroundColor: _fundoCard,
        onRefresh: _carregarPerguntas,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 170),

            Icon(Icons.forum_outlined, color: _azul, size: 52),

            SizedBox(height: 20),

            Center(
              child: Text(
                'Nenhuma pergunta ainda',
                style: TextStyle(
                  color: _textoPrincipal,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 8),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Seja o primeiro a iniciar uma conversa.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _textoSecundario, fontSize: 14),
              ),
            ),

            SizedBox(height: 120),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _azul,
      backgroundColor: _fundoCard,
      onRefresh: _carregarPerguntas,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 0, bottom: 100),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _perguntas.length,
        itemBuilder: (context, index) {
          final pergunta = _perguntas[index];

          return _buildPerguntaItem(pergunta);
        },
      ),
    );
  }

  // ============================================================
  // ITEM DO FEED
  // ============================================================

  Widget _buildPerguntaItem(Pergunta pergunta) {
    // ==========================================================
    // IMPORTANTE
    //
    // NÃO usamos mais:
    //
    // usuario: _usuario
    //
    // porque isso fazia todas as perguntas aparecerem
    // como se fossem do usuário atualmente logado.
    //
    // Agora usamos o ID salvo na própria pergunta.
    // ==========================================================

    final autor = _autores[pergunta.userId];

    return Container(
      decoration: const BoxDecoration(
        color: _fundoCard,
        border: Border(bottom: BorderSide(color: _divisor, width: 0.8)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: PerguntaCard(
          pergunta: pergunta,

          // ====================================================
          // CORREÇÃO PRINCIPAL
          //
          // PerguntaCard exige "autor", não "usuario".
          // ====================================================
          autor: autor,

          onTap: () => _abrirPergunta(pergunta),
        ),
      ),
    );
  }
}
