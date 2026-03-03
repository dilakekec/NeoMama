import 'package:flutter/material.dart';

import 'package:neomama/core/config/route_names.dart';
import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';
import 'package:neomama/models/baby_profile.dart';

class MenuScreen extends StatelessWidget {
  final BabyProfile baby;

  const MenuScreen({super.key, required this.baby});

  void _open(BuildContext context, String route) {
    Navigator.pushNamed(context, route, arguments: baby);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'nav_tools'), style: t.titleLarge),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          children: [
            _SectionTitle(AppStrings.t(context, 'menu_content')),
            _MenuItem(
              icon: Icons.library_music_outlined,
              accent: const Color(0xFF9CB7FF),
              title: AppStrings.t(context, 'menu_music'),
              subtitle: AppStrings.t(context, 'menu_music_sub'),
              onTap: () => _open(context, RouteNames.music),
            ),
            _MenuItem(
              icon: Icons.article_outlined,
              accent: const Color(0xFFF3B6A3),
              title: AppStrings.t(context, 'menu_articles'),
              subtitle: AppStrings.t(context, 'menu_articles_sub'),
              onTap: () => _open(context, RouteNames.articles),
            ),
            _MenuItem(
              icon: Icons.offline_pin_outlined,
              accent: const Color(0xFF8FBFF6),
              title: AppStrings.t(context, 'menu_offline'),
              subtitle: AppStrings.t(context, 'menu_offline_sub'),
              onTap: () => _open(context, RouteNames.offlineLibrary),
            ),

            const SizedBox(height: 12),
            _SectionTitle(AppStrings.t(context, 'menu_baby_care')),
            _MenuItem(
              icon: Icons.vaccines_outlined,
              accent: const Color(0xFF7CCFAE),
              title: AppStrings.t(context, 'menu_vaccinations'),
              subtitle: AppStrings.t(context, 'menu_vaccinations_sub'),
              onTap: () => _open(context, RouteNames.vaccinations),
            ),
            _MenuItem(
              icon: Icons.child_friendly_outlined,
              accent: const Color(0xFFC9D1D9),
              title: AppStrings.t(context, 'menu_teething'),
              subtitle: AppStrings.t(context, 'menu_teething_sub'),
              onTap: () => _open(context, RouteNames.teething),
            ),
            _MenuItem(
              icon: Icons.monitor_weight_outlined,
              accent: const Color(0xFF95D0FF),
              title: AppStrings.t(context, 'menu_growth'),
              subtitle: AppStrings.t(context, 'menu_growth_sub'),
              onTap: () => _open(context, RouteNames.growth),
            ),
            _MenuItem(
              icon: Icons.restaurant_outlined,
              accent: const Color(0xFFF0D3A8),
              title: AppStrings.t(context, 'menu_feeding'),
              subtitle: AppStrings.t(context, 'menu_feeding_sub'),
              onTap: () => _open(context, RouteNames.feeding),
            ),
            _MenuItem(
              icon: Icons.bedtime_outlined,
              accent: const Color(0xFF8FAEFF),
              title: AppStrings.t(context, 'menu_sleep'),
              subtitle: AppStrings.t(context, 'menu_sleep_sub'),
              onTap: () => _open(context, RouteNames.sleep),
            ),
            _MenuItem(
              icon: Icons.toys_outlined,
              accent: const Color(0xFFECCB9B),
              title: AppStrings.t(context, 'menu_play'),
              subtitle: AppStrings.t(context, 'menu_play_sub'),
              onTap: () => _open(context, RouteNames.monthlyPlay),
            ),
            _MenuItem(
              icon: Icons.timeline_outlined,
              accent: const Color(0xFF7CCFAE),
              title: AppStrings.t(context, 'menu_development'),
              subtitle: AppStrings.t(context, 'menu_development_sub'),
              onTap: () => _open(context, RouteNames.monthlyDevelopment),
            ),

            const SizedBox(height: 12),
            _SectionTitle(AppStrings.t(context, 'menu_profile')),
            _MenuItem(
              icon: Icons.account_circle_outlined,
              accent: cs.primary,
              title: AppStrings.t(context, 'menu_baby_profile'),
              subtitle: AppStrings.t(context, 'menu_baby_profile_sub'),
              onTap: () => _open(context, RouteNames.babyProfile),
            ),
            _MenuItem(
              icon: Icons.list_alt_outlined,
              accent: cs.secondary,
              title: AppStrings.t(context, 'menu_baby_list'),
              subtitle: AppStrings.t(context, 'menu_baby_list_sub'),
              onTap: () => _open(context, RouteNames.babyList),
            ),

            const SizedBox(height: 12),
            _SectionTitle(AppStrings.t(context, 'menu_app')),
            _MenuItem(
              icon: Icons.settings_outlined,
              accent: const Color(0xFFB8C1D9),
              title: AppStrings.t(context, 'menu_settings'),
              subtitle: AppStrings.t(context, 'menu_settings_sub'),
              onTap: () => _open(context, RouteNames.settings),
            ),
          ],
        ),
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
