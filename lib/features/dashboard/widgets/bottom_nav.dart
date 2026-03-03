import "package:flutter/material.dart";
import 'package:neomama/l10n/app_strings.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: AppStrings.t(context, 'nav_home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.menu_book),
          label: AppStrings.t(context, 'nav_library'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: AppStrings.t(context, 'nav_settings'),
        ),
      ],
    );
  }
}
