import 'dart:ui';
import 'package:flutter/material.dart';

import '../vaccinations_service.dart';
import '../data/vaccinations_data.dart';
import '../models/vaccination_models.dart';
import 'package:neomama/core/theme/app_colors.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class VaccinationsCard extends StatefulWidget {
  final String babyKey; 
  final String? babyDobIso; 
  final VoidCallback onTap;

  const VaccinationsCard({
    super.key,
    required this.babyKey,
    required this.onTap,
    this.babyDobIso,
  });

  @override
  State<VaccinationsCard> createState() => _VaccinationsCardState();
}

class _VaccinationsCardState extends State<VaccinationsCard> {
  final _svc = VaccinationsService();

  Map<String, VaccinationState> _state = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant VaccinationsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.babyKey != widget.babyKey) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _svc.load(widget.babyKey);
    if (!mounted) return;
    setState(() {
      _state = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    final items = vaccinationsDataFor(code);
    final total = items.length;
    final done = _state.values.where((v) => v.done).length;
    final pct = total <= 0 ? 0.0 : (done / total).clamp(0.0, 1.0);

    final nextLine =
        _loading ? AppStrings.t(context, 'loading') : _nextDueLine(total: total, items: items);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.o(0.78),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _IconBox(pct: pct, loading: _loading),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.t(context, 'vaccinations'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: _loading ? null : pct,
                            minHeight: 9,
                            backgroundColor: Colors.black.o(0.06),
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              AppStrings.t(
                                context,
                                'vaccinations_completed',
                                vars: {'done': '$done', 'total': '$total'},
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6D6C83),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            if (!_loading)
                              IconButton(
                                onPressed: _load,
                                tooltip: AppStrings.t(context, 'refresh'),
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                  color: Color(0xFF6D6C83),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nextLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            color: Colors.black.o(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 26,
                    color: Color(0xFF6D6C83),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _nextDueLine({
    required int total,
    required List<VaccinationItem> items,
  }) {
    if (total == 0) return AppStrings.t(context, 'vaccinations_no_schedule');
    final doneCount = _state.values.where((v) => v.done).length;
    if (doneCount >= total) return AppStrings.t(context, 'vaccinations_all_logged');

    final sorted = [...items]..sort((a, b) {
        final am = _monthIndexFor(a);
        final bm = _monthIndexFor(b);
        final c = am.compareTo(bm);
        return c != 0 ? c : a.title.compareTo(b.title);
      });

    for (final item in sorted) {
      final st = _state[item.id] ?? const VaccinationState(done: false);
      if (st.done) continue;

      final due = _estimateDueDate(item);
      final label = _labelFor(item);

      if (due == null) {
        return AppStrings.t(
          context,
          'vaccinations_next',
          vars: {'title': item.title, 'label': label},
        );
      }
      return AppStrings.t(
        context,
        'vaccinations_next_date',
        vars: {'title': item.title, 'label': label, 'date': _fmtDate(due)},
      );
    }

    return AppStrings.t(context, 'vaccinations_next_none');
  }

  
  
  

  
  
  String _labelFor(VaccinationItem item) => item.monthLabel;

  
  
  int _monthIndexFor(VaccinationItem item) {
    
    final idMatch = RegExp(r'(\d{1,2})').firstMatch(item.id);
    if (idMatch != null) {
      final v = int.tryParse(idMatch.group(1)!);
      if (v != null) return v;
    }

    
    final titleMatch = RegExp(r'(\d{1,2})').firstMatch(item.title);
    if (titleMatch != null) {
      final v = int.tryParse(titleMatch.group(1)!);
      if (v != null) return v;
    }

    
    return 0;
  }

  DateTime? _estimateDueDate(VaccinationItem item) {
    final rawDob = widget.babyDobIso;
    if (rawDob == null || rawDob.trim().isEmpty) return null;

    final dob = DateTime.tryParse(rawDob.trim());
    if (dob == null) return null;

    final months = _monthIndexFor(item);
    if (months <= 0) return null;

    return _addMonths(dob, months);
  }

  DateTime _addMonths(DateTime d, int months) {
    final y = d.year + ((d.month - 1 + months) ~/ 12);
    final m = ((d.month - 1 + months) % 12) + 1;
    final lastDay = DateTime(y, m + 1, 0).day;
    final day = d.day > lastDay ? lastDay : d.day;
    return DateTime(y, m, day);
  }

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }
}

class _IconBox extends StatelessWidget {
  final double pct;
  final bool loading;
  const _IconBox({required this.pct, required this.loading});

  @override
  Widget build(BuildContext context) {
    final done = pct >= 1.0;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: loading
              ? const [Color(0xFF3E3D52), Color(0xFF6D6C83)]
              : done
                  ? const [AppColors.secondary, AppColors.primary]
                  : const [AppColors.primary, AppColors.secondary],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.o(0.12),
          ),
        ],
      ),
      child: Icon(
        loading
            ? Icons.hourglass_bottom_rounded
            : (done ? Icons.check_rounded : Icons.vaccines_outlined),
        color: Colors.white,
        size: 26,
      ),
    );
  }
}
