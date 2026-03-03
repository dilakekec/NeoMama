import 'package:neomama/l10n/app_strings.dart';
import 'models/music_track.dart';

class MusicLibrary {
  const MusicLibrary._();

  static const List<_TrackSeed> _seeds = [
    _TrackSeed(
      id: 'piano_lullaby',
      titleKey: 'music_track_piano_lullaby_title',
      subtitleKey: 'music_track_piano_lullaby_sub',
      assetPath: 'assets/music/lullabies/piano_lullaby.mp3',
      category: 'lullabies',
      loop: false,
    ),
    _TrackSeed(
      id: 'white_noise',
      titleKey: 'music_track_white_noise_title',
      subtitleKey: 'music_track_white_noise_sub',
      assetPath: 'assets/music/noise/white_noise.mp3',
      category: 'noise',
      loop: true,
    ),
    _TrackSeed(
      id: 'pink_noise',
      titleKey: 'music_track_pink_noise_title',
      subtitleKey: 'music_track_pink_noise_sub',
      assetPath: 'assets/music/noise/pink_noise.mp3',
      category: 'noise',
      loop: true,
    ),
    _TrackSeed(
      id: 'brown_noise',
      titleKey: 'music_track_brown_noise_title',
      subtitleKey: 'music_track_brown_noise_sub',
      assetPath: 'assets/music/noise/brown_noise.mp3',
      category: 'noise',
      loop: true,
    ),
    _TrackSeed(
      id: 'calm_night',
      titleKey: 'music_track_calm_night_title',
      subtitleKey: 'music_track_calm_night_sub',
      assetPath: 'assets/music/nature/calm_night.mp3',
      category: 'nature',
      loop: true,
    ),
    _TrackSeed(
      id: 'humming',
      titleKey: 'music_track_humming_title',
      subtitleKey: 'music_track_humming_sub',
      assetPath: 'assets/music/voice/humming.mp3',
      category: 'voice',
      loop: true,
    ),
    _TrackSeed(
      id: 'womb_sounds',
      titleKey: 'music_track_womb_sounds_title',
      subtitleKey: 'music_track_womb_sounds_sub',
      assetPath: 'assets/music/womb/womb_sounds.mp3',
      category: 'womb',
      loop: true,
    ),
  ];

  static List<MusicTrack> tracksFor(String code) {
    return _seeds
        .map(
          (s) => MusicTrack(
            id: s.id,
            title: AppStrings.byCode(code, s.titleKey),
            subtitle: AppStrings.byCode(code, s.subtitleKey),
            assetPath: s.assetPath,
            category: s.category,
            loop: s.loop,
          ),
        )
        .toList();
  }

  static List<MusicTrack> byCategory(String category, {required String code}) {
    return tracksFor(code).where((t) => t.category == category).toList();
  }
}

class _TrackSeed {
  final String id;
  final String titleKey;
  final String subtitleKey;
  final String assetPath;
  final String category;
  final bool loop;

  const _TrackSeed({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.assetPath,
    required this.category,
    required this.loop,
  });
}
