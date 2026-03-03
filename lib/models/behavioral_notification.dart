import 'package:flutter/foundation.dart';
import 'package:neomama/models/tip_models.dart';

@immutable
class BehavioralNotification {
  final String id;
  final TipType type;
  final String title;
  final String body;
  final String reason;
  final String ctaLabel;
  final DateTime scheduledAt;
  final int priority;

  const BehavioralNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.reason,
    required this.ctaLabel,
    required this.scheduledAt,
    this.priority = 0,
  });
}
