
import 'dart:math' as math;

import '../models/lms_row.dart';


class PercentileResult {
  
  final double z;

  
  final double percentile;

  const PercentileResult({required this.z, required this.percentile});
}








class PercentileCalc {
  const PercentileCalc();

  
  double zFromLms({
    required double x,
    required double l,
    required double m,
    required double s,
  }) {
    if (x <= 0 || m <= 0 || s <= 0) return double.nan;

    
    if (l.abs() < 1e-9) {
      return math.log(x / m) / s;
    }

    final ratio = x / m;
    return ((math.pow(ratio, l) - 1.0) / (l * s)).toDouble();
  }

  
  double percentileFromZ(double z) {
    final cdf = _normalCdf(z);
    if (cdf.isNaN) return double.nan;
    return (cdf * 100.0).clamp(0.0, 100.0);
  }

  
  PercentileResult calculate({
    required double x,
    required LmsRow lms,
  }) {
    final z = zFromLms(x: x, l: lms.l, m: lms.m, s: lms.s);
    final pct = percentileFromZ(z);
    return PercentileResult(z: z, percentile: pct);
  }

  
  PercentileResult calculateFromValues({
    required double x,
    required double l,
    required double m,
    required double s,
  }) {
    final z = zFromLms(x: x, l: l, m: m, s: s);
    final pct = percentileFromZ(z);
    return PercentileResult(z: z, percentile: pct);
  }

  
  
  double _normalCdf(double z) {
    if (z.isNaN) return double.nan;

    
    if (z <= -8.0) return 0.0;
    if (z >= 8.0) return 1.0;

    
    final x = z / math.sqrt(2.0);
    return 0.5 * (1.0 + _erfApprox(x));
  }

  
  double _erfApprox(double x) {
    final sign = x < 0 ? -1.0 : 1.0;
    final ax = x.abs();

    const a1 = 0.254829592;
    const a2 = -0.284496736;
    const a3 = 1.421413741;
    const a4 = -1.453152027;
    const a5 = 1.061405429;
    const p = 0.3275911;

    final t = 1.0 / (1.0 + p * ax);
    final y = 1.0 -
        (((((a5 * t + a4) * t + a3) * t + a2) * t + a1) * t) *
            math.exp(-ax * ax);

    return sign * y;
  }
}