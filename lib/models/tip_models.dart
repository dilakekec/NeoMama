import 'package:flutter/foundation.dart';

enum TipType { info, reminder, warning }

@immutable
class TipItem {
  final String id;
  final TipType type;

  
  final String title;
  final String body;

  
  final String? reason;

  
  final String? contextTag; 

  
  final int priority;

  
  final String? ctaLabel;
  final String? ctaRoute; 

  
  final int? minAgeMonths;
  final int? maxAgeMonths;

  const TipItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.reason,
    this.contextTag,
    this.priority = 0,
    this.ctaLabel,
    this.ctaRoute,
    this.minAgeMonths,
    this.maxAgeMonths,
  });

  
  
  

  bool appliesToAge(int? ageMonths) {
    if (ageMonths == null) return true;
    if (minAgeMonths != null && ageMonths < minAgeMonths!) return false;
    if (maxAgeMonths != null && ageMonths > maxAgeMonths!) return false;
    return true;
  }

  TipItem copyWith({
    TipType? type,
    String? title,
    String? body,
    String? reason,
    String? contextTag,
    int? priority,
    String? ctaLabel,
    String? ctaRoute,
    int? minAgeMonths,
    int? maxAgeMonths,
  }) {
    return TipItem(
      id: id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      reason: reason ?? this.reason,
      contextTag: contextTag ?? this.contextTag,
      priority: priority ?? this.priority,
      ctaLabel: ctaLabel ?? this.ctaLabel,
      ctaRoute: ctaRoute ?? this.ctaRoute,
      minAgeMonths: minAgeMonths ?? this.minAgeMonths,
      maxAgeMonths: maxAgeMonths ?? this.maxAgeMonths,
    );
  }

  
  
  

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'body': body,
        'reason': reason,
        'contextTag': contextTag,
        'priority': priority,
        'ctaLabel': ctaLabel,
        'ctaRoute': ctaRoute,
        'minAgeMonths': minAgeMonths,
        'maxAgeMonths': maxAgeMonths,
      };

  factory TipItem.fromJson(Map<String, dynamic> j) {
    final typeStr = (j['type'] ?? 'info').toString();
    final type = TipType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => TipType.info,
    );

    return TipItem(
      id: (j['id'] ?? '').toString(),
      type: type,
      title: (j['title'] ?? '').toString(),
      body: (j['body'] ?? '').toString(),
      reason: j['reason']?.toString(),
      contextTag: j['contextTag']?.toString(),
      priority: (j['priority'] is num) ? (j['priority'] as num).toInt() : 0,
      ctaLabel: j['ctaLabel']?.toString(),
      ctaRoute: j['ctaRoute']?.toString(),
      minAgeMonths: (j['minAgeMonths'] is num) ? (j['minAgeMonths'] as num).toInt() : null,
      maxAgeMonths: (j['maxAgeMonths'] is num) ? (j['maxAgeMonths'] as num).toInt() : null,
    );
  }
}