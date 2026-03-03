import 'package:flutter/material.dart';

import 'community_models.dart';
import 'community_repository.dart';
import 'community_moderation_service.dart';
import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class CommunityRoomScreen extends StatefulWidget {
  final CommunityRoom room;

  const CommunityRoomScreen({
    super.key,
    required this.room,
  });

  @override
  State<CommunityRoomScreen> createState() => _CommunityRoomScreenState();
}

class _CommunityRoomScreenState extends State<CommunityRoomScreen> {
  late final CommunityRepository _repo;
  late final CommunityModerationService _moderation;
  CommunityRoom? _room;
  String _localeCode = 'en';
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    _repo = CommunityRepository();
    _moderation = CommunityModerationService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = Localizations.localeOf(context).languageCode;
    if (_didInit && code == _localeCode) return;
    _didInit = true;
    _localeCode = code;
    _loadRoom();
  }

  Future<void> _loadRoom() async {
    final room = await _repo.loadRoom(widget.room.id, _localeCode);
    if (!mounted) return;
    setState(() => _room = room ?? widget.room);
  }

  Future<void> _voteWorked(String id) async {
    final messenger = ScaffoldMessenger.of(context);
    await _repo.voteWorked(id);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(AppStrings.t(context, 'community_vote_thanks'))),
    );
    await _loadRoom();
  }

  Future<void> _openShareSheet() async {
    final room = _room ?? widget.room;
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final selected = <String>{};

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (ctx) {
        final t = Theme.of(ctx).textTheme;
        final cs = Theme.of(ctx).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: NeoCard(
              padding: const EdgeInsets.all(16),
              child: StatefulBuilder(
                builder: (ctx, setModal) {
                  final title = titleCtrl.text.trim();
                  final body = bodyCtrl.text.trim();
                  final valid = title.length >= 4 && body.length >= 12;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.t(ctx, 'community_share_title'),
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleCtrl,
                        onChanged: (_) => setModal(() {}),
                        decoration: InputDecoration(
                          hintText: AppStrings.t(ctx, 'community_share_hint'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: bodyCtrl,
                        onChanged: (_) => setModal(() {}),
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: AppStrings.t(ctx, 'community_share_body_hint'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppStrings.t(ctx, 'community_share_tags'),
                        style: t.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: room.tags.map((tag) {
                          final on = selected.contains(tag);
                          return GestureDetector(
                            onTap: () => setModal(() {
                              if (on) {
                                selected.remove(tag);
                              } else {
                                selected.add(tag);
                              }
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: on ? cs.primary.o(0.16) : Colors.transparent,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: on ? cs.primary.o(0.35) : cs.outlineVariant,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: t.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: on ? cs.primary : cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(AppStrings.t(ctx, 'cancel')),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              onPressed: valid
                                  ? () async {
                                      final input = '${titleCtrl.text}\n${bodyCtrl.text}';
                                      final result = _moderation.review(input);
                                      if (result.review == AiReview.block) {
                                        final msg = AppStrings.t(
                                          ctx,
                                          result.reasonKey ?? 'community_moderation_block',
                                        );
                                        ScaffoldMessenger.of(ctx).showSnackBar(
                                          SnackBar(content: Text(msg)),
                                        );
                                        return;
                                      }

                                      if (result.review == AiReview.caution) {
                                        final msg = AppStrings.t(
                                          ctx,
                                          result.reasonKey ?? 'community_moderation_caution',
                                        );
                                        final proceed = await showDialog<bool>(
                                          context: ctx,
                                          builder: (_) => AlertDialog(
                                            title: Text(AppStrings.t(
                                                ctx, 'community_moderation_title')),
                                            content: Text(msg),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, false),
                                                child: Text(AppStrings.t(ctx, 'cancel')),
                                              ),
                                              FilledButton(
                                                onPressed: () => Navigator.pop(ctx, true),
                                                child: Text(AppStrings.t(
                                                    ctx, 'community_moderation_continue')),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (!ctx.mounted) return;
                                        if (proceed != true) return;
                                      }

                                      final navigator = Navigator.of(ctx);
                                      final exp = CommunityExperience(
                                        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
                                        title: title,
                                        body: body,
                                        tags: selected.isEmpty
                                            ? room.tags.take(1).toList()
                                            : selected.toList(),
                                        workedCount: 0,
                                        aiReview: result.review,
                                        medicalClaim: result.medicalClaim,
                                      );
                                      await _repo.addExperience(room.id, exp);
                                      if (!mounted) return;
                                      navigator.pop();
                                      await _loadRoom();
                                    }
                                  : null,
                              child: Text(AppStrings.t(ctx, 'community_share_submit')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final room = _room ?? widget.room;

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(room.title, style: t.titleLarge),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            NeoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.question,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: room.tags
                        .map((tag) => _TagPill(label: tag, tone: cs.primary))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _TagPill(
                        label: AppStrings.t(context, 'community_ai_premod'),
                        tone: cs.secondary,
                      ),
                      const SizedBox(width: 8),
                      _TagPill(
                        label: AppStrings.t(context, 'community_med_filter'),
                        tone: cs.tertiary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            NeoCard(
              onTap: _openShareSheet,
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppStrings.t(context, 'community_share_cta'),
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Text(
              AppStrings.t(context, 'community_room_experiences'),
              style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),

            ...room.experiences.map(
              (exp) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                  child: _ExperienceItem(
                    exp: exp,
                    workedCount: exp.workedCount,
                    onVote: () => _voteWorked(exp.id),
                  ),
                ),
            ),

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
        ),
      ),
    );
  }
}

class _ExperienceItem extends StatelessWidget {
  final CommunityExperience exp;
  final int workedCount;
  final VoidCallback onVote;

  const _ExperienceItem({
    required this.exp,
    required this.workedCount,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final aiLabel = _aiLabel(context, exp.aiReview);
    final aiColor = _aiColor(context, exp.aiReview);

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exp.title,
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
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
              TextButton.icon(
                onPressed: onVote,
                icon: Icon(Icons.thumb_up_alt_rounded, size: 16, color: cs.secondary),
                label: Text(
                  '${AppStrings.t(context, 'community_vote_action')} $workedCount',
                  style: t.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.secondary,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
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
