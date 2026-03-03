import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback, rootBundle;
import 'package:neomama/models/baby_profile.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector3;
import 'package:xml/xml.dart';
import 'package:neomama/features/teething/models/teething_models.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class TeethingScreen extends StatefulWidget {
  final BabyProfile baby;
  const TeethingScreen({super.key, required this.baby});

  @override
  State<TeethingScreen> createState() => _TeethingScreenState();
}

class _TeethingScreenState extends State<TeethingScreen> {
  static const _assetPath = 'assets/teeth/teeth_chart.svg';
  String _localeCode = 'en';
  bool _didInit = false;

  String get _prefsKey {
    final id = widget.baby.id.toString();
    return 'teething_events_v1__$id';
  }

  bool _loading = true;
  String? _error;

  Rect _viewBox = const Rect.fromLTWH(0, 0, 800, 600);

  Path? _upperGums;
  Path? _lowerGums;
  final Map<String, Path> _toothPaths = {};
  final Map<String, DateTime> _erupted = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = Localizations.localeOf(context).languageCode;
    _localeCode = (code == 'tr' || code == 'en') ? code : 'en';
    if (_didInit) return;
    _didInit = true;
    _boot();
  }

  bool get _svgReady =>
      _upperGums != null && _lowerGums != null && _toothPaths.length == 20;

  Future<void> _boot() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _loadSvgPaths(_localeCode);
      await _loadSaved();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadSvgPaths(String localeCode) async {
    final raw = await rootBundle.loadString(_assetPath);
    final doc = XmlDocument.parse(raw);

    final svgEl = doc.findAllElements('svg').first;
    final vb = svgEl.getAttribute('viewBox');
    if (vb != null) {
      final parts = vb
          .split(RegExp(r'[ ,]+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (parts.length == 4) {
        final x = double.tryParse(parts[0]) ?? 0;
        final y = double.tryParse(parts[1]) ?? 0;
        final w = double.tryParse(parts[2]) ?? 800;
        final h = double.tryParse(parts[3]) ?? 600;
        _viewBox = Rect.fromLTWH(x, y, w, h);
      }
    }

    Path? upperG;
    Path? lowerG;
    final teeth = <String, Path>{};

    for (final p in doc.findAllElements('path')) {
      final id = p.getAttribute('id');
      final d = p.getAttribute('d');
      if (id == null || d == null) continue;

      final path = parseSvgPathData(d);

      if (id == 'upper-gums') {
        upperG = path;
      } else if (id == 'lower-gums') {
        lowerG = path;
      } else if (id.startsWith('tooth-u-') || id.startsWith('tooth-l-')) {
        teeth[id] = path;
      }
    }

    if (teeth.length != 20) {
      throw StateError(
        AppStrings.byCode(
          localeCode,
          'teething_svg_teeth_error',
          vars: {'count': '${teeth.length}'},
        ),
      );
    }
    if (upperG == null || lowerG == null) {
      throw StateError(AppStrings.byCode(localeCode, 'teething_svg_gums_error'));
    }

    _upperGums = upperG;
    _lowerGums = lowerG;

    _toothPaths
      ..clear()
      ..addAll(teeth);
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_prefsKey);
    if (s == null || s.trim().isEmpty) return;

    final decoded = jsonDecode(s);
    if (decoded is! Map) return;

    _erupted.clear();
    decoded.forEach((key, value) {
      if (key is! String) return;
      if (value is! String) return;
      final dt = DateTime.tryParse(value);
      if (dt == null) return;
      _erupted[key] = dt;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, String>{};
    for (final e in _erupted.entries) {
      map[e.key] = e.value.toIso8601String();
    }
    await prefs.setString(_prefsKey, jsonEncode(map));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final babyName = widget.baby.name.trim().isEmpty
        ? AppStrings.t(context, 'baby')
        : widget.baby.name;

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'teething'), style: t.titleLarge),
          actions: [
            IconButton(
              tooltip: AppStrings.t(context, 'refresh'),
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loading ? null : _boot,
            ),
          ],
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    NeoCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: cs.primary.o(0.12),
                            child:
                                Icon(Icons.tag_faces_rounded, color: cs.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$babyName • ${AppStrings.t(context, 'teeth_chart')}',
                                    style: t.titleMedium),
                                const SizedBox(height: 6),
                                Text(
                                  AppStrings.t(context, 'teething_hint'),
                                  style: t.bodyMedium,
                                ),
                                if (_error != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    _error!,
                                    style: t.bodyMedium
                                        ?.copyWith(color: cs.error),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    NeoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  AppStrings.t(context, 'chart'),
                                  style: t.titleMedium,
                                ),
                              ),
                              _LegendDot(color: cs.primary),
                              const SizedBox(width: 6),
                              Text(AppStrings.t(context, 'erupted'),
                                  style: t.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (_, c) {
                              final w = c.maxWidth;
                              final h = (w * 1.15).clamp(320.0, 440.0);

                              if (!_svgReady) {
                                return SizedBox(
                                  height: h,
                                  child: Center(
                                    child: Text(
                                      AppStrings.t(context, 'svg_not_ready'),
                                      textAlign: TextAlign.center,
                                      style: t.bodyMedium,
                                    ),
                                  ),
                                );
                              }

                              return SizedBox(
                                height: h,
                                width: double.infinity,
                                child: _TeethChart(
                                  colorScheme: cs,
                                  viewBox: _viewBox,
                                  upperGums: _upperGums!,
                                  lowerGums: _lowerGums!,
                                  teeth: _toothPaths,
                                  erupted: _erupted,
                                  onToothTap: (id) async {
                                    HapticFeedback.selectionClick();
                                    await _openToothSheet(context, id);
                                  },
                                  onToothLongPress: (id) async {
                                    HapticFeedback.mediumImpact();
                                    if (_erupted.containsKey(id)) {
                                      setState(() => _erupted.remove(id));
                                      await _save();
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    NeoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                    AppStrings.t(context, 'history'),
                                    style: t.titleMedium,
                                  )),
                              Text('${_erupted.length}/20',
                                  style: t.titleSmall),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (_erupted.isEmpty)
                            Text(AppStrings.t(context, 'no_tooth_logged'),
                                style: t.bodyMedium)
                          else
                            for (final e in _sortedEvents())
                              _HistoryRow(
                                toothId: e.key,
                                date: e.value,
                                label: _toothLabel(e.key),
                                range: _toothRange(e.key),
                                onTap: () => _openToothSheet(context, e.key),
                                onDelete: () async {
                                  setState(() => _erupted.remove(e.key));
                                  await _save();
                                },
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  List<MapEntry<String, DateTime>> _sortedEvents() {
    final list = _erupted.entries.toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  ToothType _typeForId(String id) {
    final n = int.tryParse(id.split('-').last) ?? 0;
    switch (n) {
      case 1:
      case 10:
        return ToothType.secondMolar;
      case 2:
      case 9:
        return ToothType.firstMolar;
      case 3:
      case 8:
        return ToothType.canine;
      case 4:
      case 7:
        return ToothType.lateralIncisor;
      case 5:
      case 6:
      default:
        return ToothType.centralIncisor;
    }
  }

  String _typeLabel(ToothType type) {
    switch (type) {
      case ToothType.centralIncisor:
        return AppStrings.t(context, 'tooth_type_central');
      case ToothType.lateralIncisor:
        return AppStrings.t(context, 'tooth_type_lateral');
      case ToothType.canine:
        return AppStrings.t(context, 'tooth_type_canine');
      case ToothType.firstMolar:
        return AppStrings.t(context, 'tooth_type_first_molar');
      case ToothType.secondMolar:
        return AppStrings.t(context, 'tooth_type_second_molar');
    }
  }

  String _toothRange(String id) {
    final isUpper = id.startsWith('tooth-u-');
    final type = _typeForId(id);

    String key;
    switch (type) {
      case ToothType.centralIncisor:
        key = isUpper
            ? 'tooth_range_upper_central'
            : 'tooth_range_lower_central';
        break;
      case ToothType.lateralIncisor:
        key = isUpper
            ? 'tooth_range_upper_lateral'
            : 'tooth_range_lower_lateral';
        break;
      case ToothType.canine:
        key = isUpper
            ? 'tooth_range_upper_canine'
            : 'tooth_range_lower_canine';
        break;
      case ToothType.firstMolar:
        key = isUpper
            ? 'tooth_range_upper_first_molar'
            : 'tooth_range_lower_first_molar';
        break;
      case ToothType.secondMolar:
        key = isUpper
            ? 'tooth_range_upper_second_molar'
            : 'tooth_range_lower_second_molar';
        break;
    }
    return AppStrings.t(context, key);
  }

  String _toothLabel(String id) {
    final isUpper = id.startsWith('tooth-u-');
    final jaw = isUpper
        ? AppStrings.t(context, 'upper')
        : AppStrings.t(context, 'lower');
    return '$jaw ${_typeLabel(_typeForId(id))}';
  }

  Future<void> _openToothSheet(BuildContext context, String toothId) async {
    final existing = _erupted[toothId];

    final res = await showModalBottomSheet<_ToothResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ToothSheet(
        toothId: toothId,
        toothLabel: _toothLabel(toothId),
        eruptionRange: _toothRange(toothId),
        initialDate: existing,
      ),
    );

    if (res == null) return;

    setState(() {
      if (res.isErupted) {
        _erupted[toothId] = res.date;
      } else {
        _erupted.remove(toothId);
      }
    });

    await _save();
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color.o(0.30),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.o(0.55)),
      ),
    );
  }
}

class _TeethChart extends StatelessWidget {
  final ColorScheme colorScheme;

  final Rect viewBox;
  final Path upperGums;
  final Path lowerGums;
  final Map<String, Path> teeth;
  final Map<String, DateTime> erupted;

  final ValueChanged<String> onToothTap;
  final ValueChanged<String> onToothLongPress;

  const _TeethChart({
    required this.colorScheme,
    required this.viewBox,
    required this.upperGums,
    required this.lowerGums,
    required this.teeth,
    required this.erupted,
    required this.onToothTap,
    required this.onToothLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final size = Size(c.maxWidth, c.maxHeight);

        final sx = size.width / viewBox.width;
        final sy = size.height / viewBox.height;
        final s = sx < sy ? sx : sy;

        final dx = (size.width - viewBox.width * s) / 2 - viewBox.left * s;
        final dy = (size.height - viewBox.height * s) / 2 - viewBox.top * s;

        final m = Matrix4.identity()
          ..translateByVector3(Vector3(dx, dy, 0))
          ..scaleByVector3(Vector3(s, s, 1));

        
        final inv = Matrix4.inverted(m);

        String? hitAt(Offset p) {
          final v = inv.transform3(Vector3(p.dx, p.dy, 0));
          final sp = Offset(v.x, v.y);

          
          for (final id in erupted.keys) {
            final path = teeth[id];
            if (path != null && path.contains(sp)) return id;
          }

          for (final e in teeth.entries) {
            if (e.value.contains(sp)) return e.key;
          }
          return null;
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) {
            final hit = hitAt(d.localPosition);
            if (hit != null) onToothTap(hit);
          },
          onLongPressStart: (d) {
            final hit = hitAt(d.localPosition);
            if (hit != null) onToothLongPress(hit);
          },
          child: CustomPaint(
            painter: _TeethPainter(
              cs: colorScheme,
              transform: m,
              upperGums: upperGums,
              lowerGums: lowerGums,
              teeth: teeth,
              erupted: erupted,
            ),
          ),
        );
      },
    );
  }
}

class _TeethPainter extends CustomPainter {
  final ColorScheme cs;
  final Matrix4 transform;

  final Path upperGums;
  final Path lowerGums;
  final Map<String, Path> teeth;
  final Map<String, DateTime> erupted;

  _TeethPainter({
    required this.cs,
    required this.transform,
    required this.upperGums,
    required this.lowerGums,
    required this.teeth,
    required this.erupted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.transform(transform.storage);

    final gumsPaint = Paint()
      ..color = cs.primary.o(0.22)
      ..style = PaintingStyle.fill;

    final toothPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final eruptedPaint = Paint()
      ..color = cs.primary.o(0.28)
      ..style = PaintingStyle.fill;

    
    canvas.drawPath(upperGums, gumsPaint);
    canvas.drawPath(lowerGums, gumsPaint);

    
    final ordered = teeth.keys.toList()..sort(_toothSort);
    for (final id in ordered) {
      final path = teeth[id]!;
      if (erupted.containsKey(id)) {
        canvas.drawPath(path, eruptedPaint);
      }
      canvas.drawPath(path, toothPaint);
    }

    canvas.restore();
  }

  int _toothSort(String a, String b) {
    int rank(String id) {
      final isUpper = id.startsWith('tooth-u-') ? 0 : 1;
      final n = int.tryParse(id.split('-').last) ?? 0;
      return isUpper * 100 + n;
    }

    return rank(a).compareTo(rank(b));
  }

  bool _sameTransform(Matrix4 a, Matrix4 b) {
    final sa = a.storage;
    final sb = b.storage;
    for (int i = 0; i < 16; i++) {
      if (sa[i] != sb[i]) return false;
    }
    return true;
  }

  @override
  bool shouldRepaint(covariant _TeethPainter old) {
    
    if (old.cs != cs) return true;
    if (!_sameTransform(old.transform, transform)) return true;
    if (old.teeth.length != teeth.length) return true;

    
    if (old.erupted.length != erupted.length) return true;
    for (final e in erupted.entries) {
      final v = old.erupted[e.key];
      if (v == null || v != e.value) return true;
    }
    return false;
  }
}

class _ToothResult {
  final bool isErupted;
  final DateTime date;
  const _ToothResult({required this.isErupted, required this.date});
}

class _ToothSheet extends StatefulWidget {
  final String toothId;
  final String toothLabel;
  final String eruptionRange;
  final DateTime? initialDate;

  const _ToothSheet({
    required this.toothId,
    required this.toothLabel,
    required this.eruptionRange,
    required this.initialDate,
  });

  @override
  State<_ToothSheet> createState() => _ToothSheetState();
}

class _ToothSheetState extends State<_ToothSheet> {
  late bool _isErupted;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _isErupted = widget.initialDate != null;
    _date = widget.initialDate ?? DateTime.now();
  }

  String _iso(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final inset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: SafeArea(
        top: false,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface.o(0.92),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: cs.outlineVariant.o(0.35)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: cs.onSurface.o(0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.toothLabel, style: t.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                              AppStrings.t(
                                context,
                                'eruption_window',
                                vars: {'range': widget.eruptionRange},
                              ),
                              style: t.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isErupted,
                        onChanged: (v) => setState(() => _isErupted = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isErupted
                              ? AppStrings.t(context, 'eruption_date')
                              : AppStrings.t(context, 'not_eruption_marked'),
                          style: t.bodyMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: !_isErupted
                            ? null
                            : () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _date,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (picked == null) return;
                                setState(() => _date = picked);
                              },
                        child: Text(_iso(_date)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          _ToothResult(isErupted: _isErupted, date: _date),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(AppStrings.t(context, 'save')),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String toothId;
  final String label;
  final String range;
  final DateTime date;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _HistoryRow({
    required this.toothId,
    required this.label,
    required this.range,
    required this.date,
    required this.onDelete,
    required this.onTap,
  });

  String _iso(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: NeoCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_iso(date), style: t.titleSmall),
                      const SizedBox(height: 4),
                      Text(label, style: t.titleMedium),
                      const SizedBox(height: 2),
                      Text(range, style: t.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: AppStrings.t(context, 'delete'),
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
