import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState(); 
}

class _MusicScreenState extends State<MusicScreen> {
  final AudioPlayer _player = AudioPlayer();
  String? _currentlyPlaying;

  final List<Map<String, String>> _tracks = [
    {
      'title': 'Calm Night',
      'file': 'music/calm_night.mp3',
    },
    {
      'title': 'Lullaby', 
      'file': 'music/lullaby.mp3',
    },
  ];

  Future<void> _togglePlay(String filePath) async {
    if (_currentlyPlaying == filePath) {
      await _player.stop();
      setState(() => _currentlyPlaying = null);
    } else {
      await _player.stop();
      await _player.play(AssetSource(filePath));
      setState(() => _currentlyPlaying = filePath);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar(title: const Text('Lullaby Player')),
      body: ListView.builder(  
        padding: const EdgeInsets.all(16),
        itemCount: _tracks.length,
        itemBuilder: (context, index) {
          final track = _tracks[index];
          final isPlaying = _currentlyPlaying == track['file'];

          return Card(  
            shape: RoundedRectangleBorder(  
              borderRadius: BorderRadius.circular(12)),
            child: ListTile(  
              leading: const Icon(Icons.music_note),
              title: Text(track['title']!),
              trailing: IconButton(  
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () => _togglePlay(track['file']!),
              ),
            ),
          );
        },
      ),
    );
  }
}
