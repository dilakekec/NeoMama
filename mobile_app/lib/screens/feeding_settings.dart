// lib/screens/feeding_settings.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/feeding_schedule.dart';

class FeedingSettings extends StatefulWidget {
  final String babyId;
  const FeedingSettings({required this.babyId, Key? key}) : super(key: key);

  @override
  _FeedingSettingsState createState() => _FeedingSettingsState();
}

class _FeedingSettingsState extends State<FeedingSettings> {
  List<TimeOfDay> times = [];
  final notifier = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initNotifications();
    _loadSchedule();
  }

  void _initNotifications() {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    notifier.initialize(InitializationSettings(android: android));
  }

  Future<void> _loadSchedule() async {
    final res = await http.get(
      Uri.parse('http://localhost:8000/api/baby/${widget.babyId}/schedule'),
    );
    final sched = FeedingSchedule.fromJson(jsonDecode(res.body));
    setState(() {
      times = sched.times.map((t) {
        final parts = t.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList();
    });
    _scheduleAll();
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context, 
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        times.add(time);
        _saveAndSchedule();
      });
    }
  }

    
    Future<void> _saveAndSchedule() async {
      final payload = FeedingSchedule(
        times: times.map((t) => t.format(context)).toList(),
      ).toJson();
      await http.post(
        Uri.parse('http://localhost:8000/api/baby/${widget.babyId}/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      _scheduleAll();
    }
  
  void _scheduleAll() {
    notifier.cancelAll();
    for (var i = 0; i < times.length; i++) {
      final time = times[i];
      notifier.zonedSchedule(
        i,
        'Feeding Time',
        'It\'s time to feed your baby at \${time.format(context)}.',
        _nextInstanceOf(time),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'feeding_channel',
            'Feeding',
            channelDescription: 'Baby feeding notifications',
          ),
        ),
        androidAllowWhileIdle: true,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local, 
      now.year, 
      now.month, 
      now.day, 
      time.hour, 
      time.minute,
    );
    if (scheduled.isBefore(now)) scheduled = scheduled.add(Duration(days: 1));
    return scheduled;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feeding Notifications')),
      body: ListView(
        children: [
          for (var time in times)
            ListTile(
              title: Text(time.format(context)),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    times.remove(time);
                  });
                  _saveAndSchedule();
                }
              ),
            ),
          ListTile(
            leading: Icon(Icons.add),
            title: const Text('Add Time'),
            onTap: _pickTime,
          ),
        ],
      ),
    );
  }
}