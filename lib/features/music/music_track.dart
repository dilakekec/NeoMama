class MusicTrack {
  final String id;
  final String title;
  final String subtitle;
  final String assetPath;
  final String category;
  final bool loop;

  const MusicTrack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.category,
    this.loop = true,
  });
}