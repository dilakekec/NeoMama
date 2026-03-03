import 'package:audio_service/audio_service.dart';

const _base = 'assets/music';

MediaItem _item({
  required String id,
  required String title,
  required String category,
  required String file,
}) {
  return MediaItem(
    id: '$_base/$file',
    title: title,
    album: category,
    artist: 'NeoMama',
    artUri: Uri.parse('asset://$_base/art/$category.png'),
    extras: {
      'category': category,
      'asset': '$_base/$file',
    },
  );
}


final lullabies = <MediaItem>[
  _item(
    id: 'lullaby_piano',
    title: 'Piano Lullaby',
    category: 'Lullabies',
    file: 'lullabies/piano_lullaby.mp3',
  ),
];


final noise = <MediaItem>[
  _item(
    id: 'noise_white',
    title: 'White Noise',
    category: 'Noise',
    file: 'noise/white_noise.mp3',
  ),
  _item(
    id: 'noise_pink',
    title: 'Pink Noise',
    category: 'Noise',
    file: 'noise/pink_noise.mp3',
  ),
  _item(
    id: 'noise_brown',
    title: 'Brown Noise',
    category: 'Noise',
    file: 'noise/brown_noise.mp3',
  ),
];


final nature = <MediaItem>[
  _item(
    id: 'nature_calm_night',
    title: 'Calm Night',
    category: 'Nature',
    file: 'nature/calm_night.mp3',
  ),
];


final voice = <MediaItem>[
  _item(
    id: 'voice_humming',
    title: 'Humming',
    category: 'Voice',
    file: 'voice/humming.mp3',
  ),
];


final womb = <MediaItem>[
  _item(
    id: 'womb_sounds',
    title: 'Womb Sounds',
    category: 'Womb',
    file: 'womb/womb_sounds.mp3',
  ),
];
