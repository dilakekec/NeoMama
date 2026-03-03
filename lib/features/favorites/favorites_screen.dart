import 'package:flutter/material.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    
    final favorites = <_FavItem>[
      _FavItem(
        "👩‍🍼",
        AppStrings.t(context, 'favorites_item_1'),
        AppStrings.t(context, 'favorites_type_article'),
      ),
      _FavItem(
        "🧸",
        AppStrings.t(context, 'favorites_item_2'),
        AppStrings.t(context, 'favorites_type_game'),
      ),
      _FavItem(
        "🌙",
        AppStrings.t(context, 'favorites_item_3'),
        AppStrings.t(context, 'favorites_type_music'),
      ),
    ];

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'favorites'), style: t.titleLarge),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: favorites.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: NeoCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💾', style: TextStyle(fontSize: 44)),
                        const SizedBox(height: 10),
                        Text(
                          AppStrings.t(context, 'favorites_empty'),
                          style:
                              t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.t(context, 'favorites_empty_sub'),
                          style: t.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: favorites.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final f = favorites[i];
                  return _FavoriteCard(
                    emoji: f.emoji,
                    title: f.title,
                    subtitle: f.type,
                    onTap: () {
                      
                    },
                    onRemove: () {
                      
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _FavItem {
  final String emoji;
  final String title;
  final String type;
  const _FavItem(this.emoji, this.title, this.type);
}

class _FavoriteCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const _FavoriteCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return NeoCard(
      onTap: onTap,
      child: Row(
        children: [
          Text(emoji, style: t.headlineSmall),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primary.o(0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: cs.primary.o(0.16)),
                  ),
                  child: Text(
                    subtitle,
                    style: t.labelLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: AppStrings.t(context, 'remove'),
            onPressed: onRemove,
            icon: Icon(Icons.favorite, color: cs.primary),
          ),
        ],
      ),
    );
  }
}
