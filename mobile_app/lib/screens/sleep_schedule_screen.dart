import 'package:flutter/material.dart';

class SleepScheduleScreen extends StatelessWidget {
  const SleepScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sleepData = [
      {'day': 'Monday', 'start': '8:00 PM', 'end': '6:30 AM'},
      {'day': 'Tuesday', 'start': '8:00 PM', 'end': '6:30 AM'},
      {'day': 'Wednesday', 'start': '8:00 PM', 'end': '6:30 AM'},
      {'day': 'Thursday', 'start': '8:00 PM', 'end': '6:30 AM'},
      {'day': 'Friday', 'start': '8:00 PM', 'end': '6:30 AM'},  
    ];

    return Scaffold(  
      appBar: AppBar(title: const Text('Sleep Schedule')),
      body: ListView.builder(  
        itemCount: sleepData.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final item = sleepData[index];
          return Card(  
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(  
              leading: const Icon(Icons.nightlight_round, color: Colors.deepPurple),
              title: Text(item['day']!),
              subtitle: Text('From ${item['start']} to ${item['end']}'),
            ),
          );
        },
      ),
    );
  }
}