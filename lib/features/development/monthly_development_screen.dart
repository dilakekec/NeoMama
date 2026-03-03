import 'package:flutter/material.dart';

import '../../data/monthly_development_data.dart';
import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class MonthlyDevelopmentScreen extends StatefulWidget {
  const MonthlyDevelopmentScreen({super.key});

  @override
  State<MonthlyDevelopmentScreen> createState() => _MonthlyDevelopmentScreenState();
}

class _MonthlyDevelopmentScreenState extends State<MonthlyDevelopmentScreen> {
  int _selectedMonth = 12;

  late final ScrollController _monthCtrl;

  @override
  void initState() {
    super.initState();
    _monthCtrl = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToSelected();
    });
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
    final data = monthlyDevelopmentDataFor(code);
    final dev = data[_selectedMonth];

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'development_title'), style: t.titleLarge),
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
                          color: cs.primary.o(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cs.primary.o(0.18)),
                        ),
                        child: Icon(Icons.auto_awesome, color: cs.primary),
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
                              AppStrings.t(context, 'development_select_month'),
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
                data: data,
                onChanged: (m) {
                  setState(() => _selectedMonth = m);
                  _jumpToSelected();
                },
              ),

              const SizedBox(height: 12),

              Expanded(
                child: dev == null
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: NeoCard(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🧸', style: TextStyle(fontSize: 44)),
                                const SizedBox(height: 10),
                                Text(
                                  AppStrings.t(context, 'development_empty_title'),
                                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  AppStrings.t(context, 'development_empty_sub'),
                                  style: t.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: _DevelopmentDetailCard(dev: dev),
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
  final Map<int, MonthlyDevelopment> data;
  final ValueChanged<int> onChanged;

  const _MonthSelector({
    required this.controller,
    required this.selectedMonth,
    required this.data,
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
          final hasData = data.containsKey(index);

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

class _DevelopmentDetailCard extends StatelessWidget {
  final MonthlyDevelopment dev;

  const _DevelopmentDetailCard({required this.dev});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dev.title,
          style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),

        _Section(
          title: AppStrings.t(context, 'development_section_physical'),
          text: dev.physical,
          icon: Icons.child_care,
        ),
        _Section(
          title: AppStrings.t(context, 'development_section_sleep'),
          text: dev.sleep,
          icon: Icons.nightlight_round,
        ),
        _Section(
          title: AppStrings.t(context, 'development_section_feeding'),
          text: dev.feeding,
          icon: Icons.restaurant,
        ),
        _Section(
          title: AppStrings.t(context, 'development_section_note'),
          text: dev.note,
          icon: Icons.info_outline,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String text;
  final IconData icon;

  const _Section({
    required this.title,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: NeoCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.primary.o(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.primary.o(0.18)),
              ),
              child: Icon(icon, color: cs.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(text, style: t.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
