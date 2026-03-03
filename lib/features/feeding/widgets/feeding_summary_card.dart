import 'package:flutter/material.dart';

import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class FeedingSummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> chips;
  final VoidCallback? onEdit;

  const FeedingSummaryCard({
    super.key,
    this.title = '',
    required this.subtitle,
    this.chips = const [],
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final resolvedTitle =
        title.trim().isEmpty ? AppStrings.t(context, 'feeding_today') : title;

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                resolvedTitle,
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              if (onEdit != null)
                IconButton(
                  tooltip: AppStrings.t(context, 'edit'),
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, color: cs.primary),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips.map((c) => _Chip(text: c)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.o(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.o(0.16)),
      ),
      child: Text(
        text,
        style: t.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: cs.primary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
