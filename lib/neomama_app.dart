import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'core/config/route_names.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/auth_gate.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

import 'features/growth/growth_screen.dart';
import 'features/teething/teething_screen.dart';
import 'features/vaccinations/vaccinations_screen.dart';

import 'models/baby_profile.dart';

import 'features/articles/articles_screen.dart';
import 'features/baby/baby_form.dart';
import 'features/baby/baby_list_screen.dart';
import 'features/baby/baby_profile_screen.dart';
import 'features/blog/blog_feed_screen.dart';
import 'features/contacts/contacts_screen.dart';
import 'features/development/monthly_development_screen.dart';
import 'features/development/monthly_play_ideas_screen.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/feeding/feeding_screen.dart';
import 'features/music/music_screen.dart';
import 'features/music/offline_library_screen.dart';
import 'features/settings/privacy_screen.dart';
import 'features/settings/about_screen.dart';
import 'features/sleep/sleep_schedule_screen.dart';
import 'features/shell/main_shell.dart';
import 'l10n/app_strings.dart';

class NeoMamaApp extends StatefulWidget {
  const NeoMamaApp({super.key});

  static NeoMamaAppState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<NeoMamaAppState>();
  }

  static NeoMamaAppState of(BuildContext context) {
    final state = maybeOf(context);
    assert(state != null, 'NeoMamaApp.of() called with no NeoMamaApp in context.');
    return state!;
  }

  @override
  State<NeoMamaApp> createState() => NeoMamaAppState();
}

class NeoMamaAppState extends State<NeoMamaApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Locale? _locale;

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;

  static const _themeKey = 'neomama_theme_mode';
  static const _localeKey = 'neomama_locale';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(_themeKey);
    final locale = prefs.getString(_localeKey);
    if (!mounted) return;
    setState(() {
      _themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      _locale = locale == null || locale.isEmpty ? _locale : Locale(locale);
    });
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    setState(() => _themeMode = mode);
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString(_themeKey, mode == ThemeMode.dark ? 'dark' : 'light'));
  }

  void setLocale(Locale? locale) {
    if (_locale == locale) return;
    setState(() => _locale = locale);
    SharedPreferences.getInstance().then((prefs) {
      if (locale == null) {
        prefs.remove(_localeKey);
      } else {
        prefs.setString(_localeKey, locale.languageCode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppStrings.t(context, 'app_name'),
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,

      
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supported) {
        if (locale == null) return const Locale('en');
        for (final s in supported) {
          if (s.languageCode == locale.languageCode) return s;
        }
        return const Locale('en');
      },

      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: _locale,

      
      home: const _RootGate(),

      
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    BabyProfile? babyArg() =>
        settings.arguments is BabyProfile ? settings.arguments as BabyProfile : null;

    MaterialPageRoute page(Widget child) => MaterialPageRoute(builder: (_) => child);

    
    
    MaterialPageRoute babyOrRedirect(Widget Function(BabyProfile baby) builder) {
      final baby = babyArg();
      if (baby == null) return page(const BabyListScreen());
      return page(builder(baby));
    }

    switch (settings.name) {
      
      case RouteNames.login:
      case RouteNames.auth:
        final provider = settings.arguments is String ? settings.arguments as String : null;
        return page(AuthGate(initialProvider: provider));

      case RouteNames.onboarding:
        return page(OnboardingScreen());

      
      case RouteNames.babyList:
        return page(const BabyListScreen());

      case RouteNames.babyForm:
        return page(BabyFormScreen(baby: babyArg()));

      case RouteNames.babyProfile:
        return babyOrRedirect((b) => BabyProfileScreen(baby: b));

      case RouteNames.dashboard:
        return babyOrRedirect((b) => MainShell(baby: b, initialIndex: 1));

      
      case RouteNames.ai:
        return babyOrRedirect((b) => MainShell(baby: b, initialIndex: 0));

      case RouteNames.feeding:
        return babyOrRedirect((b) => FeedingScreen(baby: b));

      case RouteNames.vaccinations:
        return babyOrRedirect((b) => VaccinationsScreen(baby: b));

      case RouteNames.teething:
        return babyOrRedirect((b) => TeethingScreen(baby: b));

      case RouteNames.growth:
        return babyOrRedirect((b) => GrowthScreen(baby: b));

      
      case RouteNames.favorites:
        return page(const FavoritesScreen());

      case RouteNames.blog:
        return page(const BlogFeedScreen());

      case RouteNames.forum:
        return babyOrRedirect((b) => MainShell(baby: b, initialIndex: 3));

      case RouteNames.music:
        return page(const MusicScreen());

      case RouteNames.offlineLibrary:
        return page(const OfflineLibraryScreen());

      case RouteNames.articles:
        return page(const ArticlesScreen());

      case RouteNames.sleep:
        return page(const SleepScheduleScreen());

      case RouteNames.settings:
        return babyOrRedirect((b) => MainShell(baby: b, initialIndex: 4));
      case RouteNames.privacy:
        return page(const PrivacyScreen());
      case RouteNames.about:
        return page(const AboutScreen());

      case RouteNames.monthlyPlay:
        return page(const MonthlyPlayIdeasScreen());

      case RouteNames.monthlyDevelopment:
        return page(const MonthlyDevelopmentScreen());

      case RouteNames.contacts:
        return page(const ContactsScreen());

      default:
        
        return page(const _RootGate());
    }
  }
}




class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
