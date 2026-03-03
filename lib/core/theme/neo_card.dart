import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'package:neomama/core/utils/color_ext.dart';

class NeoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const NeoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = BorderRadius.circular(AppTheme.radiusXL);

    return Material(
      color: cs.surface,
      elevation: 0,
      borderRadius: r,
      clipBehavior: Clip.antiAlias, 
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: r,
          border: Border.all(color: cs.outlineVariant.o(isDark ? 0.35 : 0.22), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.o(isDark ? 0.30 : 0.06),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
