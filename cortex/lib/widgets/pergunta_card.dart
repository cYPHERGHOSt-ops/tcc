import 'package:flutter/material.dart';

import '../models/pergunta.dart';
import '../models/usuario.dart';

class PerguntaCard extends StatelessWidget {
  final Pergunta pergunta;
  final Usuario? autor;
  final VoidCallback onTap;

  const PerguntaCard({
    super.key,
    required this.pergunta,
    required this.autor,
    required this.onTap,
  });

  // ============================================================
  // CORES
  // ============================================================

  static const Color _fundo = Color(0xFF111111);

  static const Color _azul = Color(0xFF1D9BF0);

  static const Color _textoPrincipal = Color(0xFFF5F5F5);

  static const Color _textoSecundario = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    final nomeUsuario = autor?.nome ?? 'Usuário';

    return Material(
      color: _fundo,

      child: InkWell(
        onTap: onTap,

        splashColor: _azul.withOpacity(0.08),
        highlightColor: Colors.white.withOpacity(0.02),

        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // USUÁRIO
              // ==================================================

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ==================================================
                  // AVATAR
                  // ==================================================

                  _buildAvatar(),

                  const SizedBox(width: 11),

                  // ==================================================
                  // NOME
                  // ==================================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nomeUsuario,

                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: _textoPrincipal,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          '@${_gerarUsername(nomeUsuario)}',

                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: _textoSecundario,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // MENU
                  // ==================================================
                  IconButton(
                    onPressed: () {},

                    splashRadius: 20,

                    icon: const Icon(
                      Icons.more_horiz,
                      color: _textoSecundario,
                      size: 21,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ==================================================
              // TÍTULO
              // ==================================================
              Text(
                pergunta.titulo,

                style: const TextStyle(
                  color: _textoPrincipal,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(height: 8),

              // ==================================================
              // DESCRIÇÃO
              // ==================================================
              Text(
                pergunta.descricao,

                maxLines: 4,
                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  color: Color(0xFFD0D0D0),
                  fontSize: 15,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 14),

              // ==================================================
              // AÇÕES
              // ==================================================
              Row(
                children: [
                  _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Responder',
                    onTap: onTap,
                  ),

                  const SizedBox(width: 20),

                  _ActionButton(
                    icon: Icons.ios_share_outlined,
                    label: 'Compartilhar',
                    onTap: () {},
                  ),

                  const Spacer(),

                  const Icon(
                    Icons.chevron_right,
                    color: _textoSecundario,
                    size: 21,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _buildAvatar() {
    final foto = autor?.foto;

    // Se futuramente existir uma foto cadastrada
    if (foto != null && foto.trim().isNotEmpty) {
      return CircleAvatar(
        radius: 21,
        backgroundImage: NetworkImage(foto),
        backgroundColor: _azul.withOpacity(0.12),
      );
    }

    // Avatar padrão
    return Container(
      width: 42,
      height: 42,

      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _azul.withOpacity(0.12),
      ),

      child: const Icon(Icons.person_outline, color: _azul, size: 23),
    );
  }

  // ============================================================
  // USERNAME
  // ============================================================

  String _gerarUsername(String nome) {
    final username = nome.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');

    return username.isEmpty ? 'usuario' : username;
  }
}

// ============================================================
// BOTÃO DE AÇÃO
// ============================================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(20),

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF8E8E93)),

            const SizedBox(width: 6),

            Text(
              label,

              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
