import '../models/lms_row.dart';
import 'who_csv_loader.dart';


enum WhoMetric { wfa, lhfa, hcfa } 
enum Sex { boy, girl }

class WhoLmsLoader {
  final WhoCsvLoader _csv;
  final Map<String, Future<Map<int, LmsRow>>> _cache = {};

  WhoLmsLoader({WhoCsvLoader? csv}) : _csv = csv ?? const WhoCsvLoader();

  Future<Map<int, LmsRow>> load({
    required WhoMetric metric,
    required Sex sex,
  }) {
    final path = _path(metric, sex);
    return _cache.putIfAbsent(path, () => _csv.loadLmsFromAsset(path));
  }

  String _path(WhoMetric metric, Sex sex) {
    final s = sex == Sex.boy ? 'boys' : 'girls';
    switch (metric) {
      case WhoMetric.wfa:
        return 'assets/who/who_wfa_${s}_0_60.csv';
      case WhoMetric.lhfa:
        return 'assets/who/who_lhfa_${s}_0_60.csv';
      case WhoMetric.hcfa:
        return 'assets/who/who_hcfa_${s}_0_60.csv';
    }
  }

  
  LmsRow interpolate(Map<int, LmsRow> rows, double ageMonths) {
    if (rows.isEmpty) return const LmsRow(l: 0, m: 1, s: 1);

    final keys = rows.keys.toList()..sort();
    final minK = keys.first.toDouble();
    final maxK = keys.last.toDouble();
    final x = ageMonths.isNaN ? minK : ageMonths.clamp(minK, maxK);

    int lo = keys.first;
    int hi = keys.last;

    for (int i = 0; i < keys.length; i++) {
      final k = keys[i].toDouble();
      if (k <= x) lo = keys[i];
      if (k >= x) {
        hi = keys[i];
        break;
      }
    }

    if (lo == hi) return rows[lo]!;
    final a = rows[lo]!;
    final b = rows[hi]!;
    final t = (x - lo) / (hi - lo);

    double lerp(double p, double q) => p + (q - p) * t;

    return LmsRow(
      l: lerp(a.l, b.l),
      m: lerp(a.m, b.m),
      s: lerp(a.s, b.s),
    );
  }
}