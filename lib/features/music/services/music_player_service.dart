import 'package:audio_service/audio_service.dart';

import '../data/music_playlists.dart';
import '../models/music_track.dart';

class MusicPlayerService {
  const MusicPlayerService();

  
  static Map<String, List<MusicTrack>> get categories => {
        'lullabies': lullabies as List<MusicTrack>,
        'noise': noise as List<MusicTrack>,
        'nature': nature as List<MusicTrack>,
        'voice': voice as List<MusicTrack>,
        'womb': womb as List<MusicTrack>,
      };

  
  static List<MusicTrack> get allTracks => [
        ...lullabies as List<MusicTrack>,
        ...noise as List<MusicTrack>,
        ...nature as List<MusicTrack>,
        ...voice as List<MusicTrack>,
        ...womb as List<MusicTrack>,
      ];

  
  static List<MediaItem> buildQueue({String? category}) {
    final tracks =
        category == null ? allTracks : (categories[category] ?? <MusicTrack>[]);

    return tracks.map((t) => t.toMediaItem()).toList();
  }

  
  static bool shouldLoop(MediaItem item) {
    final extras = item.extras;
    if (extras == null) return false;
    return extras['loop'] == true;
  }
}