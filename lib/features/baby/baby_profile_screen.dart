import 'package:flutter/material.dart';
import '../../models/baby_profile.dart' as m;

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/config/route_names.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class BabyProfileScreen extends StatelessWidget {
  final m.BabyProfile baby;

  const BabyProfileScreen({
    super.key,
    required this.baby,
  });

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  String _ageValue(int? months) {
    if (months == null) return '-';
    if (months >= 12) return '${months ~/ 12}';
    return '$months';
  }

  String _ageUnit(BuildContext context, int? months) {
    if (months == null) return '';
    if (months >= 12) return AppStrings.t(context, 'year_abbr');
    return AppStrings.t(context, 'month_abbr');
  }

  List<String> _splitAllergies(String raw) {
    return raw
        .split(RegExp(r'[\,\n;•]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final months = baby.ageInMonths;
    final hasAllergy = baby.allergies != null && baby.allergies!.trim().isNotEmpty;
    final allergyItems = hasAllergy ? _splitAllergies(baby.allergies!.trim()) : const <String>[];

    return NeoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'baby_profile'), style: t.titleLarge),
          actions: [
            IconButton(
              tooltip: AppStrings.t(context, 'open_dashboard'),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  RouteNames.dashboard,
                  arguments: baby,
                );
              },
              icon: const Icon(Icons.open_in_new),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            NeoCard(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          cs.primary.o(0.28),
                          cs.secondary.o(0.35),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                          color: Colors.black.o(0.08),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _initials(baby.name),
                        style: t.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    baby.name,
                    style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${AppStrings.t(context, 'dob')} • ${baby.formattedDob}',
                    style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: AppStrings.t(context, 'age'),
                          value: _ageValue(months),
                          unit: _ageUnit(context, months),
                          tint: cs.primary.o(0.12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricCard(
                          title: AppStrings.t(context, 'weight'),
                          value: '-',
                          unit: 'kg',
                          tint: cs.secondary.o(0.12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricCard(
                          title: AppStrings.t(context, 'height'),
                          value: '-',
                          unit: 'cm',
                          tint: cs.tertiary.o(0.12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _PrimaryButton(
                    label: AppStrings.t(context, 'edit_profile'),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteNames.babyForm,
                        arguments: baby,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            NeoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.health_and_safety_outlined, color: cs.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.t(context, 'allergies'),
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (hasAllergy)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allergyItems.isEmpty
                          ? [
                              Text(
                                baby.allergies!,
                                style: t.bodyMedium,
                              ),
                            ]
                          : allergyItems.map((a) => _Chip(text: a)).toList(),
                    )
                  else
                    Text(
                      AppStrings.t(context, 'no_allergy'),
                      style: t.bodyMedium,
                    ),
                  if (!hasAllergy) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              RouteNames.babyForm,
                              arguments: baby,
                            );
                          },
                          child: Text(AppStrings.t(context, 'add')),
                        ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color tint;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final showUnit = value != '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.o(0.06)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: t.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface.o(0.65),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            showUnit ? '$value $unit' : value,
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.primary.o(0.35),
                cs.secondary.o(0.45),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: Text(
              label,
              style: t.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;

  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.errorContainer.o(0.6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.error.o(0.35)),
      ),
      child: Text(
        text,
        style: t.bodySmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: cs.onSurface,
        ),
      ),
    );
  }
}
