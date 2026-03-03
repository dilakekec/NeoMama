import 'package:flutter/material.dart';
import 'package:neomama/core/theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  
  final List<Color> colors;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors = const [AppColors.bgTopLeft, AppColors.bgBottomRight],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
