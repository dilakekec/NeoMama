// lib/models/feeding_schedule.dart
class FeedingSchedule {
  final List<String> times;
  FeedingSchedule({required this.times});
  factory FeedingSchedule.fromJson(Map<String, dynamic> json) =>
      FeedingSchedule(times: List<String>.from(json["times"]));
  Map<String, dynamic> toJson() => {"times":times};
}
