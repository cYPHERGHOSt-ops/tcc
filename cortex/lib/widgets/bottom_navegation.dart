import 'package:flutter/material.dart';

class CortexBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CortexBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF000000),
        border: Border(top: BorderSide(color: Color(0xFF202020), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItem(
                context,
                index: 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Início',
              ),
              _buildItem(
                context,
                index: 1,
                icon: Icons.search_outlined,
                selectedIcon: Icons.search,
                label: 'Buscar',
              ),
              _buildItem(
                context,
                index: 2,
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'Conta',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final selecionado = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
            decoration: BoxDecoration(
              color: selecionado
                  ? const Color(0xFF1677FF).withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selecionado ? selectedIcon : icon,
                  size: 24,
                  color: selecionado
                      ? const Color(0xFF1677FF)
                      : const Color(0xFF8A8A8A),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
                    color: selecionado
                        ? const Color(0xFF1677FF)
                        : const Color(0xFF8A8A8A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
