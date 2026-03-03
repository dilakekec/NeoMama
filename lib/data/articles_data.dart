import 'package:neomama/l10n/app_strings.dart';

class Article {
  final String title;
  final String category;
  final String content;

  const Article({
    required this.title,
    required this.category,
    required this.content,
  });
}

List<Article> articlesDataFor(String code) {
  return [
    Article(
      title: AppStrings.byCode(code, 'article_breastfeeding_title'),
      category: AppStrings.byCode(code, 'article_breastfeeding_cat'),
      content: AppStrings.byCode(code, 'article_breastfeeding_body'),
    ),
    Article(
      title: AppStrings.byCode(code, 'article_sleep_title'),
      category: AppStrings.byCode(code, 'article_sleep_cat'),
      content: AppStrings.byCode(code, 'article_sleep_body'),
    ),
    Article(
      title: AppStrings.byCode(code, 'article_teething_title'),
      category: AppStrings.byCode(code, 'article_teething_cat'),
      content: AppStrings.byCode(code, 'article_teething_body'),
    ),
  ];
}
