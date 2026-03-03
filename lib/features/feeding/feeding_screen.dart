import 'package:flutter/material.dart';

import '../../models/baby_profile.dart';
import 'feeding_detail_screen.dart';

import 'widgets/feeding_summary_card.dart';
import 'widgets/feeding_note_card.dart';
import 'widgets/feeding_time_card.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class FeedingScreen extends StatelessWidget {
  final BabyProfile baby;
  const FeedingScreen({super.key, required this.baby});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    
    final summarySubtitle = AppStrings.t(context, 'feeding_summary_sub');
    final summaryChips = [
      AppStrings.t(context, 'feeding_chip_bottle'),
      AppStrings.t(context, 'feeding_chip_solid'),
      AppStrings.t(context, 'feeding_chip_water'),
    ];

    final note = AppStrings.t(context, 'feeding_note');
    final schedule = const [
      _FeedSlot('09:00', 'feed_bottle', 'feed_bottle_detail', Icons.local_drink_outlined),
      _FeedSlot('12:30', 'feed_solid', 'feed_solid_detail', Icons.restaurant_outlined),
      _FeedSlot('16:00', 'feed_water', 'feed_water_detail', Icons.water_drop_outlined),
    ];

    final guides = <_GuideItem>[
      _GuideItem(
        title: AppStrings.t(context, 'feeding_daily_tips'),
        subtitle: AppStrings.t(context, 'feeding_daily_tips_sub'),
        icon: Icons.lightbulb_outline,
        tips: [
          AppStrings.t(context, 'feeding_tip_water'),
          AppStrings.t(context, 'feeding_tip_small'),
          AppStrings.t(context, 'feeding_tip_no_screen'),
        ],
      ),
      _GuideItem(
        title: AppStrings.t(context, 'feeding_meal_ideas'),
        subtitle: AppStrings.t(context, 'feeding_meal_ideas_sub'),
        icon: Icons.restaurant_outlined,
        tips: [
          AppStrings.t(context, 'feeding_meal_1'),
          AppStrings.t(context, 'feeding_meal_2'),
          AppStrings.t(context, 'feeding_meal_3'),
        ],
      ),
      _GuideItem(
        title: AppStrings.t(context, 'feeding_allergy_notes'),
        subtitle: AppStrings.t(context, 'feeding_allergy_notes_sub'),
        icon: Icons.warning_amber_outlined,
        tips: [
          AppStrings.t(context, 'feeding_allergy_tip1'),
          AppStrings.t(context, 'feeding_allergy_tip2'),
        ],
      ),
    ];

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'feeding'), style: t.titleLarge),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            FeedingSummaryCard(
              subtitle: summarySubtitle,
              chips: summaryChips,
              onEdit: () {
                
              },
            ),
            const SizedBox(height: 14),
            FeedingNoteCard(
              note: note,
              onAdd: () {
                
              },
            ),
            const SizedBox(height: 18),

            Text(
              AppStrings.t(context, 'feeding_schedule'),
              style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),

            ...schedule.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FeedingTimeCard(
                    timeLabel: s.time,
                    typeLabel: AppStrings.t(context, s.type),
                    detail: AppStrings.t(context, s.detail),
                    icon: s.icon,
                    onTap: () {
                      
                    },
                  ),
                )),

            const SizedBox(height: 8),

            Text(
              AppStrings.t(context, 'feeding_guides'),
              style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: guides.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final it = guides[i];
                return NeoCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FeedingDetailScreen(
                          title: it.title,
                          tips: it.tips,
                        ),
                      ),
                    );
                  },
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
                        child: Icon(it.icon, color: cs.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              it.title,
                              style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              it.subtitle,
                              style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedSlot {
  final String time;
  final String type;
  final String detail;
  final IconData icon;
  const _FeedSlot(this.time, this.type, this.detail, this.icon);
}

class _GuideItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> tips;

  _GuideItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tips,
  });
}
