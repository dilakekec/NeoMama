
class GrowthEntry {
  final String id; 
  final String babyKey;

  
  final String dateIso;

  
  final int ageDays;

  
  final double? weightKg;
  final double? lengthCm;
  final double? headCircCm;

  const GrowthEntry({
    required this.id,
    required this.babyKey,
    required this.dateIso,
    required this.ageDays,
    this.weightKg,
    this.lengthCm,
    this.headCircCm,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'babyKey': babyKey,
        'dateIso': dateIso,
        'ageDays': ageDays,
        'weightKg': weightKg,
        'lengthCm': lengthCm,
        'headCircCm': headCircCm,
      };

  static GrowthEntry fromJson(Map<String, dynamic> j) => GrowthEntry(
        id: j['id'] as String,
        babyKey: j['babyKey'] as String,
        dateIso: j['dateIso'] as String,
        ageDays: (j['ageDays'] as num).toInt(),
        weightKg: (j['weightKg'] as num?)?.toDouble(),
        lengthCm: (j['lengthCm'] as num?)?.toDouble(),
        headCircCm: (j['headCircCm'] as num?)?.toDouble(),
      );
}