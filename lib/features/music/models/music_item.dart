import 'package:audio_service/audio_service.dart';

class MusicItem {
  final String id;
  final String title;
  final String subtitle;
  final String assetPath;
  final String category;
  final bool loop;
  final Duration? duration;

  const MusicItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.category,
    this.loop = false,
    this.duration,
  });

  
  MediaItem toMediaItem() {
    return MediaItem(
      id: assetPath, 
      title: title,
      album: category,
      artist: 'NeoMama',
      artUri: Uri.parse('asset://assets/music/art/$category.png'),
      duration: duration,
      extras: {
        'id': id,
        'category': category,
        'loop': loop,
        'asset': assetPath,
      },
    );
  }

  MusicItem copyWith({
    bool? loop,
    Duration? duration,
  }) {
    return MusicItem(
      id: id,
      title: title,
      subtitle: subtitle,
      assetPath: assetPath,
      category: category,
      loop: loop ?? this.loop,
      duration: duration ?? this.duration,
    );
  }
}