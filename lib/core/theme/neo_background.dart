import 'package:flutter/material.dart';
import 'app_colors.dart';

class NeoBackground extends StatelessWidget {
  final Widget child;
  final bool withSafeArea;

  const NeoBackground({
    super.key,
    required this.child,
    this.withSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget content = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF0F131B),
                  Color(0xFF141A26),
                  Color(0xFF1B2433),
                ]
              : const [
                  AppColors.bgTopLeft,
                  AppColors.bgTopRight,
                  AppColors.bgBottomRight,
                ],
        ),
      ),
      child: child,
    );

    if (withSafeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }
}
