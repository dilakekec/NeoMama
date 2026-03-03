import 'package:flutter/material.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/config/route_names.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return NeoBackground(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      
                      
                      Navigator.pushReplacementNamed(context, RouteNames.babyList);
                    },
                    child: Text(
                      AppStrings.t(context, 'onboarding_skip'),
                      style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),

                const Spacer(),

                
                _Entrance(
                  delay: const Duration(milliseconds: 0),
                  child: Center(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(34),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                            color: Colors.black.o(0.10),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/icons/features/neomama_logo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                _Entrance(
                  delay: const Duration(milliseconds: 80),
                  child: Text(
                    AppStrings.t(context, 'onboarding_hello'),
                    style: t.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                _Entrance(
                  delay: const Duration(milliseconds: 140),
                  child: Text(
                    AppStrings.t(context, 'onboarding_tagline'),
                    style: t.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),

                const Spacer(),

                
                _Entrance(
                  delay: const Duration(milliseconds: 200),
                  child: NeoCard(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                RouteNames.login,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                AppStrings.t(context, 'onboarding_continue_email'),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                RouteNames.login,
                                arguments: 'google',
                              );
                            },
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
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                RouteNames.login,
                                arguments: 'apple',
                              );
                            },
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

                        Text(
                          AppStrings.t(context, 'onboarding_footer'),
                          style: t.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Center(
                  child: _Entrance(
                    delay: const Duration(milliseconds: 260),
                    child: Text(
                      AppStrings.t(context, 'offline_friendly'),
                      style: t.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Entrance extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const _Entrance({
    required this.child,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        final d = (1 - v) * 18;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, d),
            child: child,
          ),
        );
      },
      
      child: FutureBuilder<void>(
        future: Future<void>.delayed(delay),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const SizedBox.shrink();
          }
          return child;
        },
      ),
    );
  }
}
