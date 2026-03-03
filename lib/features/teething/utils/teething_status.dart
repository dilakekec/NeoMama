import '../models/teething_models.dart';
import 'package:neomama/l10n/app_strings.dart';

enum TeethingStatus { empty, recent, active, calm }

class TeethingInfo {
  final TeethingStatus status;
  final int eruptedCount;     
  final int total;            
  final DateTime? latestDate; 
  final int? daysSinceLatest; 
  final String label;         

  const TeethingInfo({
    required this.status,
    required this.eruptedCount,
    required this.total,
    required this.label,
    this.latestDate,
    this.daysSinceLatest,
  });
}

TeethingInfo computeTeethingInfo(
  Map<String, ToothState> state, {
  required String localeCode,
}) {
  const total = 20;

  if (state.isEmpty) {
    return TeethingInfo(
      status: TeethingStatus.empty,
      eruptedCount: 0,
      total: total,
      label: AppStrings.byCode(localeCode, 'teething_label_empty'),
    );
  }

  final erupted = state.values.where((s) => s.erupted).length;

  DateTime? latest;
  for (final s in state.values) {
    final d = safeParseIsoDate(s.dateIso);
    if (d == null) continue;
    if (latest == null || d.isAfter(latest)) latest = d;
  }

  if (latest == null) {
    return TeethingInfo(
      status: TeethingStatus.active,
      eruptedCount: erupted,
      total: total,
      label: AppStrings.byCode(
        localeCode,
        'teething_label_marked',
        vars: {'erupted': '$erupted', 'total': '$total'},
      ),
    );
  }

  final days = _daysBetween(DateTime.now(), latest);

  if (days <= 7) {
    return TeethingInfo(
      status: TeethingStatus.recent,
      eruptedCount: erupted,
      total: total,
      latestDate: latest,
      daysSinceLatest: days,
      label: AppStrings.byCode(
        localeCode,
        'teething_label_recent',
        vars: {'days': '$days'},
      ),
    );
  }

  if (days <= 30) {
    return TeethingInfo(
      status: TeethingStatus.active,
      eruptedCount: erupted,
      total: total,
      latestDate: latest,
      daysSinceLatest: days,
      label: AppStrings.byCode(
        localeCode,
        'teething_label_progress',
        vars: {'erupted': '$erupted', 'total': '$total'},
      ),
    );
  }

  return TeethingInfo(
    status: TeethingStatus.calm,
    eruptedCount: erupted,
    total: total,
    latestDate: latest,
    daysSinceLatest: days,
    label: AppStrings.byCode(
      localeCode,
      'teething_label_calm',
      vars: {'erupted': '$erupted', 'total': '$total'},
    ),
  );
}

DateTime? safeParseIsoDate(String? iso) {
  if (iso == null) return null;
  final s = iso.trim();
  if (s.isEmpty) return null;
  return DateTime.tryParse(s);
}

int _daysBetween(DateTime a, DateTime b) {
  final aa = DateTime(a.year, a.month, a.day);
  final bb = DateTime(b.year, b.month, b.day);
  return aa.difference(bb).inDays.abs();
}
