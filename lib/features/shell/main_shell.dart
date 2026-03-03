import 'package:flutter/material.dart';

import 'package:neomama/models/baby_profile.dart';

import 'package:neomama/features/dashboard/dashboard_screen.dart';
import 'package:neomama/features/forum/mama_forum_screen.dart';
import 'package:neomama/features/ai/ai_support_screen.dart';
import 'package:neomama/features/shell/menu_screen.dart';
import 'package:neomama/features/settings/settings_screen.dart';

import 'package:neomama/widgets/bottom_nav.dart';
import 'package:neomama/l10n/app_strings.dart';
import 'package:neomama/core/config/shell_routes.dart';

class MainShell extends StatefulWidget {
  final BabyProfile baby;
  final int initialIndex;

  const MainShell({
    super.key,
    required this.baby,
    this.initialIndex = 1,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;
  final _keys = List.generate(5, (_) => GlobalKey<NavigatorState>());

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 4);
  }

  void _go(int i) {
    if (i == _index) {
      _keys[i].currentState?.popUntil((r) => r.isFirst);
      return;
    }
    setState(() => _index = i);
  }

  Widget _tabNavigator({
    required int index,
    required Widget root,
  }) {
    return Offstage(
      offstage: _index != index,
      child: TickerMode(
        enabled: _index == index,
        child: Navigator(
          key: _keys[index],
          onGenerateRoute: (settings) {
            if (settings.name == Navigator.defaultRouteName) {
              return MaterialPageRoute(builder: (_) => root);
            }
            return ShellRoutes.onGenerateRoute(settings);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _tabNavigator(
            index: 0,
            root: AiSupportScreen(baby: widget.baby),
          ),
          _tabNavigator(
            index: 1,
            root: DashboardScreen(baby: widget.baby),
          ),
          _tabNavigator(
            index: 2,
            root: MenuScreen(baby: widget.baby),
          ),
          _tabNavigator(
            index: 3,
            root: const MamaForumScreen(),
          ),
          _tabNavigator(
            index: 4,
            root: const SettingsScreen(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _index,
        onTap: _go,
        items: [
          BottomNavItem(
            icon: Icons.smart_toy_outlined,
            label: AppStrings.t(context, 'nav_ai'),
          ),
          BottomNavItem(
            icon: Icons.home_rounded,
            label: AppStrings.t(context, 'nav_home'),
          ),
          BottomNavItem(
            icon: Icons.menu_rounded,
            label: AppStrings.t(context, 'nav_tools'),
          ),
          BottomNavItem(
            icon: Icons.forum_outlined,
            label: AppStrings.t(context, 'nav_forum'),
          ),
          BottomNavItem(
            icon: Icons.person_outline,
            label: AppStrings.t(context, 'nav_profile'),
          ),
        ],
        showLabels: true,
      ),
    );
  }
}
