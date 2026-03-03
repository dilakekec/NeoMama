import 'package:flutter/material.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class BlogFeedScreen extends StatelessWidget {
  const BlogFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'blog_feed'), style: t.titleLarge),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _ArticleCard(
              emoji: "👩‍🍼",
              category: AppStrings.t(context, 'blog_cat_articles'),
              title: AppStrings.t(context, 'blog_1_title'),
              subtitle: AppStrings.t(context, 'blog_1_sub'),
            ),
            _ArticleCard(
              emoji: "🧠",
              category: AppStrings.t(context, 'blog_cat_wellness'),
              title: AppStrings.t(context, 'blog_2_title'),
              subtitle: AppStrings.t(context, 'blog_2_sub'),
            ),
            _ArticleCard(
              emoji: "🥣",
              category: AppStrings.t(context, 'blog_cat_nutrition'),
              title: AppStrings.t(context, 'blog_3_title'),
              subtitle: AppStrings.t(context, 'blog_3_sub'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final String emoji;
  final String category;
  final String title;
  final String subtitle;

  const _ArticleCard({
    required this.emoji,
    required this.category,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NeoCard(
        onTap: () {
          
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.primary.o(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                emoji,
                style: t.headlineSmall,
              ),
            ),
            const SizedBox(width: 14),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: t.labelMedium?.copyWith(
                      color: cs.primary,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: t.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: t.bodyMedium,
                  ),
                ],
              ),
            ),

            
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
