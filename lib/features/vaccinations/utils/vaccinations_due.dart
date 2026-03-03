import '../models/vaccination_models.dart';

enum DueStatus { done, overdue, upcoming, scheduled, unknown }

class DueInfo {
  final DueStatus status;

  
  final DateTime? dueDate;

  
  final int? daysDelta;

  
  final String label;

  const DueInfo({
    required this.status,
    required this.label,
    this.dueDate,
    this.daysDelta,
  });
}


DateTime? safeParseIsoDate(String? iso) {
  if (iso == null) return null;
  final s = iso.trim();
  if (s.isEmpty) return null;
  return DateTime.tryParse(s);
}








DueInfo computeDueInfo({
  required VaccinationItem item,
  required VaccinationState state,
  required DateTime? dob,
}) {
  
  if (state.done) {
    final doneDate = safeParseIsoDate(state.dateIso);
    return DueInfo(
      status: DueStatus.done,
      label: doneDate == null ? 'Done' : 'Done • ${_fmtDate(doneDate)}',
      dueDate: dob == null ? null : _addMonths(dob, item.dueMonth), 
      daysDelta: 0,
    );
  }

  if (dob == null) {
    return DueInfo(
      status: DueStatus.unknown,
      label: item.monthLabel, 
    );
  }

  final due = _addMonths(dob, item.dueMonth); 
  final today = _dayOnly(DateTime.now());
  final delta = _dayOnly(due).difference(today).inDays;

  if (delta < 0) {
    return DueInfo(
      status: DueStatus.overdue,
      label: 'Overdue • ${_fmtDate(due)}',
      dueDate: due,
      daysDelta: delta,
    );
  }

  if (delta <= 14) {
    return DueInfo(
      status: DueStatus.upcoming,
      label: 'Upcoming • ${_fmtDate(due)}',
      dueDate: due,
      daysDelta: delta,
    );
  }

  return DueInfo(
    status: DueStatus.scheduled,
    label: '~${_fmtDate(due)}',
    dueDate: due,
    daysDelta: delta,
  );
}



DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _addMonths(DateTime d, int months) {
  final y = d.year + ((d.month - 1 + months) ~/ 12);
  final m = ((d.month - 1 + months) % 12) + 1;
  final lastDay = DateTime(y, m + 1, 0).day;
  final day = d.day > lastDay ? lastDay : d.day;
  return DateTime(y, m, day);
}

String _fmtDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}