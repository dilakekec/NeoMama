

import 'dart:convert';
import 'dart:io';

class Spec {
  final String csvPath;
  final String outPath;
  final String listName;
  const Spec(this.csvPath, this.outPath, this.listName);
}

Future<void> main() async {
  
  const specs = <Spec>[
    Spec('assets/who/who_boys_weight_0_24.csv', 'lib/data/who/wfa_boys_0_5.dart', 'wfaBoys0To5'),
    Spec('assets/who/who_girls_weight_0_24.csv', 'lib/data/who/wfa_girls_0_5.dart', 'wfaGirls0To5'),
    Spec('assets/who/who_boys_height_0_24.csv', 'lib/data/who/lhfa_boys_0_2.dart', 'lhfaBoys0To2'),
    Spec('assets/who/who_girls_height_0_24.csv', 'lib/data/who/lhfa_girls_0_2.dart', 'lhfaGirls0To2'),
  ];

  for (final s in specs) {
    await _generate(s);
  }

  stdout.writeln('Done.');
}

Future<void> _generate(Spec spec) async {
  final file = File(spec.csvPath);
  if (!await file.exists()) {
    throw Exception('CSV not found: ${spec.csvPath}');
  }

  final text = await file.readAsString();
  final rows = const LineSplitter().convert(text).where((l) => l.trim().isNotEmpty).toList();
  if (rows.length < 2) throw Exception('CSV has no data: ${spec.csvPath}');

  final headers = _splitCsvLine(rows.first).map((e) => e.trim()).toList();
  int idx(String name) {
    final i = headers.indexWhere((h) => h.toLowerCase() == name.toLowerCase());
    if (i == -1) throw Exception('Missing column "$name" in ${spec.csvPath}. Headers=$headers');
    return i;
  }

  final iAge = idx('age');
  final iL = idx('L');
  final iM = idx('M');
  final iS = idx('S');

  final buff = StringBuffer()
    ..writeln('// GENERATED FILE - DO NOT EDIT BY HAND')
    ..writeln("import '../../features/growth/services/who_lms_loader.dart';")
    ..writeln('')
    ..writeln('const List<LmsRow> ${spec.listName} = [');

  for (var r = 1; r < rows.length; r++) {
    final cols = _splitCsvLine(rows[r]);
    if (cols.length < headers.length) continue;

    final age = _parseDouble(cols[iAge]);
    final l = _parseDouble(cols[iL]);
    final m = _parseDouble(cols[iM]);
    final s = _parseDouble(cols[iS]);

    if (age == null || l == null || m == null || s == null) continue;

    buff.writeln(
      '  LmsRow(ageMonths: ${age.toStringAsFixed(3)}, l: ${l.toStringAsFixed(6)}, m: ${m.toStringAsFixed(6)}, s: ${s.toStringAsFixed(6)}),',
    );
  }

  buff.writeln('];');

  final out = File(spec.outPath);
  await out.parent.create(recursive: true);
  await out.writeAsString(buff.toString());

  stdout.writeln('Generated: ${spec.outPath}');
}

double? _parseDouble(String s) {
  final v = s.trim();
  if (v.isEmpty) return null;
  
  final normalized = v.replaceAll(',', '.');
  return double.tryParse(normalized);
}


List<String> _splitCsvLine(String line) {
  final out = <String>[];
  final sb = StringBuffer();
  bool inQuotes = false;

  for (var i = 0; i < line.length; i++) {
    final c = line[i];
    if (c == '"') {
      inQuotes = !inQuotes;
      continue;
    }
    if (c == ',' && !inQuotes) {
      out.add(sb.toString());
      sb.clear();
      continue;
    }
    sb.write(c);
  }
  out.add(sb.toString());
  return out;
}
