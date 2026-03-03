import 'package:flutter/material.dart';
import 'package:neomama/core/utils/color_ext.dart';

class NeoIconBadge extends StatelessWidget {
  final Widget icon;
  final Color color;

  const NeoIconBadge({
    super.key,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.o(0.22),
        shape: BoxShape.circle,
      ),
      child: IconTheme(
        data: IconThemeData(size: 22, color: color.o(0.95)),
        child: icon,
      ),
    );
  }
}