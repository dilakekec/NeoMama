import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:neomama/models/behavioral_notification.dart';

class LocalNotificationsService {
  LocalNotificationsService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> init() async {
    if (_ready) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
    _ready = true;
  }

  static Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(
      alert: true,
      sound: false,
      badge: false,
    );
  }

  static Future<void> scheduleNudge(BehavioralNotification nudge) async {
    if (!_ready) {
      await init();
    }

    final now = DateTime.now();
    var scheduled = nudge.scheduledAt;
    if (!scheduled.isAfter(now.add(const Duration(seconds: 5)))) {
      scheduled = now.add(const Duration(seconds: 5));
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'neomama.nudges',
        'NeoMama Nudges',
        channelDescription: 'Context-aware nudges',
        importance: Importance.low,
        priority: Priority.low,
        playSound: false,
        enableVibration: false,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: false,
        presentBadge: false,
      ),
    );

    final id = _idFor(nudge.id);
    final tzTime = tz.TZDateTime.from(scheduled, tz.local);

    await _plugin.zonedSchedule(
      id,
      nudge.title,
      nudge.body,
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    if (kDebugMode) {
      // ignore: avoid_print
      print('Scheduled nudge ${nudge.id} at $scheduled');
    }
  }

  static int _idFor(String id) {
    return id.hashCode & 0x7FFFFFFF;
  }
}
