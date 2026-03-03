import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_signals.dart';

class DailySignalsService {
  static String _key(String babyKey) => 'daily_signals:$babyKey';

  
  
  
  Future<DailySignals> load(String babyKey) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(babyKey));

    if (raw == null || raw.trim().isEmpty) {
      return DailySignals.empty;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return DailySignals.empty;
      }

      return DailySignals(
        sleepRestless: decoded['sleep_restless'] == true,
        feedingHard: decoded['feeding_hard'] == true,
        teethingSymptoms: decoded['teething_symptoms'] == true,
        newFood: decoded['new_food'] == true,
        skinRash: decoded['skin_rash'] == true,
      );
    } catch (_) {
      
      return DailySignals.empty;
    }
  }

  
  
  
  Future<void> save(String babyKey, DailySignals s) async {
    final prefs = await SharedPreferences.getInstance();

    final payload = <String, dynamic>{
      'sleep_restless': s.sleepRestless,
      'feeding_hard': s.feedingHard,
      'teething_symptoms': s.teethingSymptoms,
      'new_food': s.newFood,
      'skin_rash': s.skinRash,
      '_v': 1, 
    };

    await prefs.setString(_key(babyKey), jsonEncode(payload));
  }

  
  
  
  Future<void> clear(String babyKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(babyKey));
  }
}
