import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/vaccination_models.dart';

class VaccinationsService {
  
  static const _keyPrefix = 'vaccinations_v1:'; 

  String _key(String babyKey) => '$_keyPrefix${_sanitizeBabyKey(babyKey)}';

  String _sanitizeBabyKey(String babyKey) {
    final k = babyKey.trim();
    
    if (k.isEmpty) return 'unknown';
    
    return k.replaceAll(RegExp(r'\s+'), '_');
  }

  Future<Map<String, VaccinationState>> load(String babyKey) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(babyKey));
    if (raw == null || raw.trim().isEmpty) return {};

    try {
      final decoded = jsonDecode(raw);

      
      if (decoded is! Map) return {};

      final out = <String, VaccinationState>{};
      decoded.forEach((id, v) {
        if (id is! String) return;
        final map = (v is Map) ? Map<String, dynamic>.from(v) : <String, dynamic>{};
        out[id] = VaccinationState.fromJson(map);
      });

      return out;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('VaccinationsService.load decode error: $e');
        debugPrintStack(stackTrace: st);
      }

      
      
      await _softResetCorrupted(prefs, babyKey);
      return {};
    }
  }

  Future<void> save(String babyKey, Map<String, VaccinationState> map) async {
    final prefs = await SharedPreferences.getInstance();

    
    final jsonMap = <String, dynamic>{};
    for (final e in map.entries) {
      jsonMap[e.key] = e.value.toJson();
    }

    try {
      await prefs.setString(_key(babyKey), jsonEncode(jsonMap));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('VaccinationsService.save error: $e');
        debugPrintStack(stackTrace: st);
      }
      rethrow;
    }
  }

  
  Future<void> upsert(String babyKey, String vaccineId, VaccinationState state) async {
    final current = await load(babyKey);
    current[vaccineId] = state;
    await save(babyKey, current);
  }

  
  Future<void> remove(String babyKey, String vaccineId) async {
    final current = await load(babyKey);
    current.remove(vaccineId);
    await save(babyKey, current);
  }

  
  Future<void> clear(String babyKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(babyKey));
  }

  Future<void> _softResetCorrupted(SharedPreferences prefs, String babyKey) async {
    try {
      
      final k = _key(babyKey);
      final raw = prefs.getString(k);
      if (raw != null && raw.trim().isNotEmpty) {
        await prefs.setString('${k}__corrupt_backup', raw);
      }
      await prefs.remove(k);
    } catch (_) {
      
    }
  }
}
