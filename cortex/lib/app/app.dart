import 'package:flutter/material.dart';

import '../repositories/auth_repository.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';

class CortexApp extends StatefulWidget {
  const CortexApp({super.key});

  @override
  State<CortexApp> createState() => _CortexAppState();
}

class _CortexAppState extends State<CortexApp> {
  final AuthRepository _authRepository = AuthRepository();

  bool _carregando = true;
  bool _logado = false;

  @override
  void initState() {
    super.initState();

    _verificarSessao();
  }

  Future<void> _verificarSessao() async {
    final usuario = await _authRepository.usuarioLogado();

    if (!mounted) {
      return;
    }

    setState(() {
      _logado = usuario != null;
      _carregando = false;
    });
  }

  void _entrou() {
    setState(() {
      _logado = true;
    });
  }

  void _saiu() {
    setState(() {
      _logado = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cortex',
      theme: ThemeData(useMaterial3: true),
      home: _carregando
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _logado
          ? HomeScreen(onLogout: _saiu)
          : LoginScreen(onLogin: _entrou),
    );
  }
}
