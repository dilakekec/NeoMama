import 'package:flutter/foundation.dart';

@immutable
class VaccinationItem {
  final String id;          
  final int dueMonth;       
  final String monthLabel;  
  final String title;       
  final String description;

  const VaccinationItem({
    required this.id,
    required this.dueMonth,
    required this.monthLabel,
    required this.title,
    required this.description,
  });
}

@immutable
class VaccinationState {
  final bool done;
  final String? dateIso; 
  final String? note;

  const VaccinationState({
    required this.done,
    this.dateIso,
    this.note,
  });

  VaccinationState copyWith({
    bool? done,
    String? dateIso,
    String? note,
  }) {
    return VaccinationState(
      done: done ?? this.done,
      dateIso: dateIso ?? this.dateIso,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'done': done,
        'dateIso': dateIso,
        'note': note,
      };

  factory VaccinationState.fromJson(Map<String, dynamic> j) {
    return VaccinationState(
      done: (j['done'] as bool?) ?? false,
      dateIso: j['dateIso'] as String?,
      note: j['note'] as String?,
    );
  }
}