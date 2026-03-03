import 'package:flutter/foundation.dart';

@immutable
class TomorrowPreview {
  
  final String title;

  
  final String body;

  
  final String? reason;

  
  final PreviewType type;

  
  final int priority;

  
  final String? ctaLabel;
  final String? ctaRoute;

  const TomorrowPreview({
    required this.title,
    required this.body,
    this.reason,
    this.type = PreviewType.info,
    this.priority = 0,
    this.ctaLabel,
    this.ctaRoute,
  });

  TomorrowPreview copyWith({
    String? title,
    String? body,
    String? reason,
    PreviewType? type,
    int? priority,
    String? ctaLabel,
    String? ctaRoute,
  }) {
    return TomorrowPreview(
      title: title ?? this.title,
      body: body ?? this.body,
      reason: reason ?? this.reason,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      ctaLabel: ctaLabel ?? this.ctaLabel,
      ctaRoute: ctaRoute ?? this.ctaRoute,
    );
  }

  
  
  

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'reason': reason,
        'type': type.name,
        'priority': priority,
        'ctaLabel': ctaLabel,
        'ctaRoute': ctaRoute,
      };

  factory TomorrowPreview.fromJson(Map<String, dynamic> j) {
    final typeStr = (j['type'] ?? 'info').toString();
    final type = PreviewType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => PreviewType.info,
    );

    return TomorrowPreview(
      title: (j['title'] ?? '').toString(),
      body: (j['body'] ?? '').toString(),
      reason: j['reason']?.toString(),
      type: type,
      priority: (j['priority'] is num) ? (j['priority'] as num).toInt() : 0,
      ctaLabel: j['ctaLabel']?.toString(),
      ctaRoute: j['ctaRoute']?.toString(),
    );
  }
}


enum PreviewType { info, headsUp, warning }