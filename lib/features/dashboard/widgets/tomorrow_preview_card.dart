import "package:flutter/material.dart";
import "../models/tip_item.dart";

class TomorrowPreviewCard extends StatelessWidget {
  final TomorrowPreview preview;
  const TomorrowPreviewCard({super.key, required this.preview});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              preview.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(preview.body),
          ],
        ),
      ),
    );
  }
}
