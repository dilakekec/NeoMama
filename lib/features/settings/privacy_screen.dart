import 'package:flutter/material.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/l10n/app_strings.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'privacy'), style: t.titleLarge),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            NeoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.t(context, 'privacy_headline'),
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.t(context, 'privacy_body'),
                    style: t.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            NeoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.t(context, 'privacy_section1'),
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  _Bullet(text: AppStrings.t(context, 'privacy_item1')),
                  _Bullet(text: AppStrings.t(context, 'privacy_item2')),
                  _Bullet(text: AppStrings.t(context, 'privacy_item3')),
                ],
              ),
            ),
            const SizedBox(height: 14),
            NeoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.t(context, 'privacy_section2'),
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  _Bullet(text: AppStrings.t(context, 'privacy_item4')),
                  _Bullet(text: AppStrings.t(context, 'privacy_item5')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: t.bodyMedium?.copyWith(height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
