import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    final favorites = [
      {
        'title': 'Breastfeeding Tips for New Moms',
        'category': 'Article',
      },
      {
        'title': 'Introducing Solids to Your Baby',
        'category': 'Nutrition',
      },
    ];
    return Scaffold(  
      appBar: AppBar(title: const Text('My Favorites')),
      body: ListView.builder(  
        padding: const EdgeInsets.all(16),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final fav = favorites[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.pinkAccent),
              title: Text(fav['title']!),
              subtitle: Text(fav['category']!),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(  
                    const SnackBar(content: Text('Removed from favorites')),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}