import 'dart:ui';
import 'package:flutter/material.dart';

import '../teething_service.dart';
import '../models/teething_models.dart';
import '../utils/teething_info.dart';
import 'package:neomama/core/theme/app_colors.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class TeethingCard extends StatefulWidget {
  final String babyKey;
  final VoidCallback onTap;

  const TeethingCard({
    super.key,
    required this.babyKey,
    required this.onTap,
  });

  @override
  State<TeethingCard> createState() => _TeethingCardState();
}

class _TeethingCardState extends State<TeethingCard> {
  final _svc = TeethingService();

  Map<String, ToothState> _state = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant TeethingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.babyKey != widget.babyKey) _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _svc.load(widget.babyKey);
      if (!mounted) return;
      setState(() {
        _state = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final code = Localizations.localeOf(context).languageCode;
    final info = computeTeethingInfo(_state, localeCode: code);

    final total = info.total; 
    final erupted = info.eruptedCount;
    final pct = info.progress.clamp(0.0, 1.0);

    final accent = _accentFor(info.status, cs);

    final subtitle = _loading
        ? AppStrings.t(context, 'loading')
        : (_error != null ? AppStrings.t(context, 'teething_load_error') : info.label);

    final surface = Colors.white.o(0.78);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _IconBox(
                    pct: pct,
                    loading: _loading,
                    status: info.status,
                    hasError: _error != null,
                    accent: accent,
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.t(context, 'teething'),
                          style: t.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ) ??
                              const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14.5,
                              ),
                        ),
                        const SizedBox(height: 8),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: _loading ? null : pct,
                            minHeight: 9,
                            backgroundColor: Colors.black.o(0.06),
                            valueColor:
                                _loading ? null : AlwaysStoppedAnimation(accent),
                          ),
                        ),
                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Text(
                              AppStrings.t(
                                context,
                                'teething_marked_count',
                                vars: {'erupted': '$erupted', 'total': '$total'},
                              ),
                              style: t.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ) ??
                                  const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6D6C83),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: _loading ? null : _load,
                              tooltip: AppStrings.t(context, 'refresh'),
                              icon: Icon(
                                Icons.refresh_rounded,
                                size: 18,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),

                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodySmall?.copyWith(
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                                color: _error != null
                                    ? cs.error.o(0.85)
                                    : Colors.black.o(0.55),
                              ) ??
                              TextStyle(
                                fontSize: 12,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                                color: _error != null
                                    ? cs.error.o(0.85)
                                    : Colors.black.o(0.55),
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 26,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _accentFor(TeethingStatus status, ColorScheme cs) {
    switch (status) {
      case TeethingStatus.recent:
        return AppColors.primary;
      case TeethingStatus.active:
        return AppColors.secondary;
      case TeethingStatus.calm:
        return cs.onSurfaceVariant; 
      case TeethingStatus.empty:
        return AppColors.primary;
    }
  }
}

class _IconBox extends StatelessWidget {
  final double pct;
  final bool loading;
  final TeethingStatus status;
  final bool hasError;
  final Color accent;

  const _IconBox({
    required this.pct,
    required this.loading,
    required this.status,
    required this.hasError,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final done = pct >= 1.0;

    List<Color> gradientColors() {
      if (hasError) return [cs.error, cs.error.o(0.65)];
      if (loading) return const [Color(0xFF3E3D52), Color(0xFF6D6C83)];
      if (done) return const [AppColors.secondary, AppColors.primary];

      switch (status) {
        case TeethingStatus.recent:
          return const [AppColors.primary, AppColors.secondary];
        case TeethingStatus.active:
          return const [AppColors.secondary, AppColors.primary];
        case TeethingStatus.calm:
          return [cs.onSurfaceVariant, cs.onSurfaceVariant.o(0.55)];
        case TeethingStatus.empty:
          return const [AppColors.primary, AppColors.secondary];
      }
    }

    IconData pickIcon() {
      if (hasError) return Icons.error_outline_rounded;
      if (loading) return Icons.hourglass_bottom_rounded;
      if (done) return Icons.check_rounded;

      switch (status) {
        case TeethingStatus.recent:
          return Icons.auto_awesome_rounded;
        case TeethingStatus.active:
          return Icons.emoji_emotions_outlined;
        case TeethingStatus.calm:
          return Icons.nightlight_round;
        case TeethingStatus.empty:
          return Icons.emoji_emotions_outlined;
      }
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: gradientColors()),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.o(0.12),
          ),
        ],
      ),
      child: Icon(
        pickIcon(),
        color: Colors.white,
        size: 26,
      ),
    );
  }
}
