import 'package:flutter/material.dart';

import '../../data/monthly_play_ideas.dart';
import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class MonthlyPlayIdeasScreen extends StatefulWidget {
  const MonthlyPlayIdeasScreen({super.key});

  @override
  State<MonthlyPlayIdeasScreen> createState() => _MonthlyPlayIdeasScreenState();
}

class _MonthlyPlayIdeasScreenState extends State<MonthlyPlayIdeasScreen> {
  int _selectedMonth = 12;

  late final ScrollController _monthCtrl;

  @override
  void initState() {
    super.initState();
    _monthCtrl = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToSelected());
  }

  @override
  void dispose() {
    _monthCtrl.dispose();
    super.dispose();
  }

  void _jumpToSelected() {
    final offset = (_selectedMonth * 72.0) - 120;
    if (!_monthCtrl.hasClients) return;
    _monthCtrl.animateTo(
      offset.clamp(0, _monthCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final code = Localizations.localeOf(context).languageCode;
    final ideasForMonth =
        monthlyPlayIdeasFor(code).where((x) => x.month == _selectedMonth).toList();

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'play_ideas'), style: t.titleLarge),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: NeoCard(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cs.secondary.o(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cs.secondary.o(0.18)),
                        ),
                        child: Icon(Icons.toys_outlined, color: cs.secondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.t(
                                context,
                                'month_label',
                                vars: {'month': '$_selectedMonth'},
                              ),
                              style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.t(context, 'play_ideas_subtitle'),
                              style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _MonthSelector(
                controller: _monthCtrl,
                selectedMonth: _selectedMonth,
                allIdeas: monthlyPlayIdeasFor(code),
                onChanged: (m) {
                  setState(() => _selectedMonth = m);
                  _jumpToSelected();
                },
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ideasForMonth.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: NeoCard(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🎈', style: TextStyle(fontSize: 44)),
                                const SizedBox(height: 10),
                                Text(
                                  AppStrings.t(context, 'play_ideas_empty_title'),
                                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  AppStrings.t(context, 'play_ideas_empty_sub'),
                                  style: t.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: ideasForMonth.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final idea = ideasForMonth[i];

                          return NeoCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: cs.secondary.o(0.12),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: cs.secondary.o(0.18)),
                                      ),
                                      child: Icon(Icons.lightbulb_outline, color: cs.secondary, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            idea.title,
                                            style: t.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: cs.primary.o(0.10),
                                              borderRadius: BorderRadius.circular(999),
                                              border: Border.all(color: cs.primary.o(0.16)),
                                            ),
                                            child: Text(
                                              idea.category,
                                              style: t.labelLarge?.copyWith(
                                                color: cs.primary,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  idea.description,
                                  style: t.bodyMedium,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final ScrollController controller;
  final int selectedMonth;
  final List<PlayIdea> allIdeas;
  final ValueChanged<int> onChanged;

  const _MonthSelector({
    required this.controller,
    required this.selectedMonth,
    required this.allIdeas,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 54,
      child: ListView.separated(
        controller: controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 25,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selectedMonth;
          final hasData = allIdeas.any((x) => x.month == index);

          final bg = isSelected ? cs.primary.o(0.92) : Colors.transparent;
          final fg = isSelected ? cs.onPrimary : cs.onSurface;
          final borderColor = hasData
              ? (isSelected ? Colors.transparent : cs.primary.o(0.18))
              : cs.outlineVariant.o(0.45);

          return SizedBox(
            width: 64,
            child: NeoCard(
              padding: EdgeInsets.zero,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onChanged(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$index',
                          style: t.labelLarge?.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          AppStrings.t(context, 'month_abbr'),
                          style: t.labelSmall?.copyWith(
                            color: fg.o(0.85),
                            fontWeight: hasData ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
