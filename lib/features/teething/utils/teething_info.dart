import '../data/teeth_data.dart';
import '../models/teething_models.dart';
import 'package:neomama/l10n/app_strings.dart';

enum TeethingStatus { empty, recent, active, calm }

class TeethingInfo {
  final TeethingStatus status;

  final int eruptedCount;
  final int total;

  
  final double progress;

  
  final DateTime? latestDate;

  
  final int? daysSinceLatest;

  
  final String label;

  const TeethingInfo({
    required this.status,
    required this.eruptedCount,
    required this.total,
    required this.progress,
    required this.label,
    this.latestDate,
    this.daysSinceLatest,
  });
}

const int _recentDaysThreshold = 7;
const int _activeDaysThreshold = 30;

TeethingInfo computeTeethingInfo(
  Map<String, ToothState> state, {
  required String localeCode,
}) {
  final totalTeeth = kPrimaryTeeth.length;

  if (state.isEmpty) {
    return TeethingInfo(
      status: TeethingStatus.empty,
      eruptedCount: 0,
      total: totalTeeth,
      progress: 0.0,
      label: AppStrings.byCode(localeCode, 'teething_label_empty'),
    );
  }

  
  final knownIds = kPrimaryTeeth.map((t) => t.id).toSet();
  final knownStateEntries = state.entries.where((e) => knownIds.contains(e.key));

  final erupted = knownStateEntries.where((e) => e.value.erupted).length;
  final progress =
      totalTeeth <= 0 ? 0.0 : (erupted / totalTeeth).clamp(0.0, 1.0);

  DateTime? latest;
  for (final e in knownStateEntries) {
    final d = safeParseIsoDate(e.value.dateIso);
    if (d == null) continue;
    if (latest == null || d.isAfter(latest)) latest = d;
  }

  
  if (latest == null) {
    return TeethingInfo(
      status: TeethingStatus.active,
      eruptedCount: erupted,
      total: totalTeeth,
      progress: progress,
      label: AppStrings.byCode(
        localeCode,
        'teething_label_marked',
        vars: {'erupted': '$erupted', 'total': '$totalTeeth'},
      ),
    );
  }

  final days = daysSince(latest);

  if (days <= _recentDaysThreshold) {
    return TeethingInfo(
      status: TeethingStatus.recent,
      eruptedCount: erupted,
      total: totalTeeth,
      progress: progress,
      latestDate: latest,
      daysSinceLatest: days,
      label: AppStrings.byCode(
        localeCode,
        'teething_label_recent',
        vars: {'days': '$days'},
      ),
    );
  }

  if (days <= _activeDaysThreshold) {
    return TeethingInfo(
      status: TeethingStatus.active,
      eruptedCount: erupted,
      total: totalTeeth,
      progress: progress,
      latestDate: latest,
      daysSinceLatest: days,
      label: AppStrings.byCode(
        localeCode,
        'teething_label_progress',
        vars: {'erupted': '$erupted', 'total': '$totalTeeth'},
      ),
    );
  }

  return TeethingInfo(
    status: TeethingStatus.calm,
    eruptedCount: erupted,
    total: totalTeeth,
    progress: progress,
    latestDate: latest,
    daysSinceLatest: days,
    label: AppStrings.byCode(
      localeCode,
      'teething_label_calm',
      vars: {'erupted': '$erupted', 'total': '$totalTeeth'},
    ),
  );
}


DateTime? safeParseIsoDate(String? iso) {
  if (iso == null) return null;
  final s = iso.trim();
  if (s.isEmpty) return null;

  
  final parts = s.split('-');
  if (parts.length != 3) return null;

  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;

  
  if (m < 1 || m > 12) return null;
  if (d < 1 || d > 31) return null;

  return DateTime(y, m, d);
}


int daysSince(DateTime date) {
  final now = DateTime.now();
  final a = DateTime(now.year, now.month, now.day);
  final b = DateTime(date.year, date.month, date.day);
  final diff = a.difference(b).inDays;
  return diff < 0 ? 0 : diff;
}
