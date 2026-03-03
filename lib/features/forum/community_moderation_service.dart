import 'community_models.dart';

class ModerationResult {
  final AiReview review;
  final bool medicalClaim;
  final String? reasonKey;

  const ModerationResult({
    required this.review,
    required this.medicalClaim,
    this.reasonKey,
  });
}

class CommunityModerationService {
  ModerationResult review(String text) {
    final lower = text.toLowerCase();

    if (_containsAny(lower, _toxicWords)) {
      return const ModerationResult(
        review: AiReview.block,
        medicalClaim: false,
        reasonKey: 'community_moderation_toxic',
      );
    }

    final medical = _containsAny(lower, _medicalWords);
    final hardBlock = _containsAny(lower, _blockWords);

    if (hardBlock) {
      return const ModerationResult(
        review: AiReview.block,
        medicalClaim: true,
        reasonKey: 'community_moderation_med_block',
      );
    }

    if (medical) {
      return const ModerationResult(
        review: AiReview.caution,
        medicalClaim: true,
        reasonKey: 'community_moderation_med_caution',
      );
    }

    return const ModerationResult(
      review: AiReview.pass,
      medicalClaim: false,
    );
  }

  bool _containsAny(String text, List<String> words) {
    for (final w in words) {
      if (text.contains(w)) return true;
    }
    return false;
  }
}

const List<String> _medicalWords = [
  'antibiotic',
  'antibiyotik',
  'ibuprofen',
  'paracetamol',
  'parasetamol',
  'tylenol',
  'advil',
  'dose',
  'doz',
  'mg',
  'ml',
  'prescribe',
  'prescribed',
  'reçete',
  'vaccine',
  'aşı',
  'diagnose',
  'teşhis',
  'treatment',
  'tedavi',
];

const List<String> _blockWords = [
  'stop vaccine',
  'aşı yaptırma',
  'aşı yaptirmayin',
  'bleach',
  'çamaşır suyu',
  'herbal cure',
  'mucize tedavi',
];

const List<String> _toxicWords = [
  'idiot',
  'stupid',
  'salak',
  'aptal',
  'gerizekali',
  'gerizekalı',
];
