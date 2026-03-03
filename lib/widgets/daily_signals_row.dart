import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/daily_signals.dart';
import 'package:neomama/core/theme/app_colors.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class DailySignalsRow extends StatelessWidget {
  final DailySignals value;
  final ValueChanged<DailySignals> onChanged;

  const DailySignalsRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.o(0.74),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.o(0.35)),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 10),
                color: Colors.black.o(0.06),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.t(context, 'today_signals'),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2F2E3A),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Chip(
                    label: AppStrings.t(context, 'signal_sleep_restless'),
                    icon: Icons.nightlight_round,
                    on: value.sleepRestless,
                    onTap: () => onChanged(value.copyWith(
                      sleepRestless: !value.sleepRestless,
                    )),
                  ),
                  _Chip(
                    label: AppStrings.t(context, 'signal_feeding_hard'),
                    icon: Icons.restaurant,
                    on: value.feedingHard,
                    onTap: () => onChanged(value.copyWith(
                      feedingHard: !value.feedingHard,
                    )),
                  ),
                  _Chip(
                    label: AppStrings.t(context, 'signal_teething_symptoms'),
                    icon: Icons.emoji_emotions_outlined,
                    on: value.teethingSymptoms,
                    onTap: () => onChanged(value.copyWith(
                      teethingSymptoms: !value.teethingSymptoms,
                    )),
                  ),
                  _Chip(
                    label: AppStrings.t(context, 'signal_new_food'),
                    icon: Icons.restaurant_menu,
                    on: value.newFood,
                    onTap: () => onChanged(value.copyWith(
                      newFood: !value.newFood,
                    )),
                  ),
                  _Chip(
                    label: AppStrings.t(context, 'signal_skin_rash'),
                    icon: Icons.healing,
                    on: value.skinRash,
                    onTap: () => onChanged(value.copyWith(
                      skinRash: !value.skinRash,
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool on;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.icon,
    required this.on,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentOn = AppColors.primary;
    const accentOff = AppColors.inkMuted;

    final accent = on ? accentOn : accentOff;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: accent.o(on ? 0.14 : 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accent.o(0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: accent.o(0.95)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.6,
                fontWeight: FontWeight.w900,
                color: accent.o(0.95),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
