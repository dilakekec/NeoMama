import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:neomama/models/tip_models.dart';
import 'package:neomama/core/theme/app_colors.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class TodayTipsCard extends StatelessWidget {
  final String title;
  final List<TipItem> items;
  final VoidCallback? onEdit;
  final String? emptyLabel;
  final void Function(TipItem item)? onCta;

  const TodayTipsCard({
    super.key,
    required this.title,
    required this.items,
    this.onEdit,
    this.emptyLabel,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    final hasItems = items.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.o(0.78),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.o(0.35)),
            boxShadow: [
              BoxShadow(
                blurRadius: 22,
                offset: const Offset(0, 12),
                color: Colors.black.o(0.08),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _SparkIcon(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2F2E3A),
                      ),
                    ),
                  ),
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.tune_rounded),
                      tooltip: AppStrings.t(context, 'edit'),
                      color: const Color(0xFF6D6C83),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (!hasItems)
                Text(
                  emptyLabel ?? AppStrings.t(context, 'no_tips_yet'),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.25,
                    color: Colors.black.o(0.55),
                    fontWeight: FontWeight.w700,
                  ),
                )
              else
                ...items.map((t) => _TipRow(item: t, onCta: onCta)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final TipItem item;
  final void Function(TipItem item)? onCta;
  const _TipRow({required this.item, this.onCta});

  @override
  Widget build(BuildContext context) {
    final style = _TipStyle.from(item);
    final hasReason = (item.reason ?? '').trim().isNotEmpty;
    final action = item.ctaLabel?.trim() ?? '';
    final hasAction = action.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.o(0.70),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: style.accent.o(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: style.accent.o(0.14),
              border: Border.all(color: style.accent.o(0.20)),
            ),
            child: Icon(style.icon, color: style.accent, size: 18),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 13.2,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2F2E3A),
                        ),
                      ),
                    ),
                    if (hasReason)
                      IconButton(
                        constraints:
                            const BoxConstraints.tightFor(width: 32, height: 32),
                        padding: EdgeInsets.zero,
                        tooltip: AppStrings.t(context, 'why_this_tip'),
                        icon: Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: style.accent,
                        ),
                        onPressed: () => _showReason(context, item, style.accent),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 12.6,
                    height: 1.25,
                    color: Color(0xFF3E3D52),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (hasAction) ...[
                  const SizedBox(height: 8),
                  if (onCta != null)
                    TextButton.icon(
                      onPressed: () => onCta?.call(item),
                      icon: Icon(Icons.notifications_active_rounded,
                          size: 16, color: style.accent),
                      label: Text(
                        action,
                        style: TextStyle(
                          fontSize: 12.4,
                          fontWeight: FontWeight.w900,
                          color: style.accent,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                  else if (item.ctaRoute != null)
                    TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, item.ctaRoute!),
                      icon: Icon(Icons.arrow_forward_rounded, size: 16, color: style.accent),
                      label: Text(
                        action,
                        style: TextStyle(
                          fontSize: 12.4,
                          fontWeight: FontWeight.w900,
                          color: style.accent,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: style.accent.o(0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: style.accent.o(0.2)),
                      ),
                      child: Text(
                        action,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: style.accent,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),
          _Chip(type: item.type, accent: style.accent),
        ],
      ),
    );
  }

  void _showReason(BuildContext context, TipItem item, Color accent) {
    final reason = (item.reason ?? '').trim();
    if (reason.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.o(0.92),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.o(0.35)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                        color: Colors.black.o(0.12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: accent.o(0.14),
                              border:
                                  Border.all(color: accent.o(0.20)),
                            ),
                            child: Icon(
                              Icons.help_outline_rounded,
                              color: accent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppStrings.t(context, 'why_this_tip'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: Color(0xFF2F2E3A),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13.5,
                          color: Color(0xFF2F2E3A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        reason,
                        style: const TextStyle(
                          fontSize: 12.8,
                          height: 1.3,
                          color: Color(0xFF3E3D52),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final TipType type;
  final Color accent;
  const _Chip({required this.type, required this.accent});

  @override
  Widget build(BuildContext context) {
    final text = switch (type) {
      TipType.info => AppStrings.t(context, 'tip_type_info'),
      TipType.reminder => AppStrings.t(context, 'tip_type_remind'),
      TipType.warning => AppStrings.t(context, 'tip_type_watch'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.o(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.o(0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w900,
          color: accent.o(0.95),
        ),
      ),
    );
  }
}

class _TipStyle {
  final IconData icon;
  final Color accent;
  const _TipStyle(this.icon, this.accent);

  factory _TipStyle.from(TipItem item) {
    switch (item.type) {
      case TipType.info:
        return const _TipStyle(Icons.auto_awesome_rounded, Color(0xFF6D6C83));
      case TipType.reminder:
        return const _TipStyle(Icons.event_available_rounded, AppColors.primary);
      case TipType.warning:
        return const _TipStyle(Icons.health_and_safety_rounded, AppColors.warm);
    }
  }
}

class _SparkIcon extends StatelessWidget {
  const _SparkIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.o(0.10),
          ),
        ],
      ),
      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
    );
  }
}
