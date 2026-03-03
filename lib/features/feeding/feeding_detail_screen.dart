import 'package:flutter/material.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';

class FeedingDetailScreen extends StatelessWidget {
  final String title;
  final List<String> tips;

  const FeedingDetailScreen({
    super.key,
    required this.title,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, style: t.titleLarge),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: tips.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final tip = tips[index];

            return NeoCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(tip, style: t.bodyMedium)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}