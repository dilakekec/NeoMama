import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/neomama_app.dart';
import 'package:neomama/core/config/route_names.dart';
import 'package:neomama/l10n/app_strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _didInit = false;
  bool authEnabled = true;
  bool isSignedIn = false;
  StreamSubscription<User?>? _authSub;

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void initState() {
    super.initState();
    isSignedIn = FirebaseAuth.instance.currentUser != null;
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return;
      setState(() => isSignedIn = user != null);
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _confirmAction({
    required String title,
    required String body,
    required String okLabel,
    required Future<void> Function() onOk,
  }) async {
    final t = Theme.of(context).textTheme;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: t.titleLarge),
        content: Text(body, style: t.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.t(context, 'cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(okLabel),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await onOk();
  }

  Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final title = AppStrings.t(context, 'delete_account');
    final body = AppStrings.t(context, 'delete_account_confirm_body');
    final okLabel = AppStrings.t(context, 'delete_account');
    final success = AppStrings.t(context, 'delete_account_done');
    final reauth = AppStrings.t(context, 'delete_account_reauth');
    final failed = AppStrings.t(context, 'delete_failed');

    await _confirmAction(
      title: title,
      body: body,
      okLabel: okLabel,
      onOk: () async {
        try {
          await user.delete();
          await FirebaseAuth.instance.signOut();
          try {
            await GoogleSignIn().signOut();
          } catch (_) {}
          await _clearLocalData();
          if (!mounted) return;
          _toast(success);
        } on FirebaseAuthException catch (e) {
          if (!mounted) return;
          if (e.code == 'requires-recent-login') {
            _toast(reauth);
          } else {
            _toast(failed);
          }
        } catch (_) {
          if (!mounted) return;
          _toast(failed);
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;
    final app = NeoMamaApp.maybeOf(context);
    final mode = app?.themeMode ?? ThemeMode.light;
    _darkMode = mode == ThemeMode.dark;
  }

  Locale _currentLocale() {
    final app = NeoMamaApp.maybeOf(context);
    return app?.locale ?? Localizations.localeOf(context);
  }

  String _localeLabel(Locale locale) {
    switch (locale.languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
      default:
        return 'English';
    }
  }

  void _openLanguageSheet() {
    final app = NeoMamaApp.maybeOf(context);
    if (app == null) return;
    final current = _currentLocale();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final t = Theme.of(context).textTheme;
        final cs = Theme.of(context).colorScheme;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: NeoCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.t(context, 'select_language'), style: t.titleMedium),
                  const SizedBox(height: 10),
                  _LangTile(
                    label: 'English',
                    selected: current.languageCode == 'en',
                    onTap: () {
                      app.setLocale(const Locale('en'));
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  _LangTile(
                    label: 'Türkçe',
                    selected: current.languageCode == 'tr',
                    onTap: () {
                      app.setLocale(const Locale('tr'));
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.t(context, 'change_anytime'),
                    style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final locale = _currentLocale();

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.t(context, 'settings'), style: t.titleLarge),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(AppStrings.t(context, 'preferences'), style: t.titleMedium),
            const SizedBox(height: 12),

            NeoCard(
              child: Column(
                children: [
                  _SettingRow(
                    icon: Icons.language,
                    title: AppStrings.t(context, 'language'),
                    subtitle:
                        '${AppStrings.t(context, 'language_sub')} • ${_localeLabel(locale)}',
                    onTap: _openLanguageSheet,
                  ),
                  _DividerLine(),
                  _SettingSwitchRow(
                    icon: Icons.dark_mode,
                    title: AppStrings.t(context, 'dark_mode'),
                    subtitle: AppStrings.t(context, 'theme_pref'),
                    value: _darkMode,
                    onChanged: (v) {
                      final app = NeoMamaApp.maybeOf(context);
                      app?.setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
                      setState(() => _darkMode = v);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Text(AppStrings.t(context, 'support'), style: t.titleMedium),
            const SizedBox(height: 12),

            NeoCard(
              child: Column(
                children: [
                  _SettingRow(
                    icon: Icons.privacy_tip_outlined,
                    title: AppStrings.t(context, 'privacy'),
                    subtitle: AppStrings.t(context, 'privacy_sub'),
                    onTap: () => Navigator.pushNamed(context, RouteNames.privacy),
                  ),
                  _DividerLine(),
                  _SettingRow(
                    icon: Icons.info_outline,
                    title: AppStrings.t(context, 'about'),
                    subtitle: AppStrings.t(context, 'about_sub'),
                    onTap: () => Navigator.pushNamed(context, RouteNames.about),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            if (authEnabled) ...[
              Text(AppStrings.t(context, 'account'), style: t.titleMedium),
              const SizedBox(height: 12),
              NeoCard(
                child: Column(
                  children: [
                    if (isSignedIn)
                      _SettingRow(
                        icon: Icons.logout,
                        iconColor: cs.error,
                        title: AppStrings.t(context, 'sign_out'),
                        subtitle: AppStrings.t(context, 'sign_out_sub'),
                          onTap: () async {
                          final signedOutMsg = AppStrings.t(context, 'signed_out');
                          await _confirmAction(
                            title: AppStrings.t(context, 'sign_out'),
                            body: AppStrings.t(context, 'sign_out_sub'),
                            okLabel: AppStrings.t(context, 'sign_out'),
                            onOk: () async {
                              await FirebaseAuth.instance.signOut();
                              try {
                                await GoogleSignIn().signOut();
                              } catch (_) {}
                              if (!mounted) return;
                              _toast(signedOutMsg);
                            },
                          );
                        },
                      )
                    else
                      _SettingRow(
                        icon: Icons.login,
                        title: AppStrings.t(context, 'sign_in'),
                        subtitle: AppStrings.t(context, 'sign_in_sub'),
                        onTap: () => Navigator.pushNamed(context, RouteNames.login),
                      ),
                    if (isSignedIn) ...[
                      _DividerLine(),
                      _SettingRow(
                        icon: Icons.delete_forever,
                        iconColor: cs.error,
                        title: AppStrings.t(context, 'delete_account'),
                        subtitle: AppStrings.t(context, 'delete_account_sub'),
                        onTap: _deleteAccount,
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 18),

            Center(
              child: Text(
                AppStrings.t(context, 'offline_friendly'),
                style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Divider(
        height: 1,
        thickness: 1,
        color: cs.outlineVariant.o(0.25),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? cs.primary.o(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? cs.primary.o(0.25) : cs.outlineVariant.o(0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: t.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: selected ? cs.primary : cs.onSurface,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, color: cs.primary, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: cs.primary.o(0.12),
                child: Icon(icon, color: iconColor ?? cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: t.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingSwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: cs.primary.o(0.12),
            child: Icon(icon, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleMedium),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
