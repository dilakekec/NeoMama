import 'package:flutter/material.dart';

class BlogFeedScreen extends StatelessWidget {
  const BlogFeedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final blogs = [
      {
        'title': 'Breastfeeding Tips for New Moms',
        'category': 'Article',
        'excerpt': 'Helpful advice for a successful breastfeeding journey.',
      },
      {
        'title': 'Taking Care of Your Mental Health',
        'category': 'Wellness',
        'excerpt': 'Strategies to maintain wellness during parenthood',
      },
      {
        'title': 'Introducing Solids to Your Baby',
        'category': 'Nutrition',
        'excerpt': 'Guidance on starting your baby on solid foods',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Blog Feed')),
      body: ListView.builder(  
        padding: const EdgeInsets.all(16),
        itemCount: blogs.length,
        itemBuilder: (context, index) {
          final blog = blogs[index];
          return Card(  
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(  
              padding: const EdgeInsets.all(16),
              child: Column(  
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(blog['category']!, style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(blog['title']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(blog['excerpt']!, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 18),
                  const Text('Read more', style: TextStyle(color: Colors.blueAccent)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
      
    