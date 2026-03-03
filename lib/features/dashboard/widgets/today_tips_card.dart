import "package:flutter/material.dart";
import "../models/tip_item.dart";
import "package:neomama/l10n/app_strings.dart";

class TodayTipsCard extends StatelessWidget {
  final List<TipItem> tips;
  const TodayTipsCard({super.key, required this.tips});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.t(context, 'todays_tips'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final t in tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text("• ${t.title}: ${t.body}"),
              ),
          ],
        ),
      ),
    );
  }
}
