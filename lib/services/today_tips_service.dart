import 'package:neomama/models/daily_signals.dart';
import 'package:neomama/models/tip_models.dart';
import 'package:neomama/models/tomorrow_preview.dart';

import 'package:neomama/features/vaccinations/data/vaccinations_data.dart';
import 'package:neomama/features/vaccinations/models/vaccination_models.dart';
import 'package:neomama/features/vaccinations/vaccinations_service.dart';

import 'package:neomama/features/teething/data/teeth_data.dart';
import 'package:neomama/features/teething/models/teething_models.dart';
import 'package:neomama/features/teething/teething_service.dart';
import 'package:neomama/l10n/app_strings.dart';

class TodayTipsService {
  final VaccinationsService _vaccSvc;
  final TeethingService _teethSvc;

  TodayTipsService({
    VaccinationsService? vaccinationsService,
    TeethingService? teethingService,
  })  : _vaccSvc = vaccinationsService ?? VaccinationsService(),
        _teethSvc = teethingService ?? TeethingService();

  Future<List<TipItem>> buildTips({
    required String babyKey,
    required String? babyDobIso,
    DailySignals? signals,
    String localeCode = 'en',
  }) async {
    final tips = <TipItem>[];
    final dob = _safeParseDate(babyDobIso);

    try {
      final s = signals ?? DailySignals.empty;

      final results = await Future.wait([
        _vaccSvc.load(babyKey),
        _teethSvc.load(babyKey),
      ]);

      final vaccState = results[0] is Map<String, VaccinationState>
          ? (results[0] as Map<String, VaccinationState>)
          : <String, VaccinationState>{};

      final teethState = results[1] is Map<String, ToothState>
          ? (results[1] as Map<String, ToothState>)
          : <String, ToothState>{};

      final items = vaccinationsDataFor(localeCode);

      tips.addAll(_signalTips(s, localeCode: localeCode));

      final vaccTip = _vaccinationTip(
        dob: dob,
        state: vaccState,
        items: items,
        localeCode: localeCode,
      );
      if (vaccTip != null) tips.add(vaccTip);

      final teethTip = _teethingTip(state: teethState, localeCode: localeCode);
      if (teethTip != null) tips.add(teethTip);

      if (tips.length < 3) {
        tips.addAll(_genericTips(dob: dob, already: tips, localeCode: localeCode));
      }

      tips.sort((a, b) => _typeRank(b.type).compareTo(_typeRank(a.type)));

      return _uniqueById(tips).take(3).toList();
    } catch (_) {
      return _genericTips(dob: dob, already: tips, localeCode: localeCode)
          .take(3)
          .toList();
    }
  }

  Future<TomorrowPreview?> buildTomorrowPreview({
    required String babyKey,
    required String? babyDobIso,
    String localeCode = 'en',
  }) async {
    final dob = _safeParseDate(babyDobIso);

    try {
      final results = await Future.wait([
        _vaccSvc.load(babyKey),
        _teethSvc.load(babyKey),
      ]);

      final vaccState = results[0] is Map<String, VaccinationState>
          ? (results[0] as Map<String, VaccinationState>)
          : <String, VaccinationState>{};

      final teethState = results[1] is Map<String, ToothState>
          ? (results[1] as Map<String, ToothState>)
          : <String, ToothState>{};

      final items = vaccinationsDataFor(localeCode);
      final nextVacc = _nextVaccine(items, vaccState);
      if (nextVacc != null && dob != null) {
        final months = _monthGroupToInt(_vaccMonthGroup(nextVacc));
        if (months > 0) {
          final due = _addMonths(dob, months);
          final daysUntil = _daysUntil(due);
          if (daysUntil >= 0 && daysUntil <= 14) {
            return TomorrowPreview(
              title: _s(localeCode, 'tomorrow_focus'),
              body: _s(
                localeCode,
                'tomorrow_vaccine_soon',
                vars: {'title': _vaccTitle(nextVacc), 'date': _fmtDate(due)},
              ),
              reason: _s(localeCode, 'tomorrow_reason_vacc_estimate'),
            );
          }
        }
      }

      final latestTooth = _latestToothDate(teethState);
      if (latestTooth != null) {
        final daysAgo = _daysAgo(latestTooth);
        if (daysAgo >= 0 && daysAgo <= 7) {
          return TomorrowPreview(
            title: _s(localeCode, 'tomorrow_focus'),
            body: _s(localeCode, 'tomorrow_teething'),
            reason: _s(localeCode, 'tomorrow_reason_teeth_recent'),
          );
        }
      }
    } catch (_) {
      return TomorrowPreview(
        title: _s(localeCode, 'tomorrow_focus'),
        body: _s(localeCode, 'tomorrow_generic'),
        reason: _s(localeCode, 'tomorrow_reason_none'),
      );
    }

    return TomorrowPreview(
      title: _s(localeCode, 'tomorrow_focus'),
      body: _s(localeCode, 'tomorrow_generic'),
      reason: _s(localeCode, 'tomorrow_reason_none'),
    );
  }

  
  
  

  List<TipItem> _signalTips(DailySignals s, {required String localeCode}) {
    final out = <TipItem>[];

    if (s.sleepRestless) {
      out.add(TipItem(
        id: 'signal_sleep_restless',
        type: TipType.warning,
        title: _s(localeCode, 'tip_sleep_restless_title'),
        body: _s(localeCode, 'tip_sleep_restless_body'),
        reason: _s(localeCode, 'tip_sleep_restless_reason'),
      ));
    }

    if (s.feedingHard) {
      out.add(TipItem(
        id: 'signal_feeding_hard',
        type: TipType.reminder,
        title: _s(localeCode, 'tip_feeding_hard_title'),
        body: _s(localeCode, 'tip_feeding_hard_body'),
        reason: _s(localeCode, 'tip_feeding_hard_reason'),
      ));
    }

    if (s.teethingSymptoms) {
      out.add(TipItem(
        id: 'signal_teething_symptoms',
        type: TipType.warning,
        title: _s(localeCode, 'tip_teething_symptoms_title'),
        body: _s(localeCode, 'tip_teething_symptoms_body'),
        reason: _s(localeCode, 'tip_teething_symptoms_reason'),
      ));
    }

    return out;
  }

  
  
  

  TipItem? _vaccinationTip({
    required DateTime? dob,
    required Map<String, VaccinationState> state,
    required List<VaccinationItem> items,
    required String localeCode,
  }) {
    if (items.isEmpty) return null;

    final next = _nextVaccine(items, state);
    if (next == null) {
      return TipItem(
        id: 'vacc_all_done',
        type: TipType.info,
        title: _s(localeCode, 'tip_vacc_all_done_title'),
        body: _s(localeCode, 'tip_vacc_all_done_body'),
        reason: _s(localeCode, 'tip_vacc_all_done_reason'),
      );
    }

    final group = _vaccMonthGroup(next);

    if (dob == null) {
      return TipItem(
        id: 'vacc_next_unknown_dob',
        type: TipType.reminder,
        title: _s(localeCode, 'tip_vacc_next_title'),
        body: _s(
          localeCode,
          'tip_vacc_next_body',
          vars: {'title': _vaccTitle(next), 'group': group},
        ),
        reason: _s(localeCode, 'tip_vacc_missing_dob'),
      );
    }

    final months = _monthGroupToInt(group);
    if (months <= 0) {
      return TipItem(
        id: 'vacc_next_${_vaccId(next)}',
        type: TipType.info,
        title: _s(localeCode, 'tip_vacc_next_title'),
        body: _s(
          localeCode,
          'tip_vacc_next_body',
          vars: {'title': _vaccTitle(next), 'group': group},
        ),
        reason: _s(localeCode, 'tip_vacc_group_parse'),
      );
    }

    final due = _addMonths(dob, months);
    final daysUntil = _daysUntil(due);

    if (daysUntil < 0) {
      return TipItem(
        id: 'vacc_overdue_${_vaccId(next)}',
        type: TipType.warning,
        title: _s(localeCode, 'tip_vacc_due_title'),
        body: _s(
          localeCode,
          'tip_vacc_due_body',
          vars: {'title': _vaccTitle(next), 'date': _fmtDate(due)},
        ),
        reason: _s(localeCode, 'tip_vacc_due_reason'),
      );
    }

    if (daysUntil <= 14) {
      return TipItem(
        id: 'vacc_soon_${_vaccId(next)}',
        type: TipType.reminder,
        title: _s(localeCode, 'tip_vacc_soon_title'),
        body: _s(
          localeCode,
          'tip_vacc_soon_body',
          vars: {'title': _vaccTitle(next), 'date': _fmtDate(due)},
        ),
        reason: _s(localeCode, 'tip_vacc_soon_reason'),
      );
    }

    return TipItem(
      id: 'vacc_next_${_vaccId(next)}',
      type: TipType.info,
      title: _s(localeCode, 'tip_vacc_next_title'),
      body: _s(
        localeCode,
        'tip_vacc_next_date_body',
        vars: {'title': _vaccTitle(next), 'date': _fmtDate(due)},
      ),
      reason: _s(localeCode, 'tip_vacc_due_reason'),
    );
  }

  
  
  Object? _nextVaccine(
    List<VaccinationItem> items,
    Map<String, VaccinationState> state,
  ) {
    final sortedItems = [...items];

    sortedItems.sort((a, b) {
      final am = _monthGroupToInt(_vaccMonthGroup(a));
      final bm = _monthGroupToInt(_vaccMonthGroup(b));
      return am.compareTo(bm);
    });

    for (final v in sortedItems) {
      final id = _vaccId(v);
      final st = state[id] ?? const VaccinationState(done: false);
      if (!st.done) return v;
    }
    return null;
  }

  
  
  

  TipItem? _teethingTip({
    required Map<String, ToothState> state,
    required String localeCode,
  }) {
    final erupted = state.values.where((s) => s.erupted).length;
    final total = kPrimaryTeeth.length;

    if (state.isEmpty) {
      return TipItem(
        id: 'teeth_empty',
        type: TipType.info,
        title: _s(localeCode, 'tip_teeth_empty_title'),
        body: _s(localeCode, 'tip_teeth_empty_body'),
        reason: _s(localeCode, 'tip_teeth_empty_reason'),
      );
    }

    final latest = _latestToothDate(state);
    if (latest != null) {
      final daysAgo = _daysAgo(latest);
      if (daysAgo >= 0 && daysAgo <= 7) {
        return TipItem(
          id: 'teeth_recent',
          type: TipType.warning,
          title: _s(localeCode, 'tip_teeth_recent_title'),
          body: _s(localeCode, 'tip_teeth_recent_body'),
          reason: _s(localeCode, 'tip_teeth_recent_reason'),
        );
      }
    }

    return TipItem(
      id: 'teeth_progress',
      type: TipType.info,
      title: _s(localeCode, 'tip_teeth_progress_title'),
      body: _s(
        localeCode,
        'tip_teeth_progress_body',
        vars: {'erupted': '$erupted', 'total': '$total'},
      ),
      reason: _s(localeCode, 'tip_teeth_progress_reason'),
    );
  }

  DateTime? _latestToothDate(Map<String, ToothState> state) {
    DateTime? best;
    for (final s in state.values) {
      final d = _safeParseDate(s.dateIso);
      if (d == null) continue;
      if (best == null || d.isAfter(best)) best = d;
    }
    return best;
  }

  
  
  

  List<TipItem> _genericTips({
    required DateTime? dob,
    required List<TipItem> already,
    required String localeCode,
  }) {
    final out = <TipItem>[];
    final months = (dob == null) ? null : _ageInMonths(dob, DateTime.now());

    if (months == null) {
      out.add(TipItem(
        id: 'gen_routine',
        type: TipType.info,
        title: _s(localeCode, 'tip_gen_routine_title'),
        body: _s(localeCode, 'tip_gen_routine_body'),
        reason: _s(localeCode, 'tip_gen_routine_reason'),
      ));
      out.add(TipItem(
        id: 'gen_hygiene',
        type: TipType.reminder,
        title: _s(localeCode, 'tip_gen_hygiene_title'),
        body: _s(localeCode, 'tip_gen_hygiene_body'),
        reason: _s(localeCode, 'tip_gen_hygiene_reason'),
      ));
      return _dedupe(out, already);
    }

    if (months < 6) {
      out.add(TipItem(
        id: 'm_lt6_feeds',
        type: TipType.info,
        title: _s(localeCode, 'tip_lt6_feed_title'),
        body: _s(localeCode, 'tip_lt6_feed_body'),
        reason: _s(localeCode, 'tip_lt6_feed_reason'),
      ));
      out.add(TipItem(
        id: 'm_lt6_sleep',
        type: TipType.reminder,
        title: _s(localeCode, 'tip_lt6_sleep_title'),
        body: _s(localeCode, 'tip_lt6_sleep_body'),
        reason: _s(localeCode, 'tip_lt6_sleep_reason'),
      ));
    } else if (months < 12) {
      out.add(TipItem(
        id: 'm_lt12_textures',
        type: TipType.info,
        title: _s(localeCode, 'tip_lt12_texture_title'),
        body: _s(localeCode, 'tip_lt12_texture_body'),
        reason: _s(localeCode, 'tip_lt12_texture_reason'),
      ));
      out.add(TipItem(
        id: 'm_lt12_winddown',
        type: TipType.reminder,
        title: _s(localeCode, 'tip_lt12_winddown_title'),
        body: _s(localeCode, 'tip_lt12_winddown_body'),
        reason: _s(localeCode, 'tip_lt12_winddown_reason'),
      ));
    } else {
      out.add(TipItem(
        id: 'm_ge12_play',
        type: TipType.info,
        title: _s(localeCode, 'tip_ge12_play_title'),
        body: _s(localeCode, 'tip_ge12_play_body'),
        reason: _s(localeCode, 'tip_ge12_play_reason'),
      ));
      out.add(TipItem(
        id: 'm_ge12_move',
        type: TipType.reminder,
        title: _s(localeCode, 'tip_ge12_move_title'),
        body: _s(localeCode, 'tip_ge12_move_body'),
        reason: _s(localeCode, 'tip_ge12_move_reason'),
      ));
    }

    return _dedupe(out, already);
  }

  List<TipItem> _dedupe(List<TipItem> items, List<TipItem> already) {
    final existing = already.map((e) => e.id).toSet();
    return items.where((x) => !existing.contains(x.id)).toList();
  }

  
  
  

  int _typeRank(TipType t) {
    switch (t) {
      case TipType.warning:
        return 3;
      case TipType.reminder:
        return 2;
      case TipType.info:
        return 1;
    }
  }

  List<TipItem> _uniqueById(List<TipItem> items) {
    final seen = <String>{};
    final out = <TipItem>[];
    for (final x in items) {
      if (seen.add(x.id)) out.add(x);
    }
    return out;
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

  int _ageInMonths(DateTime dob, DateTime now) {
    var m = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) m -= 1;
    return m < 0 ? 0 : m;
  }

  DateTime _addMonths(DateTime d, int months) {
    final y = d.year + ((d.month - 1 + months) ~/ 12);
    final m = ((d.month - 1 + months) % 12) + 1;
    final lastDay = DateTime(y, m + 1, 0).day;
    final day = d.day > lastDay ? lastDay : d.day;
    return DateTime(y, m, day);
  }

  int _daysUntil(DateTime due) {
    final today = _dayOnly(DateTime.now());
    final d = _dayOnly(due);
    return d.difference(today).inDays;
  }

  int _daysAgo(DateTime date) {
    final today = _dayOnly(DateTime.now());
    final d = _dayOnly(date);
    return today.difference(d).inDays;
  }

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  int _monthGroupToInt(String label) {
    
    final s = label.trim();
    if (s.isEmpty) return 0;

    final m1 = RegExp(r'^(\d+)').firstMatch(s);
    if (m1 != null) return int.tryParse(m1.group(1)!) ?? 0;

    final m2 = RegExp(r'(\d+)').firstMatch(s);
    if (m2 != null) return int.tryParse(m2.group(1)!) ?? 0;

    return 0;
  }

  
  
  

  String _vaccId(Object v) {
    final d = v as dynamic;
    final id = d.id;
    return id == null ? '' : id.toString();
  }

  String _vaccTitle(Object v) {
    final d = v as dynamic;
    final title = d.title;
    return title == null ? 'Vaccine' : title.toString();
  }

  String _vaccMonthGroup(Object v) {
    final d = v as dynamic;

    
    final g =
        d.monthGroup ?? d.monthGroupLabel ?? d.group ?? d.month ?? d.monthLabel;
    return g == null ? '' : g.toString();
  }
}
