import 'package:flutter/material.dart';
import 'package:neomama/models/baby_profile.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/core/theme/app_colors.dart';
import 'package:neomama/l10n/app_strings.dart';

class SideMenuSheet extends StatelessWidget {
  final BabyProfile? baby;
  final void Function(String routeName) onSelect;

  const SideMenuSheet({
    super.key,
    this.baby,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final height = media.size.height * 0.82;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            offset: const Offset(0, -8),
            color: Colors.black.o(0.08),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            const _Handle(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Icon(Icons.child_care, size: 20, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      baby?.name ?? AppStrings.t(context, 'nav_baby'),
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                children: [
                  _SectionTitle(AppStrings.t(context, 'menu_core')),
                  _MenuItem(
                    icon: Icons.home_outlined,
                    accent: AppColors.primary,
                    title: AppStrings.t(context, 'menu_home'),
                    subtitle: AppStrings.t(context, 'menu_home_sub'),
                    onTap: () => onSelect('/dashboard'),
                  ),
                  _MenuItem(
                    icon: Icons.smart_toy_outlined,
                    accent: AppColors.secondary,
                    title: AppStrings.t(context, 'menu_ai'),
                    subtitle: AppStrings.t(context, 'menu_ai_sub'),
                    onTap: () => onSelect('/ai-support'),
                  ),
                  _MenuItem(
                    icon: Icons.forum_outlined,
                    accent: AppColors.mint,
                    title: AppStrings.t(context, 'menu_forum'),
                    subtitle: AppStrings.t(context, 'menu_forum_sub'),
                    onTap: () => onSelect('/forum'),
                  ),

                  const SizedBox(height: 12),
                  _SectionTitle(AppStrings.t(context, 'menu_content')),
                  _MenuItem(
                    icon: Icons.library_music_outlined,
                    accent: const Color(0xFF9CB7FF),
                    title: AppStrings.t(context, 'menu_music'),
                    subtitle: AppStrings.t(context, 'menu_music_sub'),
                    onTap: () => onSelect('/music'),
                  ),
                  _MenuItem(
                    icon: Icons.article_outlined,
                    accent: AppColors.warm,
                    title: AppStrings.t(context, 'menu_articles'),
                    subtitle: AppStrings.t(context, 'menu_articles_sub'),
                    onTap: () => onSelect('/articles'),
                  ),
                  _MenuItem(
                    icon: Icons.offline_pin_outlined,
                    accent: const Color(0xFF8FBFF6),
                    title: AppStrings.t(context, 'menu_offline'),
                    subtitle: AppStrings.t(context, 'menu_offline_sub'),
                    onTap: () => onSelect('/offline-library'),
                  ),

                  const SizedBox(height: 12),
                  _SectionTitle(AppStrings.t(context, 'menu_baby_care')),
                  _MenuItem(
                    icon: Icons.vaccines_outlined,
                    accent: const Color(0xFF7CCFAE),
                    title: AppStrings.t(context, 'menu_vaccinations'),
                    subtitle: AppStrings.t(context, 'menu_vaccinations_sub'),
                    onTap: () => onSelect('/vaccinations'),
                  ),
                  _MenuItem(
                    icon: Icons.child_friendly_outlined,
                    accent: const Color(0xFFC9D1D9),
                    title: AppStrings.t(context, 'menu_teething'),
                    subtitle: AppStrings.t(context, 'menu_teething_sub'),
                    onTap: () => onSelect('/teething'),
                  ),
                  _MenuItem(
                    icon: Icons.monitor_weight_outlined,
                    accent: const Color(0xFF95D0FF),
                    title: AppStrings.t(context, 'menu_growth'),
                    subtitle: AppStrings.t(context, 'menu_growth_sub'),
                    onTap: () => onSelect('/growth'),
                  ),
                  _MenuItem(
                    icon: Icons.restaurant_outlined,
                    accent: const Color(0xFFF0D3A8),
                    title: AppStrings.t(context, 'menu_feeding'),
                    subtitle: AppStrings.t(context, 'menu_feeding_sub'),
                    onTap: () => onSelect('/feeding'),
                  ),
                  _MenuItem(
                    icon: Icons.bedtime_outlined,
                    accent: const Color(0xFF8FAEFF),
                    title: AppStrings.t(context, 'menu_sleep'),
                    subtitle: AppStrings.t(context, 'menu_sleep_sub'),
                    onTap: () => onSelect('/sleep-schedule'),
                  ),
                  _MenuItem(
                    icon: Icons.toys_outlined,
                    accent: const Color(0xFFECCB9B),
                    title: AppStrings.t(context, 'menu_play'),
                    subtitle: AppStrings.t(context, 'menu_play_sub'),
                    onTap: () => onSelect('/play-ideas'),
                  ),
                  _MenuItem(
                    icon: Icons.timeline_outlined,
                    accent: AppColors.mint,
                    title: AppStrings.t(context, 'menu_development'),
                    subtitle: AppStrings.t(context, 'menu_development_sub'),
                    onTap: () => onSelect('/development'),
                  ),

                  const SizedBox(height: 12),
                  _SectionTitle(AppStrings.t(context, 'menu_profile')),
                  _MenuItem(
                    icon: Icons.account_circle_outlined,
                    accent: AppColors.primary,
                    title: AppStrings.t(context, 'menu_baby_profile'),
                    subtitle: AppStrings.t(context, 'menu_baby_profile_sub'),
                    onTap: () => onSelect('/baby-profile'),
                  ),
                  _MenuItem(
                    icon: Icons.list_alt_outlined,
                    accent: AppColors.secondary,
                    title: AppStrings.t(context, 'menu_baby_list'),
                    subtitle: AppStrings.t(context, 'menu_baby_list_sub'),
                    onTap: () => onSelect('/baby-list'),
                  ),

                  const SizedBox(height: 12),
                  _SectionTitle(AppStrings.t(context, 'menu_app')),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    accent: const Color(0xFFB8C1D9),
                    title: AppStrings.t(context, 'menu_settings'),
                    subtitle: AppStrings.t(context, 'menu_settings_sub'),
                    onTap: () => onSelect('/settings'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 5,
      decoration: BoxDecoration(
        color: cs.onSurface.o(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ).copyWith(color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      color: cs.surface.o(0.92),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.o(0.22),
                accent.o(0.38),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                offset: const Offset(0, 6),
                color: accent.o(0.25),
              ),
            ],
          ),
          child: Icon(icon, color: accent, size: 22),
        ),
        title: Text(
          title,
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          subtitle,
          style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
      ),
    );
  }
}
