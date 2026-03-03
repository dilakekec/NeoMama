import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/models/baby_profile.dart';

import 'package:neomama/features/growth/growth_service.dart';
import 'package:neomama/features/growth/models/growth_entry.dart';

import 'package:neomama/features/growth/services/who_lms_loader.dart';
import 'package:neomama/features/growth/services/percentile_calc.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class GrowthScreen extends StatefulWidget {
  final BabyProfile baby;

  const GrowthScreen({super.key, required this.baby});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  int _metricIndex = 0; 
  int _maxMonth = 24;

  final _svc = GrowthService();
  final _who = WhoLmsLoader();
  final _pct = PercentileCalc();

  late Future<List<GrowthEntry>> _entriesFuture;

  
  String get _babyKey => widget.baby.id.toString();

  @override
  void initState() {
    super.initState();
    _entriesFuture = _svc.load(_babyKey);
  }

  Future<void> _reload() async {
    setState(() => _entriesFuture = _svc.load(_babyKey));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final title = switch (_metricIndex) {
      0 => AppStrings.t(context, 'growth_weight_age'),
      1 => AppStrings.t(context, 'growth_length_age'),
      _ => AppStrings.t(context, 'growth_head_age'),
    };

    final unit = switch (_metricIndex) {
      0 => 'kg',
      1 => 'cm',
      _ => 'cm',
    };

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${AppStrings.t(context, 'growth')} • ${widget.baby.name}',
            style: t.titleLarge,
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: FutureBuilder<List<GrowthEntry>>(
          future: _entriesFuture,
          builder: (context, snap) {
            final entries = snap.data ?? const <GrowthEntry>[];

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                NeoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      SegmentedButton<int>(
                        segments: [
                          ButtonSegment(
                            value: 0,
                            label: Text(AppStrings.t(context, 'weight')),
                          ),
                          ButtonSegment(
                            value: 1,
                            label: Text(AppStrings.t(context, 'length')),
                          ),
                          ButtonSegment(
                            value: 2,
                            label: Text(AppStrings.t(context, 'head')),
                          ),
                        ],
                        selected: {_metricIndex},
                        onSelectionChanged: (s) => setState(() => _metricIndex = s.first),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(AppStrings.t(context, 'range'), style: t.bodyMedium),
                          const SizedBox(width: 10),
                          DropdownButton<int>(
                            value: _maxMonth,
                            items: [
                              DropdownMenuItem(
                                value: 12,
                                child: Text(AppStrings.t(context, 'range_0_12')),
                              ),
                              DropdownMenuItem(
                                value: 24,
                                child: Text(AppStrings.t(context, 'range_0_24')),
                              ),
                              DropdownMenuItem(
                                value: 60,
                                child: Text(AppStrings.t(context, 'range_0_60')),
                              ),
                            ],
                            onChanged: (v) => setState(() => _maxMonth = v ?? 24),
                          ),
                          const Spacer(),
                          Text(unit, style: t.labelLarge),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppStrings.t(context, 'growth_tip'),
                        style: t.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                NeoCard(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    height: 270,
                    child: _WhoChartBuilder(
                      metricIndex: _metricIndex,
                      maxMonth: _maxMonth,
                      unit: unit,
                      babyKey: _babyKey,
                      entries: entries,
                      who: _who,
                      pct: _pct,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                NeoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.t(context, 'measurements'),
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      if (entries.isEmpty)
                        Text(
                          AppStrings.t(context, 'measurements_empty'),
                          style: t.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        )
                      else
                        ...entries.reversed.take(6).map((e) {
                          final v = _valueForMetric(e, _metricIndex);
                          final vStr = v == null
                              ? '-'
                              : v.toStringAsFixed(_metricIndex == 0 ? 1 : 0);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(child: Text(e.dateIso, style: t.bodyMedium)),
                                Text('$vStr $unit', style: t.bodyMedium),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          
                          final now = DateTime.now();
                          final iso =
                              '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

                          
                          final ageDays = _ageDaysFromBabyDob(widget.baby.birthDate, now);
                          final id = now.millisecondsSinceEpoch.toString();

                          final entry = GrowthEntry(
                            id: id,
                            babyKey: _babyKey,
                            dateIso: iso,
                            ageDays: ageDays,
                            weightKg: _metricIndex == 0 ? 9.2 : null,
                            lengthCm: _metricIndex == 1 ? 74.0 : null,
                            headCircCm: _metricIndex == 2 ? 44.0 : null,
                          );

                          await _svc.add(_babyKey, entry);
                          await _reload();
                        },
                        icon: const Icon(Icons.add),
                        label: Text(AppStrings.t(context, 'add_sample')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                      label: Text(AppStrings.t(context, 'refresh')),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  
  int _ageDaysFromBabyDob(String birthIso, DateTime now) {
    final dob = DateTime.tryParse(birthIso);
    if (dob == null) return 0;
    final dobDayOnly = DateTime(dob.year, dob.month, dob.day);
    final nowDayOnly = DateTime(now.year, now.month, now.day);
    return nowDayOnly.difference(dobDayOnly).inDays.clamp(0, 3650);
  }

  double? _valueForMetric(GrowthEntry e, int metric) {
    return switch (metric) {
      0 => e.weightKg,
      1 => e.lengthCm,
      _ => e.headCircCm,
    };
  }
}


class _WhoChartBuilder extends StatefulWidget {
  final int metricIndex;
  final int maxMonth;
  final String unit;
  final String babyKey;
  final List<GrowthEntry> entries;

  final WhoLmsLoader who;
  final PercentileCalc pct;

  const _WhoChartBuilder({
    required this.metricIndex,
    required this.maxMonth,
    required this.unit,
    required this.babyKey,
    required this.entries,
    required this.who,
    required this.pct,
  });

  @override
  State<_WhoChartBuilder> createState() => _WhoChartBuilderState();
}

class _WhoChartBuilderState extends State<_WhoChartBuilder> {
  late Future<_WhoCurves> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadCurves();
  }

  @override
  void didUpdateWidget(covariant _WhoChartBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.metricIndex != widget.metricIndex ||
        oldWidget.maxMonth != widget.maxMonth) {
      setState(() {
        _future = _loadCurves();
      });
    }
  }

  Future<_WhoCurves> _loadCurves() async {
    
    final sex = Sex.boy;

    final metric = switch (widget.metricIndex) {
      0 => WhoMetric.wfa,
      1 => WhoMetric.lhfa,
      _ => WhoMetric.hcfa,
    };

    final rows = await widget.who.load(metric: metric, sex: sex);

    
    const z3 = -1.8807936;
    const z50 = 0.0;
    const z97 = 1.8807936;

    double xFromZ(dynamic lms, double z) {
  final l = (lms.l as num).toDouble();
  final m = (lms.m as num).toDouble();
  final s = (lms.s as num).toDouble();

  if (m <= 0 || s <= 0) return double.nan;

  if (l.abs() < 1e-9) {
    return m * math.exp(s * z);
  }
  final base = 1.0 + l * s * z;
  if (base <= 0) return double.nan;
  return m * math.pow(base, 1.0 / l).toDouble();
}

    final p3 = <Point>[];
    final p50 = <Point>[];
    final p97 = <Point>[];

    for (int m = 0; m <= widget.maxMonth; m++) {
      final lms = widget.who.interpolate(rows, m.toDouble());
      p3.add(Point(m, xFromZ(lms, z3)));
      p50.add(Point(m, xFromZ(lms, z50)));
      p97.add(Point(m, xFromZ(lms, z97)));
    }

    return _WhoCurves(p3: p3, p50: p50, p97: p97);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_WhoCurves>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final curves = snap.data!;

        final babySeries = widget.entries
            .map((e) {
              final ageMonths = (e.ageDays / 30.4375);
              final m = ageMonths.round();
              final v = switch (widget.metricIndex) {
                0 => e.weightKg,
                1 => e.lengthCm,
                _ => e.headCircCm,
              };
              if (v == null) return null;
              return Point(m, v);
            })
            .whereType<Point>()
            .where((p) => p.month >= 0 && p.month <= widget.maxMonth)
            .toList()
          ..sort((a, b) => a.month.compareTo(b.month));

        final monthsLabel = AppStrings.t(context, 'months');
        final babyLabel = AppStrings.t(context, 'baby');

        return _GrowthChart(
          maxMonth: widget.maxMonth,
          unitLabel: widget.unit,
          monthsLabel: monthsLabel,
          babyLabel: babyLabel,
          babySeries: babySeries,
          p3: curves.p3,
          p50: curves.p50,
          p97: curves.p97,
        );
      },
    );
  }
}



class Point {
  final int month;
  final double value;
  const Point(this.month, this.value);
}

class _WhoCurves {
  final List<Point> p3;
  final List<Point> p50;
  final List<Point> p97;

  const _WhoCurves({
    required this.p3,
    required this.p50,
    required this.p97,
  });
}

class _GrowthChart extends StatelessWidget {
  final int maxMonth;
  final String unitLabel;
  final String monthsLabel;
  final String babyLabel;

  final List<Point> babySeries;
  final List<Point> p3;
  final List<Point> p50;
  final List<Point> p97;

  const _GrowthChart({
    required this.maxMonth,
    required this.unitLabel,
    required this.monthsLabel,
    required this.babyLabel,
    required this.babySeries,
    required this.p3,
    required this.p50,
    required this.p97,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _GrowthPainter(
        cs: cs,
        maxMonth: maxMonth,
        unitLabel: unitLabel,
        monthsLabel: monthsLabel,
        babyLabel: babyLabel,
        babySeries: babySeries,
        p3: p3,
        p50: p50,
        p97: p97,
      ),
    );
  }
}

class _GrowthPainter extends CustomPainter {
  final ColorScheme cs;
  final int maxMonth;
  final String unitLabel;
  final String monthsLabel;
  final String babyLabel;

  final List<Point> babySeries;
  final List<Point> p3;
  final List<Point> p50;
  final List<Point> p97;

  _GrowthPainter({
    required this.cs,
    required this.maxMonth,
    required this.unitLabel,
    required this.monthsLabel,
    required this.babyLabel,
    required this.babySeries,
    required this.p3,
    required this.p50,
    required this.p97,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padL = 34.0;
    final padR = 12.0;
    final padT = 16.0;
    final padB = 26.0;

    final chart = Rect.fromLTWH(
      padL,
      padT,
      size.width - padL - padR,
      size.height - padT - padB,
    );

    final all = <double>[
      ...p3.map((e) => e.value),
      ...p50.map((e) => e.value),
      ...p97.map((e) => e.value),
      ...babySeries.map((e) => e.value),
    ].where((v) => v.isFinite).toList();

    if (all.isEmpty) return;

    double minY = all.reduce(math.min);
    double maxY = all.reduce(math.max);
    final yPad = (maxY - minY) * 0.10;
    minY -= yPad;
    maxY += yPad;

    double xForMonth(int m) => chart.left + (m / maxMonth) * chart.width;
    double yForValue(double v) =>
        chart.bottom - ((v - minY) / (maxY - minY)) * chart.height;

    final gridPaint = Paint()
      ..color = cs.outlineVariant.o(0.25)
      ..strokeWidth = 1;

    for (int m = 0;
        m <= maxMonth;
        m += (maxMonth <= 12 ? 3 : (maxMonth <= 24 ? 6 : 12))) {
      final x = xForMonth(m);
      canvas.drawLine(Offset(x, chart.top), Offset(x, chart.bottom), gridPaint);
      _drawText(canvas, '$m', Offset(x, chart.bottom + 4), alignCenter: true);
    }

    for (int i = 0; i <= 5; i++) {
      final v = minY + (maxY - minY) * (i / 5);
      final y = yForValue(v);
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      _drawText(
        canvas,
        v.toStringAsFixed(unitLabel == 'kg' ? 1 : 0),
        Offset(chart.left - 6, y - 6),
        alignRight: true,
      );
    }

    _drawLine(canvas, p3, xForMonth, yForValue,
        color: cs.primary.o(0.26), width: 2);
    _drawLine(canvas, p50, xForMonth, yForValue,
        color: cs.primary.o(0.58), width: 2.6);
    _drawLine(canvas, p97, xForMonth, yForValue,
        color: cs.primary.o(0.26), width: 2);

    _drawLine(canvas, babySeries, xForMonth, yForValue,
        color: cs.secondary, width: 3);

    final dotPaint = Paint()..color = cs.secondary;
    for (final p in babySeries) {
      final dx = xForMonth(p.month);
      final dy = yForValue(p.value);
      canvas.drawCircle(Offset(dx, dy), 4.2, dotPaint);
      canvas.drawCircle(
        Offset(dx, dy),
        6.0,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = cs.secondary.o(0.35),
      );
    }

    final legendY = chart.top - 8;
    _legend(canvas, Offset(chart.left + 4, legendY), 'P3', cs.primary.o(0.26));
    _legend(canvas, Offset(chart.left + 54, legendY), 'P50', cs.primary.o(0.58));
    _legend(canvas, Offset(chart.left + 114, legendY), 'P97', cs.primary.o(0.26));
    _legend(canvas, Offset(chart.left + 174, legendY), babyLabel, cs.secondary);

    _drawText(canvas, monthsLabel, Offset(chart.right, chart.bottom + 4), alignRight: true);
    _drawText(canvas, unitLabel, Offset(chart.left - 6, chart.top - 18), alignRight: true);
  }

  void _drawLine(
    Canvas canvas,
    List<Point> pts,
    double Function(int) xForMonth,
    double Function(double) yForValue, {
    required Color color,
    required double width,
  }) {
    final valid = pts.where((p) => p.value.isFinite).toList();
    if (valid.isEmpty) return;

    final p = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < valid.length; i++) {
      final x = xForMonth(valid[i].month);
      final y = yForValue(valid[i].value);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, p);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    bool alignRight = false,
    bool alignCenter = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: cs.onSurface.o(0.70),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    double dx = pos.dx;
    if (alignRight) dx -= tp.width;
    if (alignCenter) dx -= tp.width / 2;

    tp.paint(canvas, Offset(dx, pos.dy));
  }

  void _legend(Canvas canvas, Offset pos, String label, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(pos.dx, pos.dy), 4, paint);
    _drawText(canvas, label, Offset(pos.dx + 10, pos.dy - 7));
  }

  @override
  bool shouldRepaint(covariant _GrowthPainter old) {
    return old.maxMonth != maxMonth ||
        old.unitLabel != unitLabel ||
        old.babySeries != babySeries ||
        old.p3 != p3 ||
        old.p50 != p50 ||
        old.p97 != p97 ||
        old.cs != cs;
  }
}
