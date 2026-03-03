import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TeethingStore {
  static const _keyPrefix = 'teething_dates_'; 

  static Future<Map<String, String>> load(String babyKey) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('$_keyPrefix$babyKey');
    if (raw == null || raw.trim().isEmpty) return {};
    final map = (jsonDecode(raw) as Map).cast<String, dynamic>();
    return map.map((k, v) => MapEntry(k, v.toString()));
  }

  static Future<void> save(String babyKey, Map<String, String> data) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('$_keyPrefix$babyKey', jsonEncode(data));
  }
}