import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';

import 'package:neomama/services/audio_handler.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/l10n/app_strings.dart';

import 'widgets/mini_player_bar.dart';


import 'music_library.dart';
import 'models/music_track.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final code = Localizations.localeOf(context).languageCode;

    final categories = <_MusicCategory>[
      _MusicCategory(
        key: 'lullabies',
        title: AppStrings.t(context, 'music_lullabies'),
        subtitle: AppStrings.t(context, 'music_lullabies_sub'),
        icon: Icons.nightlight_round,
      ),
      _MusicCategory(
        key: 'noise',
        title: AppStrings.t(context, 'music_noise'),
        subtitle: AppStrings.t(context, 'music_noise_sub'),
        icon: Icons.graphic_eq,
      ),
      _MusicCategory(
        key: 'nature',
        title: AppStrings.t(context, 'music_nature'),
        subtitle: AppStrings.t(context, 'music_nature_sub'),
        icon: Icons.forest_outlined,
      ),
      _MusicCategory(
        key: 'voice',
        title: AppStrings.t(context, 'music_voice'),
        subtitle: AppStrings.t(context, 'music_voice_sub'),
        icon: Icons.record_voice_over_outlined,
      ),
      _MusicCategory(
        key: 'womb',
        title: AppStrings.t(context, 'music_womb'),
        subtitle: AppStrings.t(context, 'music_womb_sub'),
        icon: Icons.favorite_outline,
      ),
    ];

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'music'), style: t.titleLarge),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final c = categories[i];
                    final tracks = MusicLibrary.byCategory(c.key, code: code);

                    return _CategoryCard(
                      title: c.title,
                      subtitle: AppStrings.t(
                        context,
                        'music_track_count',
                        vars: {'subtitle': c.subtitle, 'count': '${tracks.length}'},
                      ),
                      icon: c.icon,
                      onTap: tracks.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MusicCategoryScreen(
                                    title: c.title,
                                    categoryKey: c.key,
                                  ),
                                ),
                              );
                            },
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: MiniPlayerBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MusicCategoryScreen extends StatelessWidget {
  final String title;
  final String categoryKey;

  const MusicCategoryScreen({
    super.key,
    required this.title,
    required this.categoryKey,
  });

  Future<void> _assertAssetExists(String path) async {
    final bd = await rootBundle.load(path);
    if (kDebugMode) {
      debugPrint('ASSET OK: $path bytes=${bd.lengthInBytes}');
    }
  }

  void _snack(BuildContext context, Object e) {
    if (kDebugMode) {
      debugPrint('Play failed: $e');
    }

    
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.t(context, 'play_failed', vars: {'error': '$e'}),
        ),
      ),
    );
  }

  MediaItem _toMediaItem(MusicTrack t, {required String album}) {
    return MediaItem(
      id: t.assetPath, 
      title: t.title,
      album: album,
      extras: {
        'loop': t.loop,
        'category': t.category,
        'trackId': t.id,
      },
    );
  }

  Future<void> _playAll(BuildContext context, List<MusicTrack> tracks) async {
    if (tracks.isEmpty) return;

    try {
      await _assertAssetExists(tracks.first.assetPath);

      final queue = tracks.map((x) => _toMediaItem(x, album: title)).toList();

      await audioHandler.updateQueue(queue);
      await audioHandler.skipToQueueItem(0);
      await audioHandler.play();
    } catch (e) {
      if (!context.mounted) return;
      _snack(context, e);
    }
  }

  Future<void> _playIndex(
    BuildContext context,
    List<MusicTrack> tracks,
    int index,
  ) async {
    if (tracks.isEmpty) return;
    if (index < 0 || index >= tracks.length) return;

    try {
      await _assertAssetExists(tracks[index].assetPath);

      final queue = tracks.map((x) => _toMediaItem(x, album: title)).toList();

      await audioHandler.updateQueue(queue);
      await audioHandler.skipToQueueItem(index);
      await audioHandler.play();
    } catch (e) {
      if (!context.mounted) return;
      _snack(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final code = Localizations.localeOf(context).languageCode;
    final tracks = MusicLibrary.byCategory(categoryKey, code: code);

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, style: t.titleLarge),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: _PlayAllCard(
                  trackCount: tracks.length,
                  onTap: tracks.isEmpty ? null : () => _playAll(context, tracks),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  itemCount: tracks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final m = tracks[i];
                    return _TrackCard(
                      title: m.title,
                      subtitle: m.subtitle,
                      loop: m.loop,
                      onTapPlay: () => _playIndex(context, tracks, i),
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: MiniPlayerBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MusicCategory {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;

  _MusicCategory({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return _Clickable(
      onTap: onTap,
      child: NeoCard(
        child: Row(
          children: [
            Icon(icon, size: 30, color: cs.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: t.bodyMedium),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _PlayAllCard extends StatelessWidget {
  final int trackCount;
  final VoidCallback? onTap;

  const _PlayAllCard({
    required this.trackCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return _Clickable(
      onTap: onTap,
      child: NeoCard(
        child: Row(
          children: [
            Icon(Icons.play_circle_fill, size: 38, color: cs.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.t(context, 'play_all'), style: t.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.t(
                      context,
                      'track_count',
                      vars: {'count': '$trackCount'},
                    ),
                    style: t.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(Icons.play_arrow, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool loop;
  final VoidCallback onTapPlay;

  const _TrackCard({
    required this.title,
    required this.subtitle,
    required this.loop,
    required this.onTapPlay,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return NeoCard(
      child: Row(
        children: [
          Icon(Icons.music_note, size: 30, color: cs.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: t.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (loop)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.loop_rounded,
                          size: 18,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: t.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton.outlined(
            tooltip: AppStrings.t(context, 'play'),
            icon: const Icon(Icons.play_arrow),
            onPressed: onTapPlay,
          ),
        ],
      ),
    );
  }
}

class _Clickable extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _Clickable({
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: child,
      ),
    );
  }
}
