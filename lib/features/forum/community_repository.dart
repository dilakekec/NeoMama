import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'community_models.dart';
import 'community_seed.dart';

class CommunityRepository {
  static const _expPrefix = 'community_exp_v1:';
  static const _votesKey = 'community_votes_v1';

  Future<List<CommunityRoom>> loadRooms(String code) async {
    final rooms = communityRoomsFor(code);
    final votes = await _loadVotes();

    final out = <CommunityRoom>[];
    for (final room in rooms) {
      final stored = await _loadExperiences(room.id);
      final merged = [
        ...room.experiences,
        ...stored,
      ];

      final adjusted = merged.map((e) {
        final v = votes[e.id] ?? e.workedCount;
        return e.copyWith(workedCount: v);
      }).toList();

      out.add(room.copyWith(experiences: adjusted));
    }

    return out;
  }

  Future<CommunityRoom?> loadRoom(String id, String code) async {
    final rooms = await loadRooms(code);
    for (final r in rooms) {
      if (r.id == id) return r;
    }
    return null;
  }

  Future<void> addExperience(String roomId, CommunityExperience exp) async {
    final current = await _loadExperiences(roomId);
    current.insert(0, exp);
    await _saveExperiences(roomId, current);
  }

  Future<void> voteWorked(String expId) async {
    final votes = await _loadVotes();
    votes[expId] = (votes[expId] ?? 0) + 1;
    await _saveVotes(votes);
  }

  Future<List<CommunityExperience>> _loadExperiences(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_expPrefix$roomId');
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => CommunityExperience.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveExperiences(
    String roomId,
    List<CommunityExperience> list,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = list.map((e) => e.toJson()).toList();
    await prefs.setString('$_expPrefix$roomId', jsonEncode(payload));
  }

  Future<Map<String, int>> _loadVotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_votesKey);
    if (raw == null || raw.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final out = <String, int>{};
      decoded.forEach((k, v) {
        if (k == null) return;
        if (v is num) out[k.toString()] = v.toInt();
      });
      return out;
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveVotes(Map<String, int> votes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_votesKey, jsonEncode(votes));
  }
}
