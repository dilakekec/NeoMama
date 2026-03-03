import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/baby_profile.dart';

class BabyService {
  static const String _storeKey = 'neomama_babies_v1';

  Future<List<BabyProfile>> fetchBabyProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    return _loadBabies(prefs);
  }

  Future<BabyProfile> createBaby({
    required String name,
    required String birthDate,
    String? feeding,
    String? allergies,
    String? notes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final babies = await _loadBabies(prefs);

    final id = _nextId(babies);
    final baby = BabyProfile(
      id: id,
      name: name.trim(),
      birthDate: birthDate.trim(),
      feedingPreferences: _nullIfEmpty(feeding),
      allergies: _nullIfEmpty(allergies),
      notes: _nullIfEmpty(notes),
    );

    babies.add(baby);
    await _saveBabies(prefs, babies);
    return baby;
  }

  Future<BabyProfile> updateBaby(
    int id, {
    required String name,
    required String birthDate,
    String? feeding,
    String? allergies,
    String? notes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final babies = await _loadBabies(prefs);

    final index = babies.indexWhere((b) => b.id == id);
    if (index == -1) {
      throw const ApiException(
        type: ApiErrorType.notFound,
        message: 'Baby profile not found.',
      );
    }

    final updated = BabyProfile(
      id: id,
      name: name.trim(),
      birthDate: birthDate.trim(),
      feedingPreferences: _nullIfEmpty(feeding),
      allergies: _nullIfEmpty(allergies),
      notes: _nullIfEmpty(notes),
    );

    babies[index] = updated;
    await _saveBabies(prefs, babies);
    return updated;
  }

  Future<void> deleteBaby(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final babies = await _loadBabies(prefs);

    final next = babies.where((b) => b.id != id).toList();
    if (next.length == babies.length) return;

    await _saveBabies(prefs, next);
  }

  Future<List<BabyProfile>> _loadBabies(SharedPreferences prefs) async {
    final raw = prefs.getString(_storeKey);
    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const FormatException('Expected a list of babies.');
      }

      return decoded.map((e) {
        if (e is! Map) {
          throw const FormatException('Invalid baby payload.');
        }
        return BabyProfile.fromJson(Map<String, dynamic>.from(e));
      }).toList();
    } catch (e) {
      throw ApiException(
        type: ApiErrorType.invalidResponse,
        message: 'Failed to load saved baby profiles.',
        details: e.toString(),
      );
    }
  }

  Future<void> _saveBabies(
    SharedPreferences prefs,
    List<BabyProfile> babies,
  ) async {
    final payload = babies.map((b) => b.toJson()).toList();
    final raw = jsonEncode(payload);
    final ok = await prefs.setString(_storeKey, raw);
    if (!ok) {
      throw const ApiException(
        type: ApiErrorType.storage,
        message: 'Failed to save baby profiles.',
      );
    }
  }

  int _nextId(List<BabyProfile> babies) {
    if (babies.isEmpty) return 1;
    final maxId = babies.map((b) => b.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  String? _nullIfEmpty(String? s) {
    final v = (s ?? '').trim();
    return v.isEmpty ? null : v;
  }
}

enum ApiErrorType { storage, invalidResponse, notFound, unknown }

class ApiException implements Exception {
  final ApiErrorType type;
  final String message;
  final String? details;

  const ApiException({
    required this.type,
    required this.message,
    this.details,
  });

  @override
  String toString() {
    final d = (details == null || details!.trim().isEmpty) ? '' : '\n$details';
    return '$message$d';
  }
}
