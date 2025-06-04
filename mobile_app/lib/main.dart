import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard.dart';
import 'screens/baby_form.dart';
import 'models/baby_profile.dart';
import 'screens/chat_screen.dart';
import 'screens/baby_list.dart';
import 'screens/edit_baby.dart';
import 'screens/feeding_screen.dart';
import 'screens/feeding_settings.dart';
import 'screens/favorites_screen.dart';
import 'screens/offline_library_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/mama_forum_screen.dart';
import 'screens/blog_feed_screen.dart';
import 'screens/sleep_schedule_screen.dart';
import 'screens/monthly_development_screen.dart';
import 'screens/monthly_play_ideas_screen.dart';
import 'screens/articles_screen.dart';
import 'screens/music_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final babyCreated = prefs.getBool('babyCreated') ?? false;

  runApp(NeoMamaApp(isLoggedIn: isLoggedIn, babyCreated: babyCreated));
}

class NeoMamaApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool babyCreated;

  const NeoMamaApp({
    Key? key, 
    required this.isLoggedIn, 
    required this.babyCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(  
      debugShowCheckedModeBanner: false,
      title: 'NeoMama',
      theme: ThemeData(primarySwatch: Colors.pink),
      initialRoute: '/',
      routes: {
        '/': (context) {
          if (!isLoggedIn) return const WelcomeScreen();
          if (!babyCreated) return const BabyForm();
          return DashboardScreen(  
            baby: BabyProfile(  
              id: 1,
              name: 'Baby Name',
              birthDate: DateTime.now().toIso8601String(),
              allergies:  '',
              notes: '',
              feedingPreferences: '',
            ),
          );
        },
        '/login': (context) => const LoginScreen(),
        '/babyform': (context) => const BabyForm(),
        '/dashboard': (context) => DashboardScreen(
              baby: ModalRoute.of(context)?.settings.arguments as BabyProfile,
            ),
        '/chat': (context) => const ChatScreen(),
        '/list': (context) => const BabyList(),
        '/edit': (context) {
          final baby = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return EditBaby(baby: baby);
        },
        '/feeding': (context) => const FeedingScreen(),
        '/feeding-settings': (context) => const FeedingSettings(babyId: '1'), 
        '/favorites': (context) => const FavoritesScreen(),
        '/downloads': (context) => OfflineLibraryScreen(),
        '/menu': (context) => const MenuScreen(),
        '/forum': (context) => const MamaForumScreen(),
        '/blog': (context) => const BlogFeedScreen(),
        '/sleep': (context) => const SleepScheduleScreen(),
        '/monthly':(context) => const MonthlyDevelopmentScreen(),
        '/play': (context) => const MonthlyPlayIdeasScreen(),
        '/articles': (context) => const ArticlesScreen(),
        '/music': (context) => const MusicScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}