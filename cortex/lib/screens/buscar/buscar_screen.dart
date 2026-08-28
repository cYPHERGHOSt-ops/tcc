import 'package:flutter/material.dart';

import '../../models/pergunta.dart';
import '../../models/usuario.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/pergunta_repository.dart';
import '../../widgets/pergunta_card.dart';
import '../perguntas/pergunta_detalhes_screen.dart';

class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
  final PerguntaRepository _repository = PerguntaRepository();
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController _buscarController = TextEditingController();

  List<Pergunta> _perguntas = [];
  List<Pergunta> _resultados = [];

  Usuario? _usuario;

  bool _carregando = true;

  static const Color _azul = Color(0xFF1677FF);
  static const Color _fundo = Color(0xFF000000);
  static const Color _card = Color(0xFF111111);
  static const Color _borda = Color(0xFF242424);

  @override
  void initState() {
    super.initState();

    _buscarController.addListener(_filtrarPerguntas);

    _inicializar();
  }

  @override
  void dispose() {
    _buscarController.removeListener(_filtrarPerguntas);
    _buscarController.dispose();

    super.dispose();
  }

  // ============================================================
  // INICIALIZAR
  // ============================================================

  Future<void> _inicializar() async {
    try {
      final usuario = await _authRepository.usuarioLogado();
      final perguntas = await _repository.listar();

      if (!mounted) {
        return;
      }

      setState(() {
        _usuario = usuario;
        _perguntas = perguntas;
        _resultados = perguntas;
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
  // CARREGAR NOVAMENTE
  // ============================================================

  Future<void> _carregarPerguntas() async {
    try {
      final perguntas = await _repository.listar();

      if (!mounted) {
        return;
      }

      setState(() {
        _perguntas = perguntas;
      });

      _filtrarPerguntas();
    } catch (e) {
      if (!mounted) {
        return;
      }

      _mostrarMensagem('Não foi possível atualizar as perguntas.');
    }
  }

  // ============================================================
  // FILTRAR
  // ============================================================

  void _filtrarPerguntas() {
    final texto = _buscarController.text.trim().toLowerCase();

    if (texto.isEmpty) {
      if (mounted) {
        setState(() {
          _resultados = List<Pergunta>.from(_perguntas);
        });
      }

      return;
    }

    final resultados = _perguntas.where((pergunta) {
      final titulo = pergunta.titulo.toLowerCase();
      final descricao = pergunta.descricao.toLowerCase();

      return titulo.contains(texto) || descricao.contains(texto);
    }).toList();

    if (!mounted) {
      return;
    }

    setState(() {
      _resultados = resultados;
    });
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

    // Se a pergunta foi excluída.
    if (resultado == true) {
      await _carregarPerguntas();
      return;
    }

    // Se a pergunta foi editada.
    if (resultado is Pergunta) {
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
        content: Text(mensagem),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF222222),
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
      appBar: AppBar(
        backgroundColor: _fundo,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Buscar',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator(color: _azul));
    }

    return RefreshIndicator(
      color: _azul,
      backgroundColor: _card,
      onRefresh: _carregarPerguntas,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 30),
        children: [
          _buildCampoBusca(),

          const SizedBox(height: 20),

          _buildTituloResultados(),

          const SizedBox(height: 10),

          _buildResultados(),
        ],
      ),
    );
  }

  // ============================================================
  // CAMPO DE BUSCA
  // ============================================================

  Widget _buildCampoBusca() {
    return TextField(
      controller: _buscarController,
      autofocus: false,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: _azul,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar perguntas...',
        hintStyle: const TextStyle(color: Color(0xFF777777)),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF888888)),
        suffixIcon: _buscarController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _buscarController.clear();
                },
                icon: const Icon(Icons.close, color: Color(0xFF888888)),
              )
            : null,
        filled: true,
        fillColor: _card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _borda),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _azul, width: 1.5),
        ),
      ),
    );
  }

  // ============================================================
  // TÍTULO
  // ============================================================

  Widget _buildTituloResultados() {
    final buscando = _buscarController.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          const Icon(Icons.forum_outlined, size: 20, color: _azul),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              buscando ? 'Resultados' : 'Perguntas recentes',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (_resultados.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: _azul.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_resultados.length}',
                style: const TextStyle(
                  color: _azul,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // RESULTADOS
  // ============================================================

  Widget _buildResultados() {
    if (_resultados.isEmpty) {
      return _buildSemResultados();
    }

    return Column(
      children: _resultados.map((pergunta) {
        return PerguntaCard(
          pergunta: pergunta,
          usuario: _usuario,
          onTap: () => _abrirPergunta(pergunta),
        );
      }).toList(),
    );
  }

  // ============================================================
  // SEM RESULTADOS
  // ============================================================

  Widget _buildSemResultados() {
    final buscando = _buscarController.text.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borda),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 46, color: Color(0xFF666666)),

          const SizedBox(height: 14),

          Text(
            buscando ? 'Nenhuma pergunta encontrada' : 'Nenhuma pergunta ainda',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            buscando
                ? 'Tente buscar por outro termo.'
                : 'As perguntas publicadas aparecerão aqui.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
