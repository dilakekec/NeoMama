import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

import 'models/music_track.dart';

class MusicService extends ChangeNotifier {
  MusicService._();
  static final MusicService instance = MusicService._();

  final AudioPlayer _player = AudioPlayer();

  MusicTrack? _current;

  bool _busy = false;

  
  bool _initialized = false;
  Future<void>? _initFuture;

  
  Object? _lastError;
  Object? get lastError => _lastError;

  
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;

  
  DateTime _lastNotify = DateTime.fromMillisecondsSinceEpoch(0);

  MusicTrack? get current => _current;
  bool get isBusy => _busy;
  bool get isPlaying => _player.playing;

  Duration get position => _player.position;
  Duration? get duration => _player.duration;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Future<void> init() {
    if (_initialized) return Future.value();
    return _initFuture ??= _initInternal();
  }

  Future<void> _initInternal() async {
    if (_initialized) return;
    _initialized = true;

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    
    _player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace st) {
        _lastError = e;
        if (kDebugMode) {
          debugPrint('MusicService playback error: $e');
        }
        _notifySoon();
      },
    );

    
    _stateSub = _player.playerStateStream.listen((st) {
      
      if (st.processingState == ProcessingState.completed) {
        
        _notifySoon(force: true);
      } else {
        _notifySoon();
      }
    });

    
    _posSub = _player.positionStream.listen((_) => _notifySoon());

    
    _durSub = _player.durationStream.listen((_) => _notifySoon(force: true));
  }

  Future<void> playTrack(MusicTrack track) async {
    await init();

    
    if (_current?.id == track.id) {
      if (!_player.playing) {
        await _player.play();
        _notifySoon(force: true);
      }
      return;
    }

    _setBusy(true);
    _lastError = null;

    try {
      _current = track;

      
      await _player.stop();

      await _player.setLoopMode(track.loop ? LoopMode.one : LoopMode.off);

      
      await _player.setAudioSource(
        AudioSource.asset(track.assetPath),
        preload: true,
      );

      await _player.play();
      _notifySoon(force: true);
    } catch (e) {
      _lastError = e;
      if (kDebugMode) {
        debugPrint('MusicService playTrack ERROR: $e');
      }
      _notifySoon(force: true);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> togglePlayPause() async {
    await init();

    
    if (_current == null) return;

    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        
        if (_player.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero);
        }
        await _player.play();
      }
      _notifySoon(force: true);
    } catch (e) {
      _lastError = e;
      if (kDebugMode) {
        debugPrint('MusicService togglePlayPause ERROR: $e');
      }
      _notifySoon(force: true);
      rethrow;
    }
  }

  Future<void> stop() async {
    await init();
    try {
      await _player.stop();
      _notifySoon(force: true);
    } catch (e) {
      _lastError = e;
      if (kDebugMode) {
        debugPrint('MusicService stop ERROR: $e');
      }
      _notifySoon(force: true);
      rethrow;
    }
  }

  Future<void> seek(Duration d) async {
    await init();
    try {
      await _player.seek(d);
      _notifySoon();
    } catch (e) {
      _lastError = e;
      if (kDebugMode) {
        debugPrint('MusicService seek ERROR: $e');
      }
      _notifySoon(force: true);
      rethrow;
    }
  }

  Future<void> setLoop(bool loop) async {
    await init();
    try {
      await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      if (_current != null) _current = _current!.copyWith(loop: loop);
      _notifySoon(force: true);
    } catch (e) {
      _lastError = e;
      if (kDebugMode) {
        debugPrint('MusicService setLoop ERROR: $e');
      }
      _notifySoon(force: true);
      rethrow;
    }
  }

  void _setBusy(bool v) {
    if (_busy == v) return;
    _busy = v;
    _notifySoon(force: true);
  }

  void _notifySoon({bool force = false}) {
    final now = DateTime.now();
    final diffMs = now.difference(_lastNotify).inMilliseconds;

    
    if (!force && diffMs < 250) return;

    _lastNotify = now;
    notifyListeners();
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}
