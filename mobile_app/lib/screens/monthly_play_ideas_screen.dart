import 'package:flutter/material.dart';


class MonthlyPlayIdeasScreen extends StatelessWidget{
  const MonthlyPlayIdeasScreen({super.key});

  final List<Map<String, String>> playIdeas = const [
    {'month': 'First Month', 'idea': 'Finger plays and soft toys'},
    {'month': 'Second Month', 'idea': 'Tummy time with toys'},
    {'month': 'Third Month', 'idea': 'Singing and clapping games'},
    {'month': 'Fourth Month', 'idea': 'Peek-a-boo with a blanket'},
    {'month': 'Fifth Month', 'idea': 'Sensory play with water'},
    {'month': 'Sixth Month', 'idea': 'Exploring textures with fabric'},
    {'month': 'Seventh Month', 'idea': 'Rolling a ball back and forth'},
    {'month': 'Eighth Month', 'idea': 'Playing with stacking toys'},
    {'month': 'Ninth Month', 'idea': 'Simple puzzles with large pieces'},
    {'month': 'Tenth Month', 'idea': 'Playing with musical instruments'},
    {'month': 'Eleventh Month', 'idea': 'Exploring nature with a magnifying glass'},
    {'month': 'Twelfth Month', 'idea': 'Building blocks and towers'},
    {'month': 'Thirteenth Month', 'idea': 'Pretend play with dolls'},
    {'month': 'Fourteenth Month', 'idea': 'Playing with shape sorters'},
    {'month': 'Fifteenth Month', 'idea': 'Exploring colors with crayons'},
    {'month': 'Sixteenth Month', 'idea': 'Playing with playdough'},
    {'month': 'Seventeenth Month', 'idea': 'Simple art projects'},
    {'month': 'Eighteenth Month', 'idea': 'Playing with water and cups'},
    {'month': 'Nineteenth Month', 'idea': 'Playing with toy cars'},
    {'month': 'Twentieth Month', 'idea': 'Exploring nature with a magnifying glass'},
    {'month': 'Twenty-First Month', 'idea': 'Playing with musical instruments'},
    {'month': 'Twenty-Second Month', 'idea': 'Building blocks and towers'},
    {'month': 'Twenty-Third Month', 'idea': 'Pretend play with dolls'},
    {'month': 'Twenty-Fourth Month', 'idea': 'Playing with shape sorters'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Play Ideas'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: playIdeas.length,
        itemBuilder: (context, index) {
          final item = playIdeas[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.pink.shade50,
            child: ListTile(
              title: Text(item['month']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['idea']!),
              leading: const Icon(Icons.toys, color: Colors.pinkAccent),
            ),
          );
        },
      ),
    );
  }
}