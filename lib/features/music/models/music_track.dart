import 'package:audio_service/audio_service.dart';

class MusicTrack {
  final String id;
  final String title;
  final String subtitle;
  final String assetPath;
  final String category;

  
  final bool loop;

  
  final Duration? duration;

  const MusicTrack({
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
      duration: duration,
      extras: {
        'id': id,
        'category': category,
        'loop': loop,
        'asset': assetPath,
      },
    );
  }

  MusicTrack copyWith({
    bool? loop,
    Duration? duration,
  }) {
    return MusicTrack(
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