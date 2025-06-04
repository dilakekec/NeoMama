// lib/models/baby_profile.dart
class BabyProfile {
  final int id;
  final String name;
  final String birthDate;
  final String? feedingPreferences;
  final String? allergies;
  final String? notes;

  BabyProfile({
    required this.id,
    required this.name,
    required this.birthDate,
    this.feedingPreferences,
    this.allergies,
    this.notes,
  });
  factory BabyProfile.fromJson(Map<String, dynamic> json) {
    return BabyProfile(
      id: json['id'],
      name: json['name'] as String,
      birthDate: json['birth_date'] as String,
      feedingPreferences: json['feeding_preferences'] as String?,
      allergies: json['allergies'] as String?,
      notes: json['notes'] as String?,
    );
  }
  Map<String, dynamic> toJson() => {
        'name': name,
        'birth_date': birthDate,
        'feeding_preferences': feedingPreferences,  
        'allergies': allergies, 
        'notes': notes,
      };
}