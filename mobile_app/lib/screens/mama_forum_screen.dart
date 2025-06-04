import 'package:flutter/material.dart';

class MamaForumScreen extends StatelessWidget {
  const MamaForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = [
      {'title': 'How to manage 1-year-old baby sleep?', 'replies': 12},
      {'title': 'Experiences with starting solids', 'replies': 7},
      {'title': 'Is it necessary to pump milk?', 'replies': 5},
      {'title': 'Teething crisis in babies', 'replies': 10},
    ];

    return Scaffold(  
      appBar: AppBar(title: const Text('Mama Forum')),
      body: ListView.builder(  
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          final String title = topic['title'] as String;
          final String replies = (topic['replies'] as int).toString();
          return ListTile(  
            title: Text(title),
            subtitle: Text('$replies replies'), 
            leading: const Icon(Icons.chat_bubble_outline),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              // future detail page
            },
          );
        },
      ),
    );
  }
}