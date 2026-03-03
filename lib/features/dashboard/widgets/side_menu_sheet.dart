import "package:flutter/material.dart";
import "package:neomama/l10n/app_strings.dart";

class SideMenuSheet extends StatelessWidget {
  const SideMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.t(context, 'menu'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(AppStrings.t(context, 'about')),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
