import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'FirebaseOptions are not configured for web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'FirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChYETkvtsKIQked1e6u4MLdoFha0eGjFg',
    appId: '1:32008875629:ios:a736842fa5ce119fcad964',
    messagingSenderId: '32008875629',
    projectId: 'neomama-2026',
    storageBucket: 'neomama-2026.firebasestorage.app',
    iosClientId:
        '32008875629-h4f2a5a2ra8pct1gb6ommo1njse536rf.apps.googleusercontent.com',
    iosBundleId: 'com.dilak.neomama',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyChYETkvtsKIQked1e6u4MLdoFha0eGjFg',
    appId: '1:32008875629:ios:a736842fa5ce119fcad964',
    messagingSenderId: '32008875629',
    projectId: 'neomama-2026',
    storageBucket: 'neomama-2026.firebasestorage.app',
    iosClientId:
        '32008875629-h4f2a5a2ra8pct1gb6ommo1njse536rf.apps.googleusercontent.com',
    iosBundleId: 'com.dilak.neomama',
  );
}
