import 'package:flutter/material.dart';
import '../../core/theme/neo_background.dart';
import '../../core/theme/neo_card.dart';
import 'package:neomama/l10n/app_strings.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final activities = [
      (
        Icons.toys_outlined,
        AppStrings.t(context, 'activities_item_1'),
        AppStrings.t(context, 'activities_item_1_sub'),
      ),
      (
        Icons.sensors_outlined,
        AppStrings.t(context, 'activities_item_2'),
        AppStrings.t(context, 'activities_item_2_sub'),
      ),
      (
        Icons.nature_people_outlined,
        AppStrings.t(context, 'activities_item_3'),
        AppStrings.t(context, 'activities_item_3_sub'),
      ),
    ];

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'activities'), style: t.titleLarge),
          centerTitle: true,
        ),
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: activities.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final a = activities[index];

            return NeoCard(
              onTap: () {},
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    a.$1,
                    color: cs.primary,
                    size: 26,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.$2,
                          style: t.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          a.$3,
                          style: t.bodyMedium,
                        ),
                      ],
                    ),
                  ),
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
