

enum ToothArch { upper, lower }
enum ToothSide { left, right }
enum ToothType {
  centralIncisor,
  lateralIncisor,
  canine,
  firstMolar,
  secondMolar,
}



extension ToothArchX on ToothArch {
  String get label => this == ToothArch.upper ? 'Upper' : 'Lower';
}

extension ToothSideX on ToothSide {
  String get label => this == ToothSide.left ? 'Left' : 'Right';
}

extension ToothTypeX on ToothType {
  String get label {
    switch (this) {
      case ToothType.centralIncisor:
        return 'Central Incisor';
      case ToothType.lateralIncisor:
        return 'Lateral Incisor';
      case ToothType.canine:
        return 'Canine';
      case ToothType.firstMolar:
        return 'First Molar';
      case ToothType.secondMolar:
        return 'Second Molar';
    }
  }
}



class ToothInfo {
  final String id;
  final ToothArch arch;
  final ToothSide side;
  final ToothType type;

  final String label;
  final String typicalRange; 
  final String description;

  
  final double x;
  final double y;

  const ToothInfo({
    required this.id,
    required this.arch,
    required this.side,
    required this.type,
    required this.label,
    required this.typicalRange,
    required this.description,
    required this.x,
    required this.y,
  });

  
  String get key => '${arch.name}_${side.name}_${type.name}_$id';
}


class ToothState {
  final bool erupted;
  final String? dateIso; 
  final String? note;
  final List<String> symptoms;

  const ToothState({
    required this.erupted,
    this.dateIso,
    this.note,
    this.symptoms = const [],
  });

  ToothState copyWith({
    bool? erupted,
    String? dateIso,
    String? note,
    List<String>? symptoms,
  }) {
    return ToothState(
      erupted: erupted ?? this.erupted,
      dateIso: dateIso ?? this.dateIso,
      note: note ?? this.note,
      symptoms: symptoms ?? this.symptoms,
    );
  }

  Map<String, dynamic> toJson() => {
        'erupted': erupted,
        'dateIso': dateIso,
        'note': note,
        'symptoms': symptoms,
      };

  factory ToothState.fromJson(Map<String, dynamic> j) {
    final raw = j['symptoms'];

    return ToothState(
      erupted: (j['erupted'] as bool?) ?? false,
      dateIso: j['dateIso'] as String?,
      note: j['note'] as String?,
      symptoms: raw is List
          ? raw.map((e) => e.toString()).toList()
          : const <String>[],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToothState &&
          erupted == other.erupted &&
          dateIso == other.dateIso &&
          note == other.note &&
          _listEquals(symptoms, other.symptoms);

  @override
  int get hashCode =>
      erupted.hashCode ^
      dateIso.hashCode ^
      note.hashCode ^
      symptoms.join('|').hashCode;
}


bool _listEquals(List a, List b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
    return true;
  }