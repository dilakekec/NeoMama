import 'package:flutter/foundation.dart';

enum AiReview { pass, caution, block }

@immutable
class CommunityExperience {
  final String id;
  final String title;
  final String body;
  final List<String> tags;
  final int workedCount;
  final AiReview aiReview;
  final bool medicalClaim;

  const CommunityExperience({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.workedCount,
    required this.aiReview,
    required this.medicalClaim,
  });

  CommunityExperience copyWith({
    String? id,
    String? title,
    String? body,
    List<String>? tags,
    int? workedCount,
    AiReview? aiReview,
    bool? medicalClaim,
  }) {
    return CommunityExperience(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      tags: tags ?? this.tags,
      workedCount: workedCount ?? this.workedCount,
      aiReview: aiReview ?? this.aiReview,
      medicalClaim: medicalClaim ?? this.medicalClaim,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'tags': tags,
        'workedCount': workedCount,
        'aiReview': aiReview.name,
        'medicalClaim': medicalClaim,
      };

  factory CommunityExperience.fromJson(Map<String, dynamic> json) {
    final review = AiReview.values.firstWhere(
      (r) => r.name == json['aiReview'],
      orElse: () => AiReview.caution,
    );
    return CommunityExperience(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      tags: (json['tags'] is List)
          ? List<String>.from(json['tags'] as List)
          : const <String>[],
      workedCount: (json['workedCount'] is num)
          ? (json['workedCount'] as num).toInt()
          : 0,
      aiReview: review,
      medicalClaim: json['medicalClaim'] == true,
    );
  }
}

@immutable
class CommunityRoom {
  final String id;
  final String title;
  final String question;
  final String emoji;
  final List<String> tags;
  final List<CommunityExperience> experiences;

  const CommunityRoom({
    required this.id,
    required this.title,
    required this.question,
    required this.emoji,
    required this.tags,
    required this.experiences,
  });

  CommunityRoom copyWith({
    String? id,
    String? title,
    String? question,
    String? emoji,
    List<String>? tags,
    List<CommunityExperience>? experiences,
  }) {
    return CommunityRoom(
      id: id ?? this.id,
      title: title ?? this.title,
      question: question ?? this.question,
      emoji: emoji ?? this.emoji,
      tags: tags ?? this.tags,
      experiences: experiences ?? this.experiences,
    );
  }
}
