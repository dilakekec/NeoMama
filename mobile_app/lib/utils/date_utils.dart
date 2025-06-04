// lib/utils/date_utils.dart
String calculateAge(String birthDate) {
  final now = DateTime.now();
  final birth = DateTime.tryParse(birthDate);
  if (birth == null) return 'Unknown';
  
  final ageDuration = now.difference(birth);
  final ageDate = DateTime(0).add(ageDuration);

  final years = ageDate.year;
  final months = ageDate.month;
  final days = ageDate.day;

  return '$years years, $months months, $days days';
}
