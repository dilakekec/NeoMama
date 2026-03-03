import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:neomama/core/theme/app_colors.dart';
import 'package:neomama/l10n/app_strings.dart';

import '../models/teething_models.dart';

class ToothMap extends StatelessWidget {
  final List<ToothInfo> teeth;
  final Map<String, ToothState> stateById;
  final void Function(ToothInfo tooth, ToothState current) onToothTap;

  const ToothMap({
    super.key,
    required this.teeth,
    required this.stateById,
    required this.onToothTap,
  });

  static const ToothState _emptyState = ToothState(erupted: false);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;

        return Container(
          decoration: BoxDecoration(
            color: _a(Colors.white, 0.78),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _a(Colors.black, 0.05)),
            boxShadow: [
              BoxShadow(
                blurRadius: 22,
                offset: const Offset(0, 12),
                color: _a(Colors.black, 0.08),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: _PremiumMouthPainter()),
              ),

              
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.1),
                        radius: 1.1,
                        colors: [
                          Colors.transparent,
                          _a(cs.onSurface, 0.06),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              for (final t in teeth)
                _DotPositioned(
                  tooth: t,
                  w: w,
                  h: h,
                  state: stateById[t.id] ?? _emptyState,
                  onTap: (s) => onToothTap(t, s),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DotPositioned extends StatelessWidget {
  final ToothInfo tooth;
  final double w;
  final double h;
  final ToothState state;
  final void Function(ToothState current) onTap;

  const _DotPositioned({
    required this.tooth,
    required this.w,
    required this.h,
    required this.state,
    required this.onTap,
  });

  static const double _tapBox = 44.0;

  @override
  Widget build(BuildContext context) {
    final left = (tooth.x * w - _tapBox / 2).clamp(0.0, w - _tapBox);
    final top = (tooth.y * h - _tapBox / 2).clamp(0.0, h - _tapBox);

    final hasNote = (state.note ?? '').trim().isNotEmpty;
    final hasDate = (state.dateIso ?? '').trim().isNotEmpty;

    return Positioned(
      left: left,
      top: top,
      child: _ToothDot(
        erupted: state.erupted,
        hasNote: hasNote,
        hasDate: hasDate,
        pulse: state.erupted,
        onTap: () => onTap(state),
      ),
    );
  }
}

class _ToothDot extends StatefulWidget {
  final bool erupted;
  final bool hasNote;
  final bool hasDate;
  final bool pulse;
  final VoidCallback onTap;

  const _ToothDot({
    required this.erupted,
    required this.hasNote,
    required this.hasDate,
    required this.pulse,
    required this.onTap,
  });

  @override
  State<_ToothDot> createState() => _ToothDotState();
}

class _ToothDotState extends State<_ToothDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.pulse) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _ToothDot oldWidget) {
    super.didUpdateWidget(oldWidget);

    
    if (oldWidget.pulse != widget.pulse) {
      if (widget.pulse) {
        _c
          ..reset()
          ..repeat(reverse: true);
      } else {
        _c.stop();
        _c.reset();
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = widget.erupted ? AppColors.secondary : AppColors.primary;
    final fill = widget.erupted ? AppColors.secondary : Colors.white;

    return Semantics(
      button: true,
      label: widget.erupted
          ? AppStrings.t(context, 'tooth_marked')
          : AppStrings.t(context, 'tooth_unmarked'),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Material(
          color: Colors.transparent,
          child: InkResponse(
            onTap: widget.onTap,
            radius: 26,
            containedInkWell: true,
            highlightShape: BoxShape.circle,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final t = _c.value;
                final glow = widget.pulse ? (0.18 + 0.10 * t) : 0.0;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.pulse)
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _a(border, glow),
                        ),
                      ),

                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _a(fill, 0.92),
                        border: Border.all(color: border, width: 2),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                            color: _a(Colors.black, 0.10),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.erupted
                            ? Icons.check_rounded
                            : Icons.circle_outlined,
                        size: 18,
                        color: widget.erupted ? Colors.white : border,
                      ),
                    ),

                    if (widget.hasDate || widget.hasNote)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: _MetaPill(
                          hasDate: widget.hasDate,
                          hasNote: widget.hasNote,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final bool hasDate;
  final bool hasNote;

  const _MetaPill({
    required this.hasDate,
    required this.hasNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _a(Colors.black, 0.06)),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 6),
            color: _a(Colors.black, 0.08),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDate)
            const Icon(Icons.event_available_outlined, size: 12),
          if (hasDate && hasNote) const SizedBox(width: 4),
          if (hasNote) const Icon(Icons.sticky_note_2_outlined, size: 12),
        ],
      ),
    );
  }
}

class _PremiumMouthPainter extends CustomPainter {
  const _PremiumMouthPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(14, 14, size.width - 28, size.height - 28),
      const Radius.circular(28),
    );

    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _a(AppColors.warm, 0.35),
          _a(AppColors.secondary, 0.32),
        ],
      ).createShader(r.outerRect);
    canvas.drawRRect(r, bg);

    final upperRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(24, 34, size.width - 48, size.height * 0.34),
      const Radius.circular(999),
    );
    final upper = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _a(AppColors.warm, 0.85),
          _a(AppColors.warm, 0.55),
        ],
      ).createShader(upperRect.outerRect);
    canvas.drawRRect(upperRect, upper);

    final lowerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        24,
        size.height * 0.58,
        size.width - 48,
        size.height * 0.34,
      ),
      const Radius.circular(999),
    );
    final lower = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _a(AppColors.secondary, 0.65),
          _a(AppColors.surface, 0.75),
        ],
      ).createShader(lowerRect.outerRect);
    canvas.drawRRect(lowerRect, lower);

    final linePaint = Paint()
      ..color = _a(AppColors.inkSoft, 0.10)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(44, size.height * 0.505),
      Offset(size.width - 44, size.height * 0.505),
      linePaint,
    );

    final sparkle = Paint()
      ..color = _a(Colors.white, 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      final cx = size.width * (0.28 + 0.22 * i);
      final cy = size.height * 0.18;
      final rr = 14.0 + i * 6;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: rr),
        -math.pi / 3,
        math.pi / 2.2,
        false,
        sparkle,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Color _a(Color c, double opacity01) {
  final a = (opacity01 * 255).clamp(0, 255).round();
  return c.withAlpha(a);
}
