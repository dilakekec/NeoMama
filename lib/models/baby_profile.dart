
import 'package:meta/meta.dart';

@immutable
class BabyProfile {
  final int id;
  final String name;

  
  final String birthDate;

  final String? feedingPreferences;
  final String? allergies;
  final String? notes;

  const BabyProfile({
    required this.id,
    required this.name,
    required this.birthDate,
    this.feedingPreferences,
    this.allergies,
    this.notes,
  });

  
  
  

  factory BabyProfile.fromJson(Map<String, dynamic> json) {
    return BabyProfile(
      id: _parseId(json['id']),
      name: (json['name'] ?? '').toString().trim(),
      birthDate: _parseBirthDateRaw(json),
      feedingPreferences: _nullableString(json['feeding_preferences']),
      allergies: _nullableString(json['allergies']),
      notes: _nullableString(json['notes']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birth_date': birthDate,
        'feeding_preferences': feedingPreferences,
        'allergies': allergies,
        'notes': notes,
      };

  
  
  

  
  String get formattedDob {
    final dt = birthDateParsed;
    if (dt == null) return birthDate;
    return _fmtDDMMYYYY(dt);
  }

  
  int? get ageInMonths {
    final dob = birthDateParsed;
    if (dob == null) return null;

    final today = _dayOnly(DateTime.now());
    final birth = _dayOnly(dob);

    if (birth.isAfter(today)) return 0; 

    var months =
        (today.year - birth.year) * 12 + (today.month - birth.month);

    if (today.day < birth.day) months -= 1;

    return months < 0 ? 0 : months;
  }

  
  DateTime? get birthDateParsed {
    try {
      return DateTime.parse(birthDate);
    } catch (_) {
      return null;
    }
  }

  
  
  

  static int _parseId(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return 0; 
  }

  static String _parseBirthDateRaw(Map<String, dynamic> json) {
    final v = json['birth_date'] ?? json['birthDate'];
    if (v == null) return '';
    return v.toString().trim();
  }

  static String? _nullableString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static DateTime _dayOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  static String _fmtDDMMYYYY(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}';
  }
}