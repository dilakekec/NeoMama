

String calculateAge(String birthDate) {
  final birth = DateTime.tryParse(birthDate);
  if (birth == null) return 'Unknown';

  final now = DateTime.now();

  int years = now.year - birth.year;
  int months = now.month - birth.month;
  int days = now.day - birth.day;

  
  if (days < 0) {
    final prevMonth = DateTime(now.year, now.month, 0); 
    days += prevMonth.day;
    months -= 1;
  }

  
  if (months < 0) {
    months += 12;
    years -= 1;
  }

  if (years < 0) {
    years = 0;
    months = 0;
    days = 0;
  }

  
  if (years == 0 && months == 0) {
    return '$days days';
  }

  if (years == 0) {
    return '$months months, $days days';
  }

  return '$years years, $months months';
}