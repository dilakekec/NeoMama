import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/config/route_names.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _splashAnimDuration = Duration(milliseconds: 6500);
  static const _splashHoldAfter = Duration(milliseconds: 1500);

  late final AnimationController _c;
  late final Animation<double> _helloDraw;
  late final Animation<double> _helloFade;
  late final Animation<double> _haloFade;
  late final Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();

    _c = AnimationController(
      vsync: this,
      duration: _splashAnimDuration,
    );

    _helloFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.55)),
    );

    _helloDraw = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0.02, 0.98)),
    );

    _haloFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.65)),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0.88, 1.0)),
    );

    _c.forward();

    
    _c.addStatusListener((s) async {
      if (s != AnimationStatus.completed) return;
      await Future<void>.delayed(_splashHoldAfter);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, RouteNames.onboarding);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return NeoBackground(
      child: Scaffold(
        body: Center(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  
                  Opacity(
                    opacity: (_haloFade.value * 0.85).clamp(0.0, 0.85),
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            cs.primary.o(0.10),
                            cs.secondary.o(0.06),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 140,
                        child: _HelloWordmark(
                          progress: _helloDraw.value,
                          opacity: _helloFade.value,
                          colorScheme: cs,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Opacity(
                        opacity: _taglineFade.value,
                        child: Text(
                          AppStrings.t(context, 'onboarding_tagline'),
                          style: t.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HelloWordmark extends StatelessWidget {
  final double progress;
  final double opacity;
  final ColorScheme colorScheme;

  const _HelloWordmark({
    required this.progress,
    required this.opacity,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.sacramento(
      fontSize: 88,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.6,
      height: 1.0,
    );

    final underlay = baseStyle.copyWith(
      color: colorScheme.onSurface.o(0.22),
    );

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF4E5266).withValues(alpha: 0.55);

    final gradient = const LinearGradient(
      colors: [
        Color(0xFFF2A0C4), // pink
        Color(0xFFD9B0F0), // lavender
        Color(0xFFA9C4EE), // soft blue
        Color(0xFF8CB5E8), // blue
      ],
      stops: [0.0, 0.35, 0.7, 1.0],
    );

    return Opacity(
      opacity: opacity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Text('NeoMama', style: underlay),
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: ShaderMask(
                  shaderCallback: (rect) => gradient.createShader(rect),
                  child: Text(
                    'NeoMama',
                    style: baseStyle.copyWith(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF3A3D4E).withValues(alpha: 0.25),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Text(
                  'NeoMama',
                  style: baseStyle.copyWith(foreground: outlinePaint),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
