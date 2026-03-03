import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../baby/baby_list_screen.dart';
import 'login_screen.dart';
import '../../core/theme/neo_background.dart';

class AuthGate extends StatelessWidget {
  final String? initialProvider;

  const AuthGate({super.key, this.initialProvider});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return NeoBackground(
            child: Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
        }

        if (snap.data != null) {
          return const BabyListScreen();
        }

        return LoginScreen(initialProvider: initialProvider);
      },
    );
  }
}
