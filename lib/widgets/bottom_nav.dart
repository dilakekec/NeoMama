import 'package:flutter/material.dart';
import 'package:neomama/core/utils/color_ext.dart';

class BottomNavItem {
  final IconData icon;
  final String label;

  const BottomNavItem({required this.icon, required this.label});
}

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;
  final bool showLabels;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: cs.surface.o(0.96),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: cs.outlineVariant.o(0.35)),
            boxShadow: [
              BoxShadow(
                blurRadius: 28,
                offset: const Offset(0, 10),
                color: cs.primary.o(0.12),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              return _item(
                context,
                icon: item.icon,
                label: item.label,
                onTap: () => onTap(i),
                isActive: currentIndex == i,
                showLabel: showLabels,
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
    required bool showLabel,
  }) {
    final cs = Theme.of(context).colorScheme;
    final activeColor = cs.primary;
    final inactiveColor = cs.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive ? cs.primary.o(0.16) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
              if (showLabel) ...[
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
