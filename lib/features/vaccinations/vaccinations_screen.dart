import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:neomama/models/baby_profile.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';

import 'data/vaccinations_data.dart';
import 'models/vaccination_models.dart';
import 'vaccinations_service.dart';
import 'vaccinations_item.dart';
import 'utils/vaccinations_due.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class VaccinationsScreen extends StatefulWidget {
  final BabyProfile baby;
  const VaccinationsScreen({super.key, required this.baby});

  @override
  State<VaccinationsScreen> createState() => _VaccinationsScreenState();
}

class _VaccinationsScreenState extends State<VaccinationsScreen> {
  final _svc = VaccinationsService();
  Map<String, VaccinationState> _state = {};
  bool _loading = true;

  String get _babyKey => widget.baby.id.toString();

  
  DateTime? get _dob => safeParseIsoDate(widget.baby.birthDate);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _svc.load(_babyKey);
    if (!mounted) return;
    setState(() {
      _state = data;
      _loading = false;
    });
  }

  int get _done => _state.values.where((v) => v.done).length;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final code = Localizations.localeOf(context).languageCode;
    final items = vaccinationsDataFor(code);
    final total = items.length;
    final progress = total == 0 ? 0.0 : (_done / total).clamp(0.0, 1.0);

    
    final groups = <String, List<VaccinationItem>>{};
    for (final v in items) {
      groups.putIfAbsent(v.monthLabel, () => []).add(v);
    }

    
    int groupMonth(String label) {
      
      final list = groups[label]!;
      list.sort((a, b) => a.dueMonth.compareTo(b.dueMonth));
      return list.first.dueMonth;
    }

    final sortedEntries = groups.entries.toList()
      ..sort((a, b) => groupMonth(a.key).compareTo(groupMonth(b.key)));

    final next = _nextVaccine(items);
    final nextDue = next == null
        ? null
        : computeDueInfo(
            item: next,
            state: _state[next.id] ?? const VaccinationState(done: false),
            dob: _dob,
          );

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'vaccinations'), style: t.titleLarge),
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _ProgressHeaderNeo(
                      babyName: widget.baby.name,
                      done: _done,
                      total: total,
                      progress: progress,
                      onReset: _resetAll,
                    ),
                    const SizedBox(height: 14),

                    if (next != null && nextDue != null) ...[
                      _NextActionCardNeo(
                        item: next,
                        meta: _nextMetaFromDue(nextDue),
                        dueText: _dueText(next, nextDue),
                        onTap: () => _openEditSheet(next),
                      ),
                      const SizedBox(height: 14),
                    ],

                    for (final e in sortedEntries)
                      _MonthSectionNeo(
                        title: e.key, 
                        items: (e.value..sort((a, b) => a.dueMonth.compareTo(b.dueMonth))),
                        state: _state,
                        dob: _dob,
                        onTapItem: _openEditSheet,
                      ),

                    const SizedBox(height: 16),
                    Text(
                      AppStrings.t(context, 'vaccinations_tip'),
                      style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  
  
  

  VaccinationItem? _nextVaccine(List<VaccinationItem> items) {
    final sorted = [...items]..sort((a, b) => a.dueMonth.compareTo(b.dueMonth));

    for (final v in sorted) {
      final st = _state[v.id] ?? const VaccinationState(done: false);
      if (!st.done) return v;
    }
    return null;
  }

  _NextMeta _nextMetaFromDue(DueInfo due) {
    final cs = Theme.of(context).colorScheme;

    switch (due.status) {
      case DueStatus.overdue:
        return _NextMeta(
          label: AppStrings.t(context, 'due_overdue'),
          color: cs.error,
          icon: Icons.warning_rounded,
        );
      case DueStatus.upcoming:
        return _NextMeta(
          label: AppStrings.t(context, 'due_upcoming'),
          color: cs.tertiary,
          icon: Icons.schedule_rounded,
        );
      case DueStatus.scheduled:
        return _NextMeta(
          label: AppStrings.t(context, 'due_next'),
          color: cs.primary,
          icon: Icons.vaccines_outlined,
        );
      case DueStatus.done:
        return _NextMeta(
          label: AppStrings.t(context, 'done'),
          color: cs.primary,
          icon: Icons.check_rounded,
        );
      case DueStatus.unknown:
        return _NextMeta(
          label: AppStrings.t(context, 'next_vaccine'),
          color: cs.primary,
          icon: Icons.vaccines_outlined,
        );
    }
  }

  String _dueText(VaccinationItem item, DueInfo due) {
    
    
    if (due.status == DueStatus.unknown || due.dueDate == null) {
      return item.monthLabel;
    }
    return '${item.monthLabel} • ~${_fmtDate(due.dueDate!)}';
  }

  
  
  

  Future<void> _resetAll() async {
    final t = Theme.of(context).textTheme;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.t(context, 'vaccinations_reset_title'), style: t.titleLarge),
        content: Text(
          AppStrings.t(context, 'vaccinations_reset_body'),
          style: t.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.t(context, 'cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.t(context, 'reset')),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _state = {});
    await _svc.save(_babyKey, _state);
  }

  Future<void> _openEditSheet(VaccinationItem item) async {
    final current = _state[item.id] ?? const VaccinationState(done: false);

    final result = await showModalBottomSheet<_EditResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSheetNeo(item: item, initial: current),
    );

    if (result == null) return;

    final next = current.copyWith(
      done: result.done,
      dateIso: result.dateIso,
      note: result.note,
    );

    setState(() {
      final empty = !next.done &&
          (next.note == null || next.note!.trim().isEmpty) &&
          next.dateIso == null;

      if (empty) {
        _state.remove(item.id);
      } else {
        _state[item.id] = next;
      }
    });

    await _svc.save(_babyKey, _state);
  }

  
  
  

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }
}





class _NextActionCardNeo extends StatelessWidget {
  final VaccinationItem item;
  final _NextMeta meta;
  final String dueText;
  final VoidCallback onTap;

  const _NextActionCardNeo({
    required this.item,
    required this.meta,
    required this.dueText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: NeoCard(
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: meta.color.o(0.12),
                child: Icon(meta.icon, color: meta.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.label,
                      style: t.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: meta.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(item.title, style: t.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      dueText,
                      style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextMeta {
  final String label;
  final Color color;
  final IconData icon;

  const _NextMeta({
    required this.label,
    required this.color,
    required this.icon,
  });
}





class _ProgressHeaderNeo extends StatelessWidget {
  final String babyName;
  final int done;
  final int total;
  final double progress;
  final VoidCallback onReset;

  const _ProgressHeaderNeo({
    required this.babyName,
    required this.done,
    required this.total,
    required this.progress,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final safeName = babyName.trim().isEmpty
        ? AppStrings.t(context, 'baby')
        : babyName.trim();

    return NeoCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$safeName • ${AppStrings.t(context, 'vaccinations')}',
                  style: t.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.t(
                    context,
                    'vaccinations_completed',
                    vars: {'done': '$done', 'total': '$total'},
                  ),
                  style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: cs.surfaceContainerHighest.o(0.6),
                    valueColor: AlwaysStoppedAnimation(cs.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('${(progress * 100).round()}%', style: t.titleSmall),
          const SizedBox(width: 6),
          IconButton(
            onPressed: onReset,
            tooltip: AppStrings.t(context, 'reset'),
            icon: Icon(Icons.restart_alt_rounded, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}





class _MonthSectionNeo extends StatelessWidget {
  final String title;
  final List<VaccinationItem> items;
  final Map<String, VaccinationState> state;
  final DateTime? dob;
  final void Function(VaccinationItem item) onTapItem;

  const _MonthSectionNeo({
    required this.title,
    required this.items,
    required this.state,
    required this.dob,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: NeoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: t.titleMedium),
            const SizedBox(height: 10),
            for (final v in items) ...[
              VaccinationItemTile(
                item: v,
                state: state[v.id] ?? const VaccinationState(done: false),
                due: computeDueInfo(
                  item: v,
                  state: state[v.id] ?? const VaccinationState(done: false),
                  dob: dob,
                ),
                onTap: () => onTapItem(v),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}



class _EditResult {
  final bool done;
  final String? dateIso;
  final String? note;
  const _EditResult({required this.done, required this.dateIso, required this.note});
}

class _EditSheetNeo extends StatefulWidget {
  final VaccinationItem item;
  final VaccinationState initial;
  const _EditSheetNeo({required this.item, required this.initial});

  @override
  State<_EditSheetNeo> createState() => _EditSheetNeoState();
}

class _EditSheetNeoState extends State<_EditSheetNeo> {
  late bool done;
  String? dateIso;
  late TextEditingController noteCtrl;

  @override
  void initState() {
    super.initState();
    done = widget.initial.done;
    dateIso = widget.initial.dateIso;
    noteCtrl = TextEditingController(text: widget.initial.note ?? '');
  }

  @override
  void dispose() {
    noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final inset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: SafeArea(
        top: false,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface.o(0.92),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: cs.outlineVariant.o(0.35)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: cs.onSurface.o(0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Text(widget.item.title, style: t.titleMedium),
                      ),
                      Switch(value: done, onChanged: (v) => setState(() => done = v)),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.item.description,
                      style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _DateRowNeo(
                    dateIso: dateIso,
                    onPick: () async {
                      final now = DateTime.now();
                      final initial = _parseIso(dateIso) ?? now;
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(now.year + 1),
                      );
                      if (picked == null) return;
                      setState(() {
                        dateIso = _toIso(picked);
                        done = true;
                      });
                    },
                    onClear: () => setState(() => dateIso = null),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: noteCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: AppStrings.t(context, 'notes_optional'),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.o(0.6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          _EditResult(
                            done: done,
                            dateIso: dateIso,
                            note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(AppStrings.t(context, 'save')),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  DateTime? _parseIso(String? s) {
    if (s == null) return null;
    try {
      final p = s.split('-').map(int.parse).toList();
      return DateTime(p[0], p[1], p[2]);
    } catch (_) {
      return null;
    }
  }

  String _toIso(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }
}

class _DateRowNeo extends StatelessWidget {
  final String? dateIso;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _DateRowNeo({
    required this.dateIso,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.o(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.o(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.event_available_outlined, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              dateIso == null
                  ? AppStrings.t(context, 'pick_vaccination_date')
                  : AppStrings.t(
                      context,
                      'done_on_date',
                      vars: {'date': dateIso!},
                    ),
              style: t.titleSmall,
            ),
          ),
          if (dateIso != null)
            IconButton(
              onPressed: onClear,
              icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant),
              tooltip: AppStrings.t(context, 'clear'),
            ),
          TextButton(
            onPressed: onPick,
            child: Text(AppStrings.t(context, 'select')),
          ),
        ],
      ),
    );
  }
}
