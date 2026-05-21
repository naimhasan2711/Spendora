import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/providers/settings_provider.dart';

/// Splash Screen with animated logo
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(AppConstants.splashDuration);

    if (!mounted) return;

    final settings = ref.read(settingsProvider);

    if (!settings.onboardingComplete) {
      // First launch - show onboarding
      context.go(AppRoutes.onboarding);
    } else if (settings.pinEnabled) {
      // PIN is enabled - show PIN screen
      context.go(AppRoutes.pin);
    } else {
      // Go to home
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 60,
                color: Color(0xFF0D4A3E),
              ),
            )
                .animate()
                .scale(
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 32),

            // App Name
            Text(
              AppConstants.appName,
              style: context.textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 8),

            // Tagline
            Text(
              AppConstants.appTagline,
              style: context.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 60),

            // Loading indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
