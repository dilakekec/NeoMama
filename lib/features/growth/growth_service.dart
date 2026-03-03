
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/growth_entry.dart';

class GrowthService {
  static const String _keyPrefix = 'growth_entries_v1_';

  String _key(String babyKey) => '$_keyPrefix$babyKey';

  Future<List<GrowthEntry>> load(String babyKey) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key(babyKey));

    if (raw == null || raw.trim().isEmpty) return <GrowthEntry>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <GrowthEntry>[];

      final items = decoded
          .whereType<Map>()
          .map((m) => m.cast<String, dynamic>())
          .map(GrowthEntry.fromJson)
          .toList();

      _sort(items);
      return items;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GrowthService.load decode failed for "$babyKey": $e');
      }
      return <GrowthEntry>[];
    }
  }

  Future<void> save(String babyKey, List<GrowthEntry> entries) async {
    final sp = await SharedPreferences.getInstance();
    final items = List<GrowthEntry>.from(entries);
    _sort(items);

    final list = items.map((e) => e.toJson()).toList();
    await sp.setString(_key(babyKey), jsonEncode(list));
  }

  
  Future<GrowthEntry> add(String babyKey, GrowthEntry entry) async {
    final items = await load(babyKey);

    final safeEntry = _ensureId(entry);
    items.removeWhere((e) => e.id == safeEntry.id);
    items.add(safeEntry);

    _sort(items);
    await save(babyKey, items);

    return safeEntry;
  }

  
  Future<bool> remove(String babyKey, String entryId) async {
    final items = await load(babyKey);
    final before = items.length;

    items.removeWhere((e) => e.id == entryId);

    if (items.length == before) return false;

    _sort(items);
    await save(babyKey, items);
    return true;
  }

  
  Future<void> clear(String babyKey) async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key(babyKey));
  }

  

  GrowthEntry _ensureId(GrowthEntry e) {
    final id = e.id.trim();
    if (id.isNotEmpty) return e;

    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    
    final newId = '${e.babyKey}_$ts';

    return GrowthEntry(
      id: newId,
      babyKey: e.babyKey,
      dateIso: e.dateIso,
      ageDays: e.ageDays,
      weightKg: e.weightKg,
      lengthCm: e.lengthCm,
      headCircCm: e.headCircCm,
    );
  }

  void _sort(List<GrowthEntry> items) {
    items.sort((a, b) {
      final ad = _tryParseIso(a.dateIso);
      final bd = _tryParseIso(b.dateIso);

      if (ad != null && bd != null) return ad.compareTo(bd);
      
      return a.dateIso.compareTo(b.dateIso);
    });
  }

  DateTime? _tryParseIso(String iso) {
    final s = iso.trim();
    if (s.isEmpty) return null;
    
    return DateTime.tryParse(s);
  }
}