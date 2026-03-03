import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:neomama/core/config/route_names.dart';
import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/l10n/app_strings.dart';

class LoginScreen extends StatefulWidget {
  final String? initialProvider;

  const LoginScreen({super.key, this.initialProvider});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  bool _showPassword = false;
  String? _error;
  bool _didAuto = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didAuto) return;
    final provider = widget.initialProvider;
    if (provider == null || provider.isEmpty) return;
    _didAuto = true;
    if (provider == 'google') {
      _signInWithGoogle();
    } else if (provider == 'apple') {
      _signInWithApple();
    }
  }

  void _setLoading(bool v) {
    if (!mounted) return;
    setState(() => _loading = v);
  }

  void _setError(String? msg) {
    if (!mounted) return;
    setState(() => _error = msg);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteNames.babyList);
  }

  String _authErrorMessage(Object error, {required String fallback}) {
    if (error is FirebaseAuthException) {
      final msg = error.message?.trim();
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return fallback;
  }

  Future<void> _signInWithEmail() async {
    final failMessage = AppStrings.t(context, 'auth_failed');
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      _setError(AppStrings.t(context, 'auth_fill_fields'));
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          rethrow;
        }
      }

      _goNext();
    } catch (e) {
      _setError(_authErrorMessage(e, fallback: failMessage));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _signInWithGoogle() async {
    final failMessage = AppStrings.t(context, 'auth_failed');
    _setLoading(true);
    _setError(null);

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _setLoading(false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _goNext();
    } catch (e) {
      _setError(_authErrorMessage(e, fallback: failMessage));
    } finally {
      _setLoading(false);
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final rand = Random.secure();
    return List.generate(length, (_) => charset[rand.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _signInWithApple() async {
    final failMessage = AppStrings.t(context, 'auth_failed');
    _setLoading(true);
    _setError(null);

    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.dilak.neomama.service',
          redirectUri: Uri.parse(
            'https://neomama-2026.firebaseapp.com/__/auth/handler',
          ),
        ),
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );

      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      _goNext();
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        _setLoading(false);
        return;
      }
      _setError(failMessage);
    } catch (e) {
      _setError(_authErrorMessage(e, fallback: failMessage));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _signInAnonymously() async {
    final failMessage = AppStrings.t(context, 'auth_failed');
    _setLoading(true);
    _setError(null);

    try {
      await FirebaseAuth.instance.signInAnonymously();
      _goNext();
    } catch (e) {
      _setError(_authErrorMessage(e, fallback: failMessage));
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                navigator.pop();
              } else {
                navigator.pushReplacementNamed(RouteNames.onboarding);
              }
            },
          ),
          title: Text(AppStrings.t(context, 'sign_in'), style: t.titleLarge),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            NeoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.t(context, 'sign_in_sub'),
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: AppStrings.t(context, 'email'),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: !_showPassword,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: AppStrings.t(context, 'password'),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                        icon: Icon(
                          _showPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                    onFieldSubmitted: (_) => _loading ? null : _signInWithEmail(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _signInWithEmail,
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(AppStrings.t(context, 'sign_in')),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.error_outline, color: cs.error),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _error!,
                            style: t.bodyMedium?.copyWith(color: cs.error),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            NeoCard(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : _signInWithGoogle,
                      icon: const Icon(Icons.g_mobiledata_rounded),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          AppStrings.t(context, 'onboarding_continue_google'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : _signInWithApple,
                      icon: const Icon(Icons.apple_rounded),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          AppStrings.t(context, 'onboarding_continue_apple'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: _loading ? null : _signInAnonymously,
                      icon: const Icon(Icons.person_outline),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          AppStrings.t(context, 'continue_without_account'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.t(context, 'offline_friendly'),
                    style: t.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
