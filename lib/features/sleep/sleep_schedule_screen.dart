import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class SleepScheduleScreen extends StatefulWidget {
  const SleepScheduleScreen({super.key});

  @override
  State<SleepScheduleScreen> createState() => _SleepScheduleScreenState();
}

class _SleepScheduleScreenState extends State<SleepScheduleScreen> {
  static const _spKey = 'sleep_times_v1'; 
  final List<TimeOfDay> _times = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_spKey);

    final loaded = <TimeOfDay>[];
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final list = (jsonDecode(raw) as List).cast<String>();
        for (final s in list) {
          final t = _parseTime(s);
          if (t != null) loaded.add(t);
        }
      } catch (_) {
        
      }
    }

    loaded.sort(_compareTime);

    if (!mounted) return;
    setState(() {
      _times
        ..clear()
        ..addAll(loaded);
      _loading = false;
    });
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    final list = _times.map(_timeToString).toList();
    await sp.setString(_spKey, jsonEncode(list));
  }

  int _compareTime(TimeOfDay a, TimeOfDay b) {
    final am = a.hour * 60 + a.minute;
    final bm = b.hour * 60 + b.minute;
    return am.compareTo(bm);
  }

  String _timeToString(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  TimeOfDay? _parseTime(String s) {
    final parts = s.trim().split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;

    
    final exists = _times.any((x) => x.hour == picked.hour && x.minute == picked.minute);
    if (exists) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.t(context, 'sleep_time_exists')),
        ),
      );
      return;
    }

    setState(() {
      _times.add(picked);
      _times.sort(_compareTime);
    });
    await _save();
  }

  Future<void> _removeAt(int index) async {
    setState(() => _times.removeAt(index));
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'sleep_schedule'), style: t.titleLarge),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            NeoCard(
              child: Row(
                children: [
                  Icon(Icons.bedtime_outlined, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.t(context, 'sleep_planned'), style: t.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.t(context, 'sleep_desc'),
                          style: t.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            if (_loading)
              const Center(child: Padding(
                padding: EdgeInsets.only(top: 24),
                child: CircularProgressIndicator(),
              ))
            else if (_times.isEmpty)
              NeoCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Text(
                      AppStrings.t(context, 'sleep_empty'),
                      style: t.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              ...List.generate(_times.length, (i) {
                final time = _times[i];
                final label = _timeToString(time);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: ValueKey('sleep_$label'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: cs.error.o(0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: cs.error.o(0.25)),
                      ),
                      child: Icon(Icons.delete_outline, color: cs.error),
                    ),
                    onDismissed: (_) => _removeAt(i),
                    child: NeoCard(
                      child: Row(
                        children: [
                          Icon(Icons.nightlight_round, color: cs.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(label, style: t.titleMedium),
                          ),
                          IconButton(
                            tooltip: AppStrings.t(context, 'remove'),
                            icon: Icon(Icons.delete_outline, color: cs.error),
                            onPressed: () => _removeAt(i),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

            _AddTimeCard(onTap: _addTime),

            const SizedBox(height: 10),

            Center(
              child: Text(
                AppStrings.t(context, 'sleep_tip'),
                style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTimeCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddTimeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: NeoCard(
          child: Row(
            children: [
              Icon(Icons.add_circle_outline, color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(AppStrings.t(context, 'sleep_add_time'), style: t.titleMedium),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
