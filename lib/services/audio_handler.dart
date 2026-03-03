import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

late AudioHandler audioHandler;


Future<void> initAudioHandler() async {
  audioHandler = await AudioService.init(
    builder: () => NeoAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.neomama.audio',
      androidNotificationChannelName: 'NeoMama Audio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class NeoAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<int?>? _indexSub;
  StreamSubscription<PlaybackEvent>? _playbackSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<SequenceState?>? _sequenceSub;

  bool _disposed = false;

  NeoAudioHandler() {
    _wirePlayerStreams();
  }

  void _wirePlayerStreams() {
    
    _sequenceSub = _player.sequenceStateStream.listen((seq) {
      final q = queue.value;
      final idx = seq.currentIndex;

      if (idx == null || idx < 0 || idx >= q.length) return;
      mediaItem.add(q[idx]);
    });

    _playbackSub = _player.playbackEventStream.listen((event) {
      final q = queue.value;
      final hasQueue = q.isNotEmpty;
      final playing = _player.playing;

      final idx = event.currentIndex ?? _player.currentIndex;
      final canSkipPrev = hasQueue && (idx ?? 0) > 0;
      final canSkipNext = hasQueue && (idx ?? 0) < (q.length - 1);

      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            if (canSkipPrev) MediaControl.skipToPrevious,
            playing ? MediaControl.pause : MediaControl.play,
            MediaControl.stop,
            if (canSkipNext) MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
            MediaAction.setRepeatMode,
            MediaAction.setShuffleMode,
          },
          androidCompactActionIndices: const [0, 1, 2],
          processingState: _mapProcessingState(_player.processingState),
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: idx,
          repeatMode: _mapRepeatMode(_player.loopMode),
          shuffleMode:
              _player.shuffleModeEnabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
        ),
      );
    });

    _durationSub = _player.durationStream.listen((duration) {
      final item = mediaItem.value;
      if (item == null || duration == null) return;
      mediaItem.add(item.copyWith(duration: duration));
    });
  }

  AudioProcessingState _mapProcessingState(ProcessingState s) {
    switch (s) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  AudioServiceRepeatMode _mapRepeatMode(LoopMode m) {
    switch (m) {
      case LoopMode.off:
        return AudioServiceRepeatMode.none;
      case LoopMode.one:
        return AudioServiceRepeatMode.one;
      case LoopMode.all:
        return AudioServiceRepeatMode.all;
    }
  }

  LoopMode _toLoopMode(AudioServiceRepeatMode m) {
    switch (m) {
      case AudioServiceRepeatMode.none:
        return LoopMode.off;
      case AudioServiceRepeatMode.one:
        return LoopMode.one;
      case AudioServiceRepeatMode.all:
        return LoopMode.all;
      case AudioServiceRepeatMode.group:
        
        return LoopMode.all;
    }
  }

  Future<void> _disposeInternal() async {
    if (_disposed) return;
    _disposed = true;

    await _indexSub?.cancel();
    await _playbackSub?.cancel();
    await _durationSub?.cancel();
    await _sequenceSub?.cancel();

    await _player.dispose();
  }

  
  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    this.queue.add(queue);

    if (queue.isEmpty) {
      await _player.stop();
      mediaItem.add(null);

      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.idle,
          playing: false,
          queueIndex: null,
          updatePosition: Duration.zero,
          bufferedPosition: Duration.zero,
        ),
      );
      return;
    }

    
    final currentId = mediaItem.value?.id;
    final keepIndex = currentId == null
        ? 0
        : queue.indexWhere((m) => m.id == currentId);

    final initialIndex = keepIndex >= 0 ? keepIndex : 0;

    
    final sources = queue
        .map((item) => AudioSource.asset(item.id))
        .toList(growable: false);

    await _player.setAudioSources(
      sources,
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );

    mediaItem.add(queue[initialIndex]);
  }

  
  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    final q = queue.value;
    final idx = q.indexWhere((m) => m.id == mediaItem.id);

    if (idx >= 0) {
      await skipToQueueItem(idx);
      return;
    }

    
    await updateQueue([mediaItem]);
    await play();
  }

  @override
  Future<void> play() async {
    if (_player.processingState == ProcessingState.completed) {
      final idx = _player.currentIndex ?? 0;
      await _player.seek(Duration.zero, index: idx);
    }
    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();

    
    mediaItem.add(null);

    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
        queueIndex: null,
        updatePosition: Duration.zero,
        bufferedPosition: Duration.zero,
      ),
    );

    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    final idx = _player.currentIndex ?? 0;
    final q = queue.value;
    if (q.isEmpty) return;
    if (idx >= q.length - 1) return; 

    await _player.seekToNext();
    if (!_player.playing) await _player.play();
  }

  @override
  Future<void> skipToPrevious() async {
    final idx = _player.currentIndex ?? 0;
    final q = queue.value;
    if (q.isEmpty) return;
    if (idx <= 0) return; 

    await _player.seekToPrevious();
    if (!_player.playing) await _player.play();
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    final q = queue.value;
    if (index < 0 || index >= q.length) return;

    await _player.seek(Duration.zero, index: index);
    await _player.play();
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    await _player.setLoopMode(_toLoopMode(repeatMode));
    
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enable = shuffleMode == AudioServiceShuffleMode.all;
    await _player.setShuffleModeEnabled(enable);
    if (enable) {
      await _player.shuffle();
    }
    
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _disposeInternal();
      return true;
    }
    return super.customAction(name, extras);
  }
}
