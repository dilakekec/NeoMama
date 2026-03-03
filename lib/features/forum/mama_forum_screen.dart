import 'package:flutter/material.dart';
import 'forum_thread_screen.dart';
import 'community_models.dart';
import 'community_repository.dart';
import 'community_seed.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class MamaForumScreen extends StatefulWidget {
  const MamaForumScreen({super.key});

  @override
  State<MamaForumScreen> createState() => _MamaForumScreenState();
}

class _MamaForumScreenState extends State<MamaForumScreen> {
  late final CommunityRepository _repo;
  late Future<List<CommunityRoom>> _roomsFuture;
  String _localeCode = 'en';
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    _repo = CommunityRepository();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = Localizations.localeOf(context).languageCode;
    if (_didInit && code == _localeCode) return;
    _didInit = true;
    _localeCode = code;
    _roomsFuture = _repo.loadRooms(code);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final code = Localizations.localeOf(context).languageCode;

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'community_title'), style: t.titleLarge),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: FutureBuilder<List<CommunityRoom>>(
          future: _roomsFuture,
          builder: (context, snap) {
            final rooms = snap.data ?? communityRoomsFor(code);
            final feed = [
              for (final r in rooms) ...r.experiences.take(1).map((e) => (room: r, exp: e)),
              for (final r in rooms) ...r.experiences.skip(1).take(1).map((e) => (room: r, exp: e)),
            ];

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                NeoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.t(context, 'community_subtitle'),
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.t(context, 'community_desc'),
                        style: t.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FeatureChip(
                            label: AppStrings.t(context, 'community_ai_premod'),
                            icon: Icons.verified_outlined,
                          ),
                          _FeatureChip(
                            label: AppStrings.t(context, 'community_med_filter'),
                            icon: Icons.health_and_safety_outlined,
                          ),
                          _FeatureChip(
                            label: AppStrings.t(context, 'community_worked_vote'),
                            icon: Icons.thumb_up_alt_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  AppStrings.t(context, 'community_rooms'),
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: rooms.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final room = rooms[i];
                      return _RoomCard(
                        room: room,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CommunityRoomScreen(room: room),
                            ),
                          );
                          if (!mounted) return;
                          setState(() {
                            _roomsFuture = _repo.loadRooms(code);
                          });
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  AppStrings.t(context, 'community_pool'),
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),

                ...feed.map((pair) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ExperienceCard(
                        room: pair.room,
                        exp: pair.exp,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CommunityRoomScreen(room: pair.room),
                            ),
                          );
                          if (!mounted) return;
                          setState(() {
                            _roomsFuture = _repo.loadRooms(code);
                          });
                        },
                      ),
                    )),

                const SizedBox(height: 6),

                Text(
                  AppStrings.t(context, 'community_disclaimer'),
                  style: t.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FeatureChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.o(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.o(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: t.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final CommunityRoom room;
  final VoidCallback onTap;

  const _RoomCard({required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: 220,
      child: NeoCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(room.emoji, style: t.headlineSmall),
            const SizedBox(height: 8),
            Text(
              room.title,
              style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              room.question,
              style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: room.tags
                  .map((tag) => _TagPill(label: tag, tone: cs.secondary))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final CommunityRoom room;
  final CommunityExperience exp;
  final VoidCallback onTap;

  const _ExperienceCard({
    required this.room,
    required this.exp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final aiLabel = _aiLabel(context, exp.aiReview);
    final aiColor = _aiColor(context, exp.aiReview);

    return NeoCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(room.emoji, style: t.headlineSmall),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.title,
                      style: t.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exp.title,
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            exp.body,
            style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.35),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                exp.tags.map((tag) => _TagPill(label: tag, tone: cs.primary)).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _TagPill(label: aiLabel, tone: aiColor),
              if (exp.medicalClaim) ...[
                const SizedBox(width: 6),
                _TagPill(
                  label: AppStrings.t(context, 'community_med_claim'),
                  tone: cs.error,
                ),
              ],
              const Spacer(),
              _WorkedBadge(count: exp.workedCount),
            ],
          ),
        ],
      ),
    );
  }

  String _aiLabel(BuildContext context, AiReview review) {
    return switch (review) {
      AiReview.pass => AppStrings.t(context, 'community_ai_pass'),
      AiReview.caution => AppStrings.t(context, 'community_ai_caution'),
      AiReview.block => AppStrings.t(context, 'community_ai_block'),
    };
  }

  Color _aiColor(BuildContext context, AiReview review) {
    final cs = Theme.of(context).colorScheme;
    return switch (review) {
      AiReview.pass => cs.primary,
      AiReview.caution => cs.tertiary,
      AiReview.block => cs.error,
    };
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  final Color tone;

  const _TagPill({
    required this.label,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.o(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.o(0.2)),
      ),
      child: Text(
        label,
        style: t.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: tone,
        ),
      ),
    );
  }
}

class _WorkedBadge extends StatelessWidget {
  final int count;
  const _WorkedBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.secondary.o(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.secondary.o(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.thumb_up_alt_rounded, size: 14, color: cs.secondary),
          const SizedBox(width: 6),
          Text(
            '${AppStrings.t(context, 'community_worked_vote')} $count',
            style: t.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
