import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NeoMama Menu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(  
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: const [
            _MenuItem(icon: '🍼', label: 'development', route: '/monthly'),
            _MenuItem(icon: '🎲', label: 'Plays', route: '/play'),
            _MenuItem(icon: '📖', label: 'Articles', route: '/articles'),
            _MenuItem(icon: '❤️', label: 'Favorites', route: '/favorites'),
            _MenuItem(icon: '📥', label: 'Downloads', route: '/downloads'),
            _MenuItem(icon: '💬', label: 'Forum', route: '/forum'),
            _MenuItem(icon: '🎵', label: 'Music', route: '/music'),
            _MenuItem(icon: '⚙️', label: 'Settings', route: '/settings'),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String icon;
  final String label;
  final String route;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.pink.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.pinkAccent.withOpacity(0.2)),
        ),
        child: Column(  
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
