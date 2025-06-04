import 'package:flutter/material.dart';

class FeedingScreen extends StatelessWidget {
  const FeedingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feeding')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _FeedingCard(
              title: 'Breastfeeding',
              subtitle: 'Learn about breastfeeding techniques and tips.',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _FeedingCard(
              title: 'Bottle-Feeding',
              subtitle: 'Get information on formula feeding your baby',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _FeedingCard(
              title: 'Starting Solids',
              subtitle: 'Guidance on transitioning to solid foods.',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeedingCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size:16),
          ],
        ),
      ),
    );
  }
}