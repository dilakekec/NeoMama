import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'neomama_app.dart';
import 'services/audio_handler.dart';
import 'services/local_notifications_service.dart';

Future<void> main() async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    
    await _loadEnvSafe();

    
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      Zone.current.handleUncaughtError(
        details.exception,
        details.stack ?? StackTrace.current,
      );
    };

    
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      Zone.current.handleUncaughtError(error, stack);
      return true; 
    };

    
    await _initFirebaseSafe();

    
    await _initAudioServiceSafe();

    
    await _initLocalNotificationsSafe();

    runApp(const NeoMamaApp());
  }, (Object error, StackTrace stack) {
    _log('Uncaught zone error: $error');
    _log(stack.toString());

    
    
  });
}

Future<void> _loadEnvSafe() async {
  try {
    
    
    await dotenv.load(fileName: '.env');
    _log('dotenv loaded');
  } catch (e) {
    
    _log('dotenv load skipped/failed: $e');
  }
}

Future<void> _initFirebaseSafe() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _log('Firebase initialized');
  } catch (e, st) {
    _log('Firebase init failed: $e');
    _log(st.toString());

    
    
    
    
    
    
    final required = (dotenv.env['FIREBASE_REQUIRED'] ?? '').toLowerCase() == 'true';
    if (required) rethrow;
  }
}

Future<void> _initAudioServiceSafe() async {
  try {
    audioHandler = await AudioService.init(
      builder: () => NeoAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'neomama.music',
        androidNotificationChannelName: 'NeoMama Music',
        androidNotificationChannelDescription: 'Playback controls for NeoMama',
        androidNotificationOngoing: true,
      ),
    );
    _log('AudioService initialized');
  } catch (e, st) {
    _log('AudioService init failed: $e');
    _log(st.toString());
    
  }
}

Future<void> _initLocalNotificationsSafe() async {
  try {
    await LocalNotificationsService.init();
    await LocalNotificationsService.requestPermissions();
    _log('Local notifications initialized');
  } catch (e, st) {
    _log('Local notifications init failed: $e');
    _log(st.toString());
  }
}

void _log(String msg) {
  if (kDebugMode) {
    
    print(msg);
  }
}
