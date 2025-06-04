import 'package:flutter/material.dart';
import'../data/articles_data.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Articles')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: articlesData.length,
        itemBuilder: (context, index) {
          final article = articlesData[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(  
              title: Text(article['title'] ?? ''),
              subtitle: Text(article['summary'] ?? ''),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                showDialog(  
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(article['title'] ?? ''),
                    content: Text(article['content'] ?? ''),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}