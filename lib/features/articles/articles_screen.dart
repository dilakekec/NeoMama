import 'package:flutter/material.dart';
import '../../data/articles_data.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  void _openArticle(BuildContext context, dynamic article) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) {
        return NeoBackground(
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: cs.onSurface.o(0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 12),
                  NeoCard(
                    padding: const EdgeInsets.all(18),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.78,
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.title,
                              style: t.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary.o(0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: cs.primary.o(0.22),
                                ),
                              ),
                              child: Text(
                                article.category,
                                style: t.bodyMedium?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              article.content,
                              style: t.bodyMedium?.copyWith(
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppStrings.t(context, 'close')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final code = Localizations.localeOf(context).languageCode;
    final items = articlesDataFor(code);

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'articles'), style: t.titleLarge),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final article = items[index];

            return NeoCard(
              onTap: () => _openArticle(context, article),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.primary.o(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: cs.primary.o(0.18),
                      ),
                    ),
                    child: Icon(
                      Icons.article_outlined,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          article.category,
                          style: t.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
