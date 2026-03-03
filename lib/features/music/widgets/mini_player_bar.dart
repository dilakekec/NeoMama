import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/services/audio_handler.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class MiniPlayerBar extends StatefulWidget {
  const MiniPlayerBar({super.key});

  @override
  State<MiniPlayerBar> createState() => _MiniPlayerBarState();
}

class _MiniPlayerBarState extends State<MiniPlayerBar> {
  StreamSubscription<PlaybackState>? _stateSub;
  StreamSubscription<MediaItem?>? _itemSub;

  PlaybackState? _state;
  MediaItem? _item;

  @override
  void initState() {
    super.initState();

    _stateSub = audioHandler.playbackState.listen((s) {
      if (!mounted) return;
      setState(() => _state = s);
    });

    _itemSub = audioHandler.mediaItem.listen((m) {
      if (!mounted) return;
      setState(() => _item = m);
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _itemSub?.cancel();
    super.dispose();
  }

  bool _isDisabled(AudioProcessingState p) {
    return p == AudioProcessingState.loading ||
        p == AudioProcessingState.buffering;
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    if (item == null) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final state = _state;
    final playing = state?.playing ?? false;
    final processing = state?.processingState ?? AudioProcessingState.idle;
    final disabled = _isDisabled(processing);

    final subtitle = (item.artist?.trim().isNotEmpty ?? false)
        ? item.artist!.trim()
        : (item.album ?? '').trim();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: NeoCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          onTap: () {
            
          },
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cs.primary.o(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  disabled
                      ? Icons.hourglass_bottom_rounded
                      : Icons.music_note_rounded,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle.isEmpty ? AppStrings.t(context, 'now_playing') : subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              IconButton(
                tooltip: playing
                    ? AppStrings.t(context, 'pause')
                    : AppStrings.t(context, 'play'),
                onPressed: disabled
                    ? null
                    : () async {
                        if (playing) {
                          await audioHandler.pause();
                        } else {
                          await audioHandler.play();
                        }
                      },
                icon: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 28,
                  color: disabled ? cs.onSurfaceVariant : cs.primary,
                ),
              ),

              IconButton(
                tooltip: AppStrings.t(context, 'stop'),
                onPressed: disabled ? null : () => audioHandler.stop(),
                icon: Icon(
                  Icons.close_rounded,
                  color: disabled ? cs.onSurfaceVariant : cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
