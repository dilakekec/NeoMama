import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:neomama/models/baby_profile.dart';
import 'package:neomama/models/behavioral_notification.dart';
import 'package:neomama/models/daily_signals.dart';
import 'package:neomama/models/tip_models.dart';
import 'package:neomama/models/tomorrow_preview.dart';
import 'package:neomama/data/monthly_development_data.dart';
import 'package:neomama/features/growth/growth_service.dart';
import 'package:neomama/features/growth/models/growth_entry.dart';
import 'package:neomama/features/teething/models/teething_models.dart';
import 'package:neomama/features/teething/teething_service.dart';
import 'package:neomama/services/behavioral_notifications_service.dart';
import 'package:neomama/services/daily_signals_service.dart';
import 'package:neomama/services/decision_engine.dart';
import 'package:neomama/services/local_notifications_service.dart';
import 'package:neomama/services/today_tips_service.dart';

import 'package:neomama/widgets/baby_avatar.dart';
import 'package:neomama/widgets/daily_signals_row.dart';
import 'package:neomama/widgets/today_tips_card.dart';
import 'package:neomama/widgets/tomorrow_preview_card.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/config/route_names.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class DashboardScreen extends StatefulWidget {
  final BabyProfile baby;
  const DashboardScreen({super.key, required this.baby});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final TodayTipsService _tipsSvc;
  late final DecisionEngine _decisionEngine;
  late final BehavioralNotificationsService _nudgeSvc;
  late final DailySignalsService _signalsSvc;
  late final GrowthService _growthSvc;
  late final TeethingService _teethSvc;
  late Future<List<TipItem>> _tipsFuture;
  late Future<TomorrowPreview?> _tomorrowFuture;
  late Future<List<TipItem>> _decisionFuture;
  late Future<List<BehavioralNotification>> _nudgesFuture;
  late Future<_TodayPanelData> _todayPanelFuture;
  String _localeCode = 'en';
  DailySignals _signals = DailySignals.empty;
  bool _signalsReady = false;

  String get _babyKey => widget.baby.id.toString();

  @override
  void initState() {
    super.initState();
    _tipsSvc = TodayTipsService();
    _decisionEngine = DecisionEngine();
    _nudgeSvc = BehavioralNotificationsService();
    _signalsSvc = DailySignalsService();
    _growthSvc = GrowthService();
    _teethSvc = TeethingService();

    final dobIso = _dobIso(widget.baby.birthDate);

    _tipsFuture = _tipsSvc.buildTips(
      babyKey: _babyKey,
      babyDobIso: dobIso,
      localeCode: _localeCode,
    );

    _tomorrowFuture = _tipsSvc.buildTomorrowPreview(
      babyKey: _babyKey,
      babyDobIso: dobIso,
      localeCode: _localeCode,
    );

    _decisionFuture = _decisionEngine.buildDecisions(
      babyKey: _babyKey,
      babyDobIso: dobIso,
      localeCode: _localeCode,
      signals: _signals,
    );

    _nudgesFuture = _nudgeSvc.build(
      babyKey: _babyKey,
      babyDobIso: dobIso,
      localeCode: _localeCode,
      signals: _signals,
    );

    _todayPanelFuture = _buildTodayPanel();

    _loadSignals();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = Localizations.localeOf(context).languageCode;
    if (code == _localeCode) return;
    _localeCode = code;
    final dobIso = _dobIso(widget.baby.birthDate);
    setState(() {
      _tipsFuture = _tipsSvc.buildTips(
        babyKey: _babyKey,
        babyDobIso: dobIso,
        localeCode: _localeCode,
      );
      _tomorrowFuture = _tipsSvc.buildTomorrowPreview(
        babyKey: _babyKey,
        babyDobIso: dobIso,
        localeCode: _localeCode,
      );
      _decisionFuture = _decisionEngine.buildDecisions(
        babyKey: _babyKey,
        babyDobIso: dobIso,
        localeCode: _localeCode,
        signals: _signals,
      );
      _nudgesFuture = _nudgeSvc.build(
        babyKey: _babyKey,
        babyDobIso: dobIso,
        localeCode: _localeCode,
        signals: _signals,
      );
      _todayPanelFuture = _buildTodayPanel();
    });
  }

  Future<void> _loadSignals() async {
    final s = await _signalsSvc.load(_babyKey);
    if (!mounted) return;
    setState(() {
      _signals = s;
      _signalsReady = true;
      _decisionFuture = _decisionEngine.buildDecisions(
        babyKey: _babyKey,
        babyDobIso: _dobIso(widget.baby.birthDate),
        localeCode: _localeCode,
        signals: _signals,
      );
      _nudgesFuture = _nudgeSvc.build(
        babyKey: _babyKey,
        babyDobIso: _dobIso(widget.baby.birthDate),
        localeCode: _localeCode,
        signals: _signals,
      );
      _todayPanelFuture = _buildTodayPanel();
    });
  }

  void _updateSignals(DailySignals next) {
    setState(() {
      _signals = next;
      _decisionFuture = _decisionEngine.buildDecisions(
        babyKey: _babyKey,
        babyDobIso: _dobIso(widget.baby.birthDate),
        localeCode: _localeCode,
        signals: _signals,
      );
      _nudgesFuture = _nudgeSvc.build(
        babyKey: _babyKey,
        babyDobIso: _dobIso(widget.baby.birthDate),
        localeCode: _localeCode,
        signals: _signals,
      );
      _todayPanelFuture = _buildTodayPanel();
    });
    _signalsSvc.save(_babyKey, next);
  }

  Future<_TodayPanelData> _buildTodayPanel() async {
    final sleepTimes = await _loadSleepTimes();
    final growth = await _growthSvc.load(_babyKey);
    final teeth = await _teethSvc.load(_babyKey);
    final recentTeethDays = _recentEruptionDays(teeth);

    return _TodayPanelData(
      sleep: _sleepLine(_signals, _localeCode, sleepTimes),
      feeding: _feedingLine(_signals, _localeCode),
      development: _developmentLine(_localeCode, growth),
      attention: _attentionLine(_signals, _localeCode, recentTeethDays),
    );
  }

  String _sleepLine(
    DailySignals signals,
    String code,
    List<TimeOfDay> sleepTimes,
  ) {
    final base = AppStrings.byCode(
      code,
      signals.sleepRestless ? 'today_sleep_low' : 'today_sleep_ok',
    );

    if (sleepTimes.isEmpty) {
      final tail = AppStrings.byCode(code, 'today_sleep_no_schedule');
      return '$base $tail';
    }

    final nextTime = _nextSleepTimeLabel(sleepTimes);
    final tail = AppStrings.byCode(
      code,
      'today_sleep_next',
      vars: {'time': nextTime},
    );
    return '$base $tail';
  }

  String _feedingLine(DailySignals signals, String code) {
    if (signals.newFood && signals.skinRash) {
      return AppStrings.byCode(code, 'today_feed_rash');
    }
    if (signals.feedingHard) {
      return AppStrings.byCode(code, 'today_feed_hard');
    }
    if (signals.newFood) {
      return AppStrings.byCode(code, 'today_feed_new_food');
    }
    return AppStrings.byCode(code, 'today_feed_ok');
  }

  String _attentionLine(
    DailySignals signals,
    String code,
    int? recentTeethDays,
  ) {
    if (signals.newFood && signals.skinRash) {
      return AppStrings.byCode(code, 'today_attention_new_food_rash');
    }
    if (recentTeethDays != null && recentTeethDays <= 7) {
      return AppStrings.byCode(
        code,
        'today_attention_teeth_recent',
        vars: {'days': '$recentTeethDays'},
      );
    }
    if (signals.teethingSymptoms) {
      return AppStrings.byCode(code, 'today_attention_teething');
    }
    if (signals.sleepRestless) {
      return AppStrings.byCode(code, 'today_attention_sleep');
    }
    if (signals.feedingHard) {
      return AppStrings.byCode(code, 'today_attention_feeding');
    }
    return AppStrings.byCode(code, 'today_attention_none');
  }

  String _developmentLine(String code, List<GrowthEntry> growth) {
    final growthLine = _growthLine(code, growth);
    if (growthLine != null) return growthLine;

    final dob = _dobDate(widget.baby.birthDate);
    if (dob == null) return AppStrings.byCode(code, 'today_dev_fallback');
    final now = DateTime.now();
    final months = _ageInMonths(dob, now);
    final data = monthlyDevelopmentDataFor(code);
    if (data.isEmpty) return AppStrings.byCode(code, 'today_dev_fallback');

    int? best;
    for (final m in data.keys) {
      if (m <= months && (best == null || m > best)) {
        best = m;
      }
    }
    best ??= data.keys.reduce((a, b) => a < b ? a : b);

    final note = data[best]?.note ?? '';
    final sentence = _firstSentence(note);
    if (sentence.trim().isEmpty) {
      return AppStrings.byCode(code, 'today_dev_fallback');
    }
    return sentence;
  }

  String? _growthLine(String code, List<GrowthEntry> growth) {
    if (growth.isEmpty) return null;
    final latest = growth.last;
    final parts = <String>[];
    if (latest.weightKg != null) {
      parts.add('${latest.weightKg!.toStringAsFixed(1)} kg');
    }
    if (latest.lengthCm != null) {
      parts.add('${latest.lengthCm!.toStringAsFixed(1)} cm');
    }
    if (latest.headCircCm != null) {
      parts.add('${latest.headCircCm!.toStringAsFixed(1)} cm HC');
    }
    if (parts.isEmpty) return null;

    final date = _formatIsoDate(latest.dateIso, code);
    return AppStrings.byCode(
      code,
      'today_dev_growth',
      vars: {
        'metrics': parts.join(' · '),
        'date': date ?? latest.dateIso,
      },
    );
  }

  String? _formatIsoDate(String iso, String code) {
    final dt = DateTime.tryParse(iso.trim());
    if (dt == null) return null;
    if (code == 'tr') {
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      return '$dd.$mm.${dt.year}';
    }
    final yyyy = dt.year.toString().padLeft(4, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  Future<List<TimeOfDay>> _loadSleepTimes() async {
    const key = 'sleep_times_v1';
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(key);
    if (raw == null || raw.trim().isEmpty) return <TimeOfDay>[];

    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      final out = <TimeOfDay>[];
      for (final s in list) {
        final t = _parseTime(s);
        if (t != null) out.add(t);
      }
      out.sort(_compareTime);
      return out;
    } catch (_) {
      return <TimeOfDay>[];
    }
  }

  TimeOfDay? _parseTime(String s) {
    final parts = s.trim().split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  int _compareTime(TimeOfDay a, TimeOfDay b) {
    final am = a.hour * 60 + a.minute;
    final bm = b.hour * 60 + b.minute;
    return am.compareTo(bm);
  }

  String _nextSleepTimeLabel(List<TimeOfDay> times) {
    if (times.isEmpty) return '--:--';
    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;
    final sorted = List<TimeOfDay>.from(times)..sort(_compareTime);

    TimeOfDay? next;
    for (final t in sorted) {
      final min = t.hour * 60 + t.minute;
      if (min >= nowMin) {
        next = t;
        break;
      }
    }
    next ??= sorted.first;
    return _formatTime(next);
  }

  String _formatTime(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  int? _recentEruptionDays(Map<String, ToothState> teeth) {
    if (teeth.isEmpty) return null;
    final now = DateTime.now();
    int? best;
    for (final state in teeth.values) {
      if (!state.erupted || state.dateIso == null) continue;
      final dt = DateTime.tryParse(state.dateIso!.trim());
      if (dt == null) continue;
      final days = now.difference(dt).inDays;
      if (days < 0) continue;
      if (best == null || days < best) best = days;
    }
    return best;
  }

  int _ageInMonths(DateTime dob, DateTime now) {
    var months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) months -= 1;
    if (months < 0) return 0;
    if (months > 240) return 240;
    return months;
  }

  String _firstSentence(String text) {
    final s = text.trim();
    if (s.isEmpty) return s;
    final punct = <int>[
      s.indexOf('.'),
      s.indexOf('!'),
      s.indexOf('?'),
    ].where((i) => i > 0).toList();
    if (punct.isEmpty) return s;
    punct.sort();
    final end = punct.first + 1;
    return s.substring(0, end).trim();
  }

  List<TipItem> _nudgesToTips(List<BehavioralNotification> nudges) {
    return nudges
        .map(
          (n) => TipItem(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            reason: n.reason,
            ctaLabel: n.ctaLabel,
          ),
        )
        .toList();
  }

  String? _dobIso(Object? d) {
    if (d is DateTime) {
      String two(int n) => n.toString().padLeft(2, '0');
      return '${d.year}-${two(d.month)}-${two(d.day)}';
    }
    if (d is String) {
      final s = d.trim();
      return s.isEmpty ? null : s;
    }
    return null;
  }

  DateTime? _dobDate(Object? d) {
    if (d is DateTime) return d;
    if (d is String) {
      try {
        return DateTime.parse(d.trim());
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String _dobLabel() => _dobIso(widget.baby.birthDate) ?? '-';

  String _ageLabel() {
    final dob = _dobDate(widget.baby.birthDate);
    if (dob == null) return '-';
    final now = DateTime.now();
    final days = now.difference(dob).inDays;
    if (days < 0) return '-';

    final months = (days / 30.44).floor();
    final remDays = (days - (months * 30.44).floor()).clamp(0, 999999);

    if (months <= 0) {
      return AppStrings.t(
        context,
        'age_days',
        vars: {'days': '$days'},
      );
    }
    return AppStrings.t(
      context,
      'age_months_days',
      vars: {'months': '$months', 'days': '$remDays'},
    );
  }

  @override
  Widget build(BuildContext context) {
    final baby = widget.baby;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          title: Text(AppStrings.t(context, 'dashboard'), style: t.titleLarge),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: AppStrings.t(context, 'settings'),
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.pushNamed(
                context,
                RouteNames.settings,
                arguments: baby,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  140 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
              _BabyHeroCard(
                baby: baby,
                babyKey: _babyKey,
                dobLabel: _dobLabel(),
                ageLabel: _ageLabel(),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/baby-profile',
                  arguments: baby,
                ),
              ),

              const SizedBox(height: 12),

              FutureBuilder<_TodayPanelData>(
                future: _todayPanelFuture,
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return _TodayPanelCard(
                      baby: baby,
                      data: _TodayPanelData(
                        sleep: AppStrings.t(context, 'loading'),
                        feeding: AppStrings.t(context, 'loading'),
                        development: AppStrings.t(context, 'loading'),
                        attention: AppStrings.t(context, 'loading'),
                      ),
                    );
                  }
                  if (!snap.hasData) {
                    return const SizedBox.shrink();
                  }
                  return _TodayPanelCard(baby: baby, data: snap.data!);
                },
              ),

              const SizedBox(height: 12),

              if (_signalsReady)
                DailySignalsRow(
                  value: _signals,
                  onChanged: _updateSignals,
                ),

              if (_signalsReady) const SizedBox(height: 14),

              Text(
                AppStrings.t(context, 'nudges_title'),
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),

              FutureBuilder<List<BehavioralNotification>>(
                future: _nudgesFuture,
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return TodayTipsCard(
                      title: AppStrings.t(context, 'nudges_title'),
                      items: const <TipItem>[],
                      emptyLabel: AppStrings.t(context, 'nudges_empty'),
                    );
                  }

                  final data = snap.data ?? const <BehavioralNotification>[];
                  final nudgeMap = {
                    for (final n in data) n.id: n,
                  };
                  return TodayTipsCard(
                    title: AppStrings.t(context, 'nudges_title'),
                    items: _nudgesToTips(data),
                    emptyLabel: AppStrings.t(context, 'nudges_empty'),
                    onCta: (item) async {
                      final nudge = nudgeMap[item.id];
                      if (nudge == null) return;
                      final snackText = AppStrings.t(context, 'nudge_sent');
                      final messenger = ScaffoldMessenger.of(context);
                      await LocalNotificationsService.requestPermissions();
                      await LocalNotificationsService.scheduleNudge(nudge);
                      await _nudgeSvc.markSent(_babyKey, item.id);
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(snackText),
                        ),
                      );
                      setState(() {
                        _nudgesFuture = _nudgeSvc.build(
                          babyKey: _babyKey,
                          babyDobIso: _dobIso(widget.baby.birthDate),
                          localeCode: _localeCode,
                          signals: _signals,
                        );
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 14),

              Text(
                AppStrings.t(context, 'decision_title'),
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),

              FutureBuilder<List<TipItem>>(
                future: _decisionFuture,
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return TodayTipsCard(
                      title: AppStrings.t(context, 'decision_title'),
                      items: const <TipItem>[],
                      emptyLabel: AppStrings.t(context, 'decision_empty'),
                    );
                  }

                  if (snap.hasError) {
                    return TodayTipsCard(
                      title: AppStrings.t(context, 'decision_title'),
                      items: const <TipItem>[],
                      emptyLabel: AppStrings.t(context, 'decision_empty'),
                    );
                  }

                  return TodayTipsCard(
                    title: AppStrings.t(context, 'decision_title'),
                    items: snap.data ?? const <TipItem>[],
                    emptyLabel: AppStrings.t(context, 'decision_empty'),
                  );
                },
              ),

              const SizedBox(height: 14),

              Text(
                AppStrings.t(context, 'todays_highlights'),
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),

              FutureBuilder<List<TipItem>>(
                future: _tipsFuture,
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return TodayTipsCard(
                      title: AppStrings.t(context, 'todays_tips'),
                      items: <TipItem>[],
                    );
                  }

                  if (snap.hasError) {
                    return TodayTipsCard(
                      title: AppStrings.t(context, 'todays_tips'),
                      items: <TipItem>[
                        TipItem(
                          id: 'err',
                          type: TipType.warning,
                          title: AppStrings.t(context, 'tips_unavailable_title'),
                          body: AppStrings.t(context, 'tips_unavailable_body'),
                        ),
                      ],
                    );
                  }

                  return TodayTipsCard(
                    title: AppStrings.t(context, 'todays_tips'),
                    items: snap.data ?? const <TipItem>[],
                  );
                },
              ),

              const SizedBox(height: 12),

              FutureBuilder<TomorrowPreview?>(
                future: _tomorrowFuture,
                builder: (_, snap) {
                  if (!snap.hasData) return const SizedBox.shrink();
                  return TomorrowPreviewCard(preview: snap.data!);
                },
              ),

              const SizedBox(height: 8),

              Text(
                AppStrings.t(context, 'tap_baby_card'),
                style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BabyHeroCard extends StatelessWidget {
  final BabyProfile baby;
  final String babyKey;
  final String dobLabel;
  final String ageLabel;
  final VoidCallback onTap;

  const _BabyHeroCard({
    required this.baby,
    required this.babyKey,
    required this.dobLabel,
    required this.ageLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final name = baby.name.trim().isEmpty ? 'Baby' : baby.name.trim();

    return NeoCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BabyAvatar(babyKey: babyKey, size: 82),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.cake_outlined,
                      text:
                          '${AppStrings.t(context, 'dob')}: $dobLabel',
                      color: cs.primary,
                    ),
                    _InfoChip(
                      icon: Icons.timelapse_outlined,
                      text: ageLabel == '-'
                          ? '${AppStrings.t(context, 'age')}: -'
                          : '${AppStrings.t(context, 'age')}: $ageLabel',
                      color: cs.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.account_circle_outlined,
                        size: 18, color: cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.t(context, 'open_profile'),
                      style: t.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.o(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.o(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: t.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayPanelData {
  final String sleep;
  final String feeding;
  final String development;
  final String attention;

  const _TodayPanelData({
    required this.sleep,
    required this.feeding,
    required this.development,
    required this.attention,
  });
}

class _TodayPanelCard extends StatelessWidget {
  final BabyProfile baby;
  final _TodayPanelData data;

  const _TodayPanelCard({
    required this.baby,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return NeoCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.t(context, 'today_panel_title'),
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          _PanelRow(
            label: AppStrings.t(context, 'today_panel_sleep_label'),
            value: data.sleep,
          ),
          const SizedBox(height: 8),
          _PanelRow(
            label: AppStrings.t(context, 'today_panel_feed_label'),
            value: data.feeding,
          ),
          const SizedBox(height: 8),
          _PanelRow(
            label: AppStrings.t(context, 'today_panel_dev_label'),
            value: data.development,
          ),
          const SizedBox(height: 8),
          _PanelRow(
            label: AppStrings.t(context, 'today_panel_attention_label'),
            value: data.attention,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PanelAction(
                icon: Icons.nightlight_outlined,
                label: AppStrings.t(context, 'sleep_schedule'),
                color: cs.primary,
                onTap: () => Navigator.pushNamed(
                  context,
                  RouteNames.sleep,
                ),
              ),
              _PanelAction(
                icon: Icons.restaurant_outlined,
                label: AppStrings.t(context, 'feeding'),
                color: cs.secondary,
                onTap: () => Navigator.pushNamed(
                  context,
                  RouteNames.feeding,
                  arguments: baby,
                ),
              ),
              _PanelAction(
                icon: Icons.auto_graph_outlined,
                label: AppStrings.t(context, 'development'),
                color: cs.tertiary,
                onTap: () => Navigator.pushNamed(
                  context,
                  RouteNames.monthlyDevelopment,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PanelRow extends StatelessWidget {
  final String label;
  final String value;

  const _PanelRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: t.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: t.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _PanelAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PanelAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        foregroundColor: color,
        backgroundColor: color.o(0.12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        textStyle: t.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        shape: const StadiumBorder(),
      ),
    );
  }
}
