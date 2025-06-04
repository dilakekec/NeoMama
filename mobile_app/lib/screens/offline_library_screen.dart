import 'package:flutter/material.dart';

class OfflineLibraryScreen extends StatelessWidget { 
  OfflineLibraryScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> items = [
    {
      'title': 'Downloaded Rhymes',
      'icon': Icons.music_note,
      'color': Colors.pinkAccent.shade100,
    },
    {
      'title': 'Offline Games',
      'icon': Icons.music_note,
      'color': Colors.pinkAccent.shade100,
    },
    {
      'title': 'Saved Articles',
      'icon': Icons.book,
      'color': Colors.purpleAccent.shade100,
    },
  ];

   @override
   Widget build(BuildContext context) {
     return Scaffold(  
       appBar: AppBar(title: const Text('Offline Library')),
       body: ListView.builder(  
         padding: const EdgeInsets.all(16),
         itemCount: items.length,
         itemBuilder: (context, index) {
           final item = items[index];
           return Card(  
             color: item['color'] as Color,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
             margin: const EdgeInsets.only(bottom: 16),
             child: ListTile(  
               leading: Icon(item['icon'] as IconData, size:30),
               title: Text(
                 item['title'], 
                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
               ),
               trailing: const Icon(Icons.arrow_forward_ios, size:16),
               onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

      