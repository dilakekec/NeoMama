import 'package:flutter/material.dart';
import 'models/vaccination_models.dart';
import 'utils/vaccinations_due.dart';
import 'package:neomama/core/theme/app_colors.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class VaccinationItemTile extends StatelessWidget {
  final VaccinationItem item;
  final VaccinationState state;
  final DueInfo due;
  final VoidCallback onTap;

  const VaccinationItemTile({
    super.key,
    required this.item,
    required this.state,
    required this.due,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final done = state.done;

    
    final accent = done
        ? AppColors.secondary
        : _statusColor(due.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.o(0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.o(0.18)),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: Colors.black.o(0.06),
            ),
          ],
        ),
        child: Row(
          children: [
            
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.o(done ? 0.95 : 0.12),
                border: Border.all(color: accent.o(0.35)),
              ),
              child: Icon(
                done ? Icons.check_rounded : Icons.vaccines_outlined,
                color: done ? Colors.white : accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      _DueChip(due: due),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: Color(0xFF3E3D52),
                      height: 1.2,
                      fontSize: 12.5,
                    ),
                  ),

                  if (state.dateIso != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${AppStrings.t(context, 'logged')}: ${state.dateIso}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6D6C83),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.black.o(0.25),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(DueStatus s) {
    switch (s) {
      case DueStatus.overdue:
        return const Color(0xFFE53935);
      case DueStatus.upcoming:
        return const Color(0xFFFF9800);
      case DueStatus.scheduled:
        return AppColors.primary;
      case DueStatus.done:
        return AppColors.secondary;
      case DueStatus.unknown:
        return const Color(0xFF6D6C83);
    }
  }
}

class _DueChip extends StatelessWidget {
  final DueInfo due;
  const _DueChip({required this.due});

  @override
  Widget build(BuildContext context) {
    final bg = _bg(due.status);
    final fg = _fg(due.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.o(0.25)),
      ),
      child: Text(
        _shortLabel(context, due),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          color: fg,
          height: 1.0,
        ),
      ),
    );
  }

  String _shortLabel(BuildContext context, DueInfo d) {
    switch (d.status) {
      case DueStatus.done:
        return AppStrings.t(context, 'done');
      case DueStatus.overdue:
        return AppStrings.t(context, 'due_overdue');
      case DueStatus.upcoming:
        return AppStrings.t(context, 'due_soon');
      case DueStatus.scheduled:
        return AppStrings.t(context, 'planned');
      case DueStatus.unknown:
        return '—';
    }
  }

  Color _fg(DueStatus s) {
    switch (s) {
      case DueStatus.overdue:
        return const Color(0xFFE53935);
      case DueStatus.upcoming:
        return const Color(0xFFFF9800);
      case DueStatus.scheduled:
        return AppColors.primary;
      case DueStatus.done:
        return AppColors.secondary;
      case DueStatus.unknown:
        return const Color(0xFF6D6C83);
    }
  }

  Color _bg(DueStatus s) => _fg(s).o(0.12);
}
