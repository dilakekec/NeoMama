enum TipType { feeding, sleep, play, health, mindset }

class TipItem {
  final String title;
  final String body;
  final TipType type;

  const TipItem({
    required this.title,
    required this.body,
    required this.type,
  });
}

class TomorrowPreview {
  final String title;
  final String body;

  const TomorrowPreview({
    required this.title,
    required this.body,
  });
}
