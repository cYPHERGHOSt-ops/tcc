import 'package:flutter/material.dart';

import '../models/pergunta.dart';

class PerguntaCard extends StatelessWidget {
  final Pergunta pergunta;
  final VoidCallback onTap;

  const PerguntaCard({super.key, required this.pergunta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pergunta.titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pergunta.descricao,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 18),
                  SizedBox(width: 6),
                  Text('Responder'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
