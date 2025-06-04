import 'package:flutter/material.dart';

class SleepScheduleScreen extends StatefulWidget {
  const SleepScheduleScreen({Key? key}) : super(key: key);

  @override
  State<SleepScheduleScreen> createState() => _SleepScheduleScreenState();
}

class _SleepScheduleScreenState extends State<SleepScheduleScreen> {
  List<TimeOfDay> sleepTimes = [];

  Future<void> _pickTime() async {
    final picked = await showTimePicker( 
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        sleepTimes.add(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Schedule')),
      body: ListView(
        children: [
          for (var time in sleepTimes)
            ListTile(
              title: Text(time.format(context)),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    sleepTimes.remove(time);
                  });
                },
              ),
            ),
          ListTile(  
            leading: const Icon(Icons.add),
            title: const Text('Add Sleep Time'),
            onTap: _pickTime,
          ),
        ],
      ),
    );
  }
}