import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:neomama/models/behavioral_notification.dart';
import 'package:neomama/models/daily_signals.dart';
import 'package:neomama/models/tip_models.dart';
import 'package:neomama/services/daily_signals_service.dart';
import 'package:neomama/l10n/app_strings.dart';
import 'package:neomama/features/vaccinations/data/vaccinations_data.dart';
import 'package:neomama/features/vaccinations/models/vaccination_models.dart';
import 'package:neomama/features/vaccinations/vaccinations_service.dart';

class BehavioralNotificationsService {
  static const _keyPrefix = 'behavioral_nudges_v1:';

  final DailySignalsService _signalsSvc;
  final VaccinationsService _vaccSvc;

  BehavioralNotificationsService({
    DailySignalsService? signalsService,
    VaccinationsService? vaccinationsService,
  })  : _signalsSvc = signalsService ?? DailySignalsService(),
        _vaccSvc = vaccinationsService ?? VaccinationsService();

  Future<List<BehavioralNotification>> build({
    required String babyKey,
    required String? babyDobIso,
    DailySignals? signals,
    String localeCode = 'en',
  }) async {
    final now = DateTime.now();
    final s = signals ?? await _signalsSvc.load(babyKey);
    final dob = _safeParseDate(babyDobIso);
    final sent = await _loadSent(babyKey);
    final out = <BehavioralNotification>[];

    bool canSend(String id, int cooldownHours) {
      final last = sent[id];
      if (last == null) return true;
      return now.difference(last).inHours >= cooldownHours;
    }

    if (s.sleepRestless && canSend('nudge_sleep', 18)) {
      final scheduledAt = _nextWindowTime(now, 18, 21);
      out.add(
        BehavioralNotification(
          id: 'nudge_sleep',
          type: TipType.reminder,
          title: _s(localeCode, 'nudge_sleep_title'),
          body: _s(localeCode, 'nudge_sleep_body'),
          reason: _s(localeCode, 'nudge_sleep_reason'),
          ctaLabel: _s(localeCode, 'nudge_sleep_action'),
          scheduledAt: scheduledAt,
          priority: 6,
        ),
      );
    }

    if (s.newFood && s.skinRash && canSend('nudge_new_food_rash', 24)) {
      final scheduledAt = _soon(now, minutes: 1);
      out.add(
        BehavioralNotification(
          id: 'nudge_new_food_rash',
          type: TipType.warning,
          title: _s(localeCode, 'nudge_new_food_rash_title'),
          body: _s(localeCode, 'nudge_new_food_rash_body'),
          reason: _s(localeCode, 'nudge_new_food_rash_reason'),
          ctaLabel: _s(localeCode, 'nudge_new_food_rash_action'),
          scheduledAt: scheduledAt,
          priority: 10,
        ),
      );
    }

    if (s.feedingHard && canSend('nudge_feeding', 12)) {
      final scheduledAt = _nextWindowTime(now, 10, 18);
      out.add(
        BehavioralNotification(
          id: 'nudge_feeding',
          type: TipType.reminder,
          title: _s(localeCode, 'nudge_feeding_title'),
          body: _s(localeCode, 'nudge_feeding_body'),
          reason: _s(localeCode, 'nudge_feeding_reason'),
          ctaLabel: _s(localeCode, 'nudge_feeding_action'),
          scheduledAt: scheduledAt,
          priority: 5,
        ),
      );
    }

    if (s.teethingSymptoms && canSend('nudge_teething', 12)) {
      final scheduledAt = _nextWindowTime(now, 15, 20);
      out.add(
        BehavioralNotification(
          id: 'nudge_teething',
          type: TipType.info,
          title: _s(localeCode, 'nudge_teething_title'),
          body: _s(localeCode, 'nudge_teething_body'),
          reason: _s(localeCode, 'nudge_teething_reason'),
          ctaLabel: _s(localeCode, 'nudge_teething_action'),
          scheduledAt: scheduledAt,
          priority: 4,
        ),
      );
    }

    final vacc = await _vaccinationNudge(
      babyKey: babyKey,
      dob: dob,
      localeCode: localeCode,
      canSend: canSend,
    );
    if (vacc != null) out.add(vacc);

    out.sort((a, b) => b.priority.compareTo(a.priority));
    return out.take(3).toList();
  }

  Future<void> markSent(String babyKey, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final map = await _loadSent(babyKey);
    map[id] = DateTime.now();
    final payload = <String, String>{};
    map.forEach((k, v) => payload[k] = v.toIso8601String());
    await prefs.setString(_key(babyKey), jsonEncode(payload));
  }

  Future<Map<String, DateTime>> _loadSent(String babyKey) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(babyKey));
    if (raw == null || raw.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final out = <String, DateTime>{};
      decoded.forEach((k, v) {
        if (k == null || v == null) return;
        final d = DateTime.tryParse(v.toString());
        if (d != null) out[k.toString()] = d;
      });
      return out;
    } catch (_) {
      return {};
    }
  }

  Future<BehavioralNotification?> _vaccinationNudge({
    required String babyKey,
    required DateTime? dob,
    required String localeCode,
    required bool Function(String id, int cooldownHours) canSend,
  }) async {
    if (dob == null) return null;
    final state = await _vaccSvc.load(babyKey);
    final items = vaccinationsDataFor(localeCode);
    final next = _nextVaccine(items, state);
    if (next == null) return null;

    final months = next.dueMonth;
    if (months <= 0) return null;

    final due = _addMonths(dob, months);
    final daysUntil = _daysUntil(due);
    if (daysUntil < 0 || daysUntil > 14) return null;

    if (!_within(DateTime.now(), 8, 11)) return null;
    if (!canSend('nudge_vacc_${next.id}', 48)) return null;

    return BehavioralNotification(
      id: 'nudge_vacc_${next.id}',
      type: TipType.warning,
      title: _s(localeCode, 'nudge_vacc_title'),
      body: _s(
        localeCode,
        'nudge_vacc_body',
        vars: {'title': next.title, 'date': _fmtDate(due)},
      ),
      reason: _s(localeCode, 'nudge_vacc_reason'),
      ctaLabel: _s(localeCode, 'nudge_vacc_action'),
      scheduledAt: _nextWindowTime(DateTime.now(), 8, 11),
      priority: 7,
    );
  }

  VaccinationItem? _nextVaccine(
    List<VaccinationItem> items,
    Map<String, VaccinationState> state,
  ) {
    final sortedItems = [...items];
    sortedItems.sort((a, b) => a.dueMonth.compareTo(b.dueMonth));
    for (final v in sortedItems) {
      final st = state[v.id] ?? const VaccinationState(done: false);
      if (!st.done) return v;
    }
    return null;
  }

  String _s(String code, String key, {Map<String, String>? vars}) {
    return AppStrings.byCode(code, key, vars: vars);
  }

  DateTime? _safeParseDate(String? iso) {
    if (iso == null) return null;
    final s = iso.trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  DateTime _addMonths(DateTime d, int months) {
    final y = d.year + ((d.month - 1 + months) ~/ 12);
    final m = ((d.month - 1 + months) % 12) + 1;
    final lastDay = DateTime(y, m + 1, 0).day;
    final day = d.day > lastDay ? lastDay : d.day;
    return DateTime(y, m, day);
  }

  int _daysUntil(DateTime due) {
    final today = DateTime.now();
    final d0 = DateTime(today.year, today.month, today.day);
    final d1 = DateTime(due.year, due.month, due.day);
    return d1.difference(d0).inDays;
  }

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  bool _within(DateTime now, int startHour, int endHour) {
    final h = now.hour;
    if (startHour <= endHour) {
      return h >= startHour && h < endHour;
    }
    return h >= startHour || h < endHour;
  }

  DateTime _soon(DateTime now, {int minutes = 1}) {
    final t = now.add(Duration(minutes: minutes));
    return t;
  }

  DateTime _nextWindowTime(DateTime now, int startHour, int endHour) {
    if (_within(now, startHour, endHour)) {
      return _soon(now, minutes: 1);
    }
    final start = DateTime(now.year, now.month, now.day, startHour);
    if (start.isAfter(now)) return start;
    return start.add(const Duration(days: 1));
  }

  String _key(String babyKey) => '$_keyPrefix$babyKey';
}
