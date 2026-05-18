import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/providers/settings_provider.dart';

/// Onboarding Screen with multiple slides
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    const OnboardingData(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Track Every Expense',
      description:
          'Easily record your daily expenses and income. Keep track of where your money goes with just a few taps.',
      color: Color(0xFF6C63FF),
    ),
    const OnboardingData(
      icon: Icons.pie_chart_rounded,
      title: 'Visual Reports',
      description:
          'Beautiful charts and graphs help you understand your spending patterns. Make smarter financial decisions.',
      color: Color(0xFF4ECDC4),
    ),
    const OnboardingData(
      icon: Icons.savings_rounded,
      title: 'Set Budgets & Goals',
      description:
          'Create monthly budgets and savings goals. Stay on track and achieve your financial dreams.',
      color: Color(0xFFFF6B6B),
    ),
    const OnboardingData(
      icon: Icons.cloud_off_rounded,
      title: '100% Offline & Secure',
      description:
          'All your data stays on your device. No internet required, no cloud storage. Your privacy is protected.',
      color: Color(0xFF22C55E),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: Text(
                  'Skip',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(data: _pages[index]);
                },
              ),
            ),

            // Page Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: WormEffect(
                  dotWidth: 10,
                  dotHeight: 10,
                  spacing: 8,
                  activeDotColor: context.colorScheme.primary,
                  dotColor: context.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
            ),

            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual onboarding page
class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 80,
              color: data.color,
            ),
          )
              .animate()
              .scale(duration: 500.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 48),

          // Title
          Text(
            data.title,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          // Description
          Text(
            data.description,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

/// Data class for onboarding pages
class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
