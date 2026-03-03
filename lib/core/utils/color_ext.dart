import 'dart:ui';

extension NeoColorOpacity on Color {
  Color opacity(double value) {
    final a = (value.clamp(0.0, 1.0) * 255).round();
    return withAlpha(a);
  }

  
  Color o(double value) => opacity(value);
}
