import 'package:flutter/material.dart';

class BuscarScreen extends StatelessWidget {
  const BuscarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: const Center(
        child: Text(
          'Buscar perguntas',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
