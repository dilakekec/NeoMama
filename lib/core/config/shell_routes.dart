import 'package:flutter/material.dart';

import 'route_names.dart';
import 'package:neomama/models/baby_profile.dart';

import 'package:neomama/features/ai/ai_support_screen.dart';
import 'package:neomama/features/articles/articles_screen.dart';
import 'package:neomama/features/baby/baby_form.dart';
import 'package:neomama/features/baby/baby_list_screen.dart';
import 'package:neomama/features/baby/baby_profile_screen.dart';
import 'package:neomama/features/blog/blog_feed_screen.dart';
import 'package:neomama/features/contacts/contacts_screen.dart';
import 'package:neomama/features/dashboard/dashboard_screen.dart';
import 'package:neomama/features/development/monthly_development_screen.dart';
import 'package:neomama/features/development/monthly_play_ideas_screen.dart';
import 'package:neomama/features/favorites/favorites_screen.dart';
import 'package:neomama/features/feeding/feeding_screen.dart';
import 'package:neomama/features/forum/mama_forum_screen.dart';
import 'package:neomama/features/growth/growth_screen.dart';
import 'package:neomama/features/music/music_screen.dart';
import 'package:neomama/features/music/offline_library_screen.dart';
import 'package:neomama/features/settings/settings_screen.dart';
import 'package:neomama/features/settings/privacy_screen.dart';
import 'package:neomama/features/settings/about_screen.dart';
import 'package:neomama/features/sleep/sleep_schedule_screen.dart';
import 'package:neomama/features/teething/teething_screen.dart';
import 'package:neomama/features/vaccinations/vaccinations_screen.dart';
import 'package:neomama/features/auth/login_screen.dart';

class ShellRoutes {
  const ShellRoutes._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    BabyProfile? babyArg() =>
        settings.arguments is BabyProfile ? settings.arguments as BabyProfile : null;

    MaterialPageRoute page(Widget child) =>
        MaterialPageRoute(builder: (_) => child, settings: settings);

    MaterialPageRoute babyOrRedirect(Widget Function(BabyProfile baby) builder) {
      final baby = babyArg();
      if (baby == null) return page(const BabyListScreen());
      return page(builder(baby));
    }

    switch (settings.name) {
      case RouteNames.login:
        return page(const LoginScreen());
      case RouteNames.babyList:
        return page(const BabyListScreen());
      case RouteNames.babyForm:
        return page(BabyFormScreen(baby: babyArg()));
      case RouteNames.babyProfile:
        return babyOrRedirect((b) => BabyProfileScreen(baby: b));
      case RouteNames.dashboard:
        return babyOrRedirect((b) => DashboardScreen(baby: b));

      case RouteNames.ai:
        return babyOrRedirect((b) => AiSupportScreen(baby: b));
      case RouteNames.feeding:
        return babyOrRedirect((b) => FeedingScreen(baby: b));
      case RouteNames.vaccinations:
        return babyOrRedirect((b) => VaccinationsScreen(baby: b));
      case RouteNames.teething:
        return babyOrRedirect((b) => TeethingScreen(baby: b));
      case RouteNames.growth:
        return babyOrRedirect((b) => GrowthScreen(baby: b));
      case RouteNames.sleep:
        return page(const SleepScheduleScreen());

      case RouteNames.favorites:
        return page(const FavoritesScreen());
      case RouteNames.blog:
        return page(const BlogFeedScreen());
      case RouteNames.forum:
        return page(const MamaForumScreen());
      case RouteNames.music:
        return page(const MusicScreen());
      case RouteNames.offlineLibrary:
        return page(const OfflineLibraryScreen());
      case RouteNames.articles:
        return page(const ArticlesScreen());
      case RouteNames.settings:
        return page(const SettingsScreen());
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
        return page(const BabyListScreen());
    }
  }
}
