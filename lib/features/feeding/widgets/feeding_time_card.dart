import 'package:flutter/material.dart';

import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/utils/color_ext.dart';

class FeedingTimeCard extends StatelessWidget {
  final String timeLabel;
  final String typeLabel;
  final String? detail;
  final IconData icon;
  final VoidCallback? onTap;

  const FeedingTimeCard({
    super.key,
    required this.timeLabel,
    required this.typeLabel,
    this.detail,
    this.icon = Icons.local_drink_outlined,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final d = (detail ?? '').trim();
    final line = d.isEmpty ? typeLabel : '$typeLabel • $d';

    return NeoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.primary.o(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.primary.o(0.18)),
            ),
            child: Icon(icon, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeLabel,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  line,
                  style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}