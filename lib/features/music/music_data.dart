import 'models/music_track.dart';

const musicTracks = <MusicTrack>[
  MusicTrack(
    id: 'piano_lullaby',
    title: 'Piano Lullaby',
    subtitle: 'Minimal piano for sleep',
    assetPath: 'assets/music/lullabies/piano_lullaby.mp3',
    category: 'lullabies',
    loop: false,
  ),

  MusicTrack(
    id: 'calm_night',
    title: 'Calm Night',
    subtitle: 'Soft nocturnal ambience',
    assetPath: 'assets/music/nature/calm_night.mp3',
    category: 'nature',
    loop: true,
  ),

  MusicTrack(
    id: 'white_noise',
    title: 'White Noise',
    subtitle: 'Balanced steady sound',
    assetPath: 'assets/music/noise/white_noise.mp3',
    category: 'noise',
    loop: true,
  ),
  MusicTrack(
    id: 'pink_noise',
    title: 'Pink Noise',
    subtitle: 'Gentler low frequencies',
    assetPath: 'assets/music/noise/pink_noise.mp3',
    category: 'noise',
    loop: true,
  ),
  MusicTrack(
    id: 'brown_noise',
    title: 'Brown Noise',
    subtitle: 'Deep calming flow',
    assetPath: 'assets/music/noise/brown_noise.mp3',
    category: 'noise',
    loop: true,
  ),

  MusicTrack(
    id: 'humming',
    title: 'Humming',
    subtitle: 'Soothing human tone',
    assetPath: 'assets/music/voice/humming.mp3',
    category: 'voice',
    loop: true,
  ),

  MusicTrack(
    id: 'womb_sounds',
    title: 'Womb Sounds',
    subtitle: 'Familiar prenatal rhythm',
    assetPath: 'assets/music/womb/womb_sounds.mp3',
    category: 'womb',
    loop: true,
  ),
];