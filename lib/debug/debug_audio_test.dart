import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class DebugAudioTest extends StatefulWidget {
  const DebugAudioTest({super.key});

  @override
  State<DebugAudioTest> createState() => _DebugAudioTestState();
}

class _DebugAudioTestState extends State<DebugAudioTest> {
  final _p = AudioPlayer();

  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<PlaybackEvent>? _eventSub;

  String _status = 'init';
  String? _error;

  static const _asset = 'assets/music/nature/calm_night.mp3';

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      _stateSub = _p.playerStateStream.listen((s) {
        if (!mounted) return;
        setState(() {
          _status =
              'playing=${s.playing} | state=${s.processingState} | pos=${_p.position.inSeconds}s';
        });
      });

      _eventSub = _p.playbackEventStream.listen(
        (_) {},
        onError: (Object e, StackTrace st) {
          if (!mounted) return;
          setState(() => _error = 'PLAYBACK ERROR: $e');
        },
      );

      if (!mounted) return;
      setState(() {
        _status = 'loading asset...';
        _error = null;
      });

      await _p.setAsset(_asset);
      await _p.play();

      if (!mounted) return;
      setState(() => _status = 'playing');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'LOAD ERROR: $e');
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _eventSub?.cancel();
    _p.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio debug')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Asset: $_asset\n\n$_status\n\n${_error ?? ''}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_p.playing) {
            await _p.pause();
          } else {
            await _p.play();
          }
          if (!mounted) return;
          setState(() {});
        },
        child: Icon(_p.playing ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}