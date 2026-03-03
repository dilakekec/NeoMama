import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/teething_models.dart';

class TeethingService {
  static const _keyPrefix = 'teething_v2:'; 

  String _key(String babyKey) => '$_keyPrefix$babyKey';

  Future<Map<String, ToothState>> load(String babyKey) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(babyKey));
    if (raw == null || raw.trim().isEmpty) return {};

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map) return {};

      final out = <String, ToothState>{};

      decoded.forEach((k, v) {
        final id = _normalizeId(k?.toString());
        if (id == null || id.trim().isEmpty) return;

        
        if (v is Map) {
          final map = <String, dynamic>{};
          v.forEach((kk, vv) => map[kk.toString()] = vv);
          out[id] = ToothState.fromJson(map);
        } else {
          
          out[id] = const ToothState(erupted: false);
        }
      });

      return out;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TeethingService.load parse error: $e');
      }
      return {};
    }
  }

  Future<void> save(String babyKey, Map<String, ToothState> map) async {
    final prefs = await SharedPreferences.getInstance();

    
    final jsonMap = <String, dynamic>{};
    map.forEach((k, v) {
      final id = k.trim();
      if (id.isEmpty) return;
      jsonMap[id] = v.toJson();
    });

    await prefs.setString(_key(babyKey), jsonEncode(jsonMap));
  }

  Future<void> clear(String babyKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(babyKey));
  }

  
  Future<void> migrateV1ToV2IfNeeded(String babyKey) async {
    final prefs = await SharedPreferences.getInstance();

    final v2Key = _key(babyKey);
    if (prefs.containsKey(v2Key)) return;

    final v1Key = 'teething:$babyKey';
    final raw = prefs.getString(v1Key);
    if (raw == null || raw.trim().isEmpty) return;

    
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;

      final out = <String, ToothState>{};
      decoded.forEach((k, v) {
        final id = _normalizeId(k?.toString());
        if (id == null || id.trim().isEmpty) return;

        if (v is Map) {
          final map = <String, dynamic>{};
          v.forEach((kk, vv) => map[kk.toString()] = vv);
          out[id] = ToothState.fromJson(map);
        }
      });

      await save(babyKey, out);
      
      
    } catch (_) {
      
    }
  }

  String? _normalizeId(String? rawId) {
    if (rawId == null) return null;
    final id = rawId.trim();
    if (id.isEmpty) return null;
    if (id.startsWith('tooth-')) return id;

    final m = RegExp(r'^([ul])(\d{1,2})$').firstMatch(id);
    if (m == null) return id;
    final arch = m.group(1);
    final num = m.group(2);
    return 'tooth-$arch-$num';
  }
}
