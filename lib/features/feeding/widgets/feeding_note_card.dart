import 'package:flutter/material.dart';

import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/l10n/app_strings.dart';

class FeedingNoteCard extends StatelessWidget {
  final String title;
  final String note;
  final VoidCallback? onAdd;

  const FeedingNoteCard({
    super.key,
    this.title = '',
    required this.note,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final clean = note.trim();
    final empty = clean.isEmpty;

    final resolvedTitle =
        title.trim().isEmpty ? AppStrings.t(context, 'notes') : title;

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
              if (onAdd != null)
                IconButton(
                  tooltip: AppStrings.t(context, 'add'),
                  onPressed: onAdd,
                  icon: Icon(Icons.add_circle_outline, color: cs.primary),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            empty ? AppStrings.t(context, 'notes_empty') : clean,
            style: t.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
