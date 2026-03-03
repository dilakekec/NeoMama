import 'package:flutter/services.dart' show rootBundle;
import '../models/lms_row.dart';

class WhoCsvLoader {
  const WhoCsvLoader();

  Future<Map<int, LmsRow>> loadLmsFromAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);

    final lines = raw
        .split(RegExp(r'\r?\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (lines.isEmpty) return {};

    
    int headerIndex = -1;
    String delimiter = ';';

    for (int i = 0; i < lines.length; i++) {
      final line = _clean(lines[i]);
      if (line.isEmpty) continue;

      final d = _detectDelimiter(line);
      final cols = _splitCsvLine(line, d).map((e) => _clean(e).toLowerCase()).toList();

      final hasL = cols.contains('l');
      final hasM = cols.contains('m');
      final hasS = cols.contains('s');
      final hasAge = cols.contains('month') || cols.contains('age') || cols.contains('x');

      if (hasAge && hasL && hasM && hasS) {
        headerIndex = i;
        delimiter = d;
        break;
      }
    }

    if (headerIndex == -1) {
      throw FormatException('CSV header not found (expected age/month/x + L/M/S): $assetPath');
    }

    final header = _splitCsvLine(_clean(lines[headerIndex]), delimiter)
        .map((e) => _clean(e))
        .toList();

    final ageIdx = _idxAny(header, ['month', 'age', 'x']);
    final lIdx = _idx(header, 'l');
    final mIdx = _idx(header, 'm');
    final sIdx = _idx(header, 's');

    if (ageIdx < 0 || lIdx < 0 || mIdx < 0 || sIdx < 0) {
      throw FormatException('CSV header missing age/month/x or L/M/S: ${header.join(delimiter)}');
    }

    final out = <int, LmsRow>{};

    for (int i = headerIndex + 1; i < lines.length; i++) {
      final line = _clean(lines[i]);
      if (line.isEmpty) continue;

      final cols = _splitCsvLine(line, delimiter);
      if (cols.length <= sIdx || cols.length <= ageIdx) continue;

      
      final age = _toDouble(cols[ageIdx]);
      if (age == null) continue;
      final month = age.round();

      final l = _toDouble(cols[lIdx]);
      final m = _toDouble(cols[mIdx]);
      final s = _toDouble(cols[sIdx]);

      if (l == null || m == null || s == null) continue;

      out[month] = LmsRow(l: l, m: m, s: s);
    }

    return out;
  }

  String _detectDelimiter(String line) {
    final h = _clean(line);
    if (h.contains(';')) return ';';
    if (h.contains(',')) return ',';
    if (h.contains('\t')) return '\t';
    return ';';
  }

  int _idx(List<String> header, String key) {
    final k = key.toLowerCase();
    for (int i = 0; i < header.length; i++) {
      final h = _clean(header[i]).toLowerCase();
      if (h == k) return i;
    }
    return -1;
  }

  int _idxAny(List<String> header, List<String> keys) {
    final set = keys.map((e) => e.toLowerCase()).toSet();
    for (int i = 0; i < header.length; i++) {
      final h = _clean(header[i]).toLowerCase();
      if (set.contains(h)) return i;
    }
    return -1;
  }

  List<String> _splitCsvLine(String line, String delimiter) {
    return line.split(delimiter).map((e) => e.trim()).toList();
  }

  String _clean(String s) => s.trim().replaceAll('\uFEFF', '');

  double? _toDouble(String raw) {
    final s = _clean(raw).replaceAll(',', '.');
    return double.tryParse(s);
  }
}