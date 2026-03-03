import 'package:neomama/models/daily_signals.dart';
import 'package:neomama/models/tip_models.dart';
import 'package:neomama/services/daily_signals_service.dart';
import 'package:neomama/core/config/route_names.dart';
import 'package:neomama/l10n/app_strings.dart';

import 'package:neomama/features/vaccinations/data/vaccinations_data.dart';
import 'package:neomama/features/vaccinations/models/vaccination_models.dart';
import 'package:neomama/features/vaccinations/vaccinations_service.dart';

class DecisionEngine {
  final DailySignalsService _signalsSvc;
  final VaccinationsService _vaccSvc;

  DecisionEngine({
    DailySignalsService? signalsService,
    VaccinationsService? vaccinationsService,
  })  : _signalsSvc = signalsService ?? DailySignalsService(),
        _vaccSvc = vaccinationsService ?? VaccinationsService();

  Future<List<TipItem>> buildDecisions({
    required String babyKey,
    required String? babyDobIso,
    DailySignals? signals,
    String localeCode = 'en',
  }) async {
    final s = signals ?? await _signalsSvc.load(babyKey);
    final dob = _safeParseDate(babyDobIso);
    final out = <TipItem>[];

    if (s.sleepRestless) {
      out.add(TipItem(
        id: 'decision_sleep_low',
        type: TipType.reminder,
        title: _s(localeCode, 'decision_sleep_low_title'),
        body: _s(localeCode, 'decision_sleep_low_body'),
        reason: _s(localeCode, 'decision_sleep_low_reason'),
        ctaLabel: _s(localeCode, 'decision_sleep_low_action'),
        priority: 5,
      ));
    }

    if (s.newFood && s.skinRash) {
      out.add(TipItem(
        id: 'decision_new_food_rash',
        type: TipType.warning,
        title: _s(localeCode, 'decision_new_food_rash_title'),
        body: _s(localeCode, 'decision_new_food_rash_body'),
        reason: _s(localeCode, 'decision_new_food_rash_reason'),
        ctaLabel: _s(localeCode, 'decision_new_food_rash_action'),
        priority: 9,
      ));
    }

    if (s.feedingHard) {
      out.add(TipItem(
        id: 'decision_feeding_hard',
        type: TipType.reminder,
        title: _s(localeCode, 'decision_feeding_hard_title'),
        body: _s(localeCode, 'decision_feeding_hard_body'),
        reason: _s(localeCode, 'decision_feeding_hard_reason'),
        ctaLabel: _s(localeCode, 'decision_feeding_hard_action'),
        priority: 6,
      ));
    }

    if (s.teethingSymptoms) {
      out.add(TipItem(
        id: 'decision_teething',
        type: TipType.info,
        title: _s(localeCode, 'decision_teething_title'),
        body: _s(localeCode, 'decision_teething_body'),
        reason: _s(localeCode, 'decision_teething_reason'),
        ctaLabel: _s(localeCode, 'decision_teething_action'),
        ctaRoute: RouteNames.teething,
        priority: 4,
      ));
    }

    final vaccAction = await _vaccinationDecision(
      babyKey: babyKey,
      dob: dob,
      localeCode: localeCode,
    );
    if (vaccAction != null) out.add(vaccAction);

    if (out.isEmpty) {
      out.add(TipItem(
        id: 'decision_routine',
        type: TipType.info,
        title: _s(localeCode, 'decision_routine_title'),
        body: _s(localeCode, 'decision_routine_body'),
        reason: _s(localeCode, 'decision_routine_reason'),
        ctaLabel: _s(localeCode, 'decision_routine_action'),
        priority: 1,
      ));
    }

    out.sort((a, b) => b.priority.compareTo(a.priority));
    return out.take(3).toList();
  }

  Future<TipItem?> _vaccinationDecision({
    required String babyKey,
    required DateTime? dob,
    required String localeCode,
  }) async {
    if (dob == null) return null;

    final state = await _vaccSvc.load(babyKey);
    final items = vaccinationsDataFor(localeCode);
    final next = _nextVaccine(items, state);
    if (next == null) return null;

    final months = _monthGroupToInt(_vaccMonthGroup(next));
    if (months <= 0) return null;

    final due = _addMonths(dob, months);
    final daysUntil = _daysUntil(due);
    if (daysUntil < 0 || daysUntil > 30) return null;

    return TipItem(
      id: 'decision_vacc_due_${next.id}',
      type: TipType.warning,
      title: _s(localeCode, 'decision_vacc_due_title'),
      body: _s(
        localeCode,
        'decision_vacc_due_body',
        vars: {'title': next.title, 'date': _fmtDate(due)},
      ),
      reason: _s(localeCode, 'decision_vacc_due_reason'),
      ctaLabel: _s(localeCode, 'decision_vacc_due_action'),
      ctaRoute: RouteNames.vaccinations,
      priority: 8,
    );
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

  String _vaccMonthGroup(VaccinationItem v) => v.monthLabel;

  int _monthGroupToInt(String label) {
    final s = label.trim();
    if (s.isEmpty) return 0;
    final m1 = RegExp(r'^(\d+)').firstMatch(s);
    if (m1 != null) return int.tryParse(m1.group(1)!) ?? 0;
    final m2 = RegExp(r'(\d+)').firstMatch(s);
    if (m2 != null) return int.tryParse(m2.group(1)!) ?? 0;
    return 0;
  }
}
