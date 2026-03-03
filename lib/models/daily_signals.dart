import 'package:flutter/foundation.dart';

@immutable
class DailySignals {
  final bool sleepRestless;
  final bool feedingHard;
  final bool teethingSymptoms;
  final bool newFood;
  final bool skinRash;

  const DailySignals({
    required this.sleepRestless,
    required this.feedingHard,
    required this.teethingSymptoms,
    required this.newFood,
    required this.skinRash,
  });

  
  
  

  static const empty = DailySignals(
    sleepRestless: false,
    feedingHard: false,
    teethingSymptoms: false,
    newFood: false,
    skinRash: false,
  );

  bool get isEmpty =>
      !sleepRestless && !feedingHard && !teethingSymptoms && !newFood && !skinRash;

  bool get hasAny =>
      sleepRestless || feedingHard || teethingSymptoms || newFood || skinRash;

  
  int get score =>
      (sleepRestless ? 1 : 0) +
      (feedingHard ? 1 : 0) +
      (teethingSymptoms ? 1 : 0) +
      (newFood ? 1 : 0) +
      (skinRash ? 1 : 0);

  
  
  

  DailySignals copyWith({
    bool? sleepRestless,
    bool? feedingHard,
    bool? teethingSymptoms,
    bool? newFood,
    bool? skinRash,
  }) {
    return DailySignals(
      sleepRestless: sleepRestless ?? this.sleepRestless,
      feedingHard: feedingHard ?? this.feedingHard,
      teethingSymptoms: teethingSymptoms ?? this.teethingSymptoms,
      newFood: newFood ?? this.newFood,
      skinRash: skinRash ?? this.skinRash,
    );
  }

  
  
  

  Map<String, dynamic> toJson() => {
        'sleepRestless': sleepRestless,
        'feedingHard': feedingHard,
        'teethingSymptoms': teethingSymptoms,
        'newFood': newFood,
        'skinRash': skinRash,
      };

  factory DailySignals.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DailySignals.empty;

    return DailySignals(
      sleepRestless: json['sleepRestless'] == true,
      feedingHard: json['feedingHard'] == true,
      teethingSymptoms: json['teethingSymptoms'] == true,
      newFood: json['newFood'] == true,
      skinRash: json['skinRash'] == true,
    );
  }
}
