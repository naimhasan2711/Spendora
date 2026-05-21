import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../accounts/providers/accounts_provider.dart';
import '../widgets/recent_transactions_card.dart';
import '../widgets/spending_chart_card.dart';
import '../widgets/category_breakdown_card.dart';
import '../widgets/budget_overview_card.dart';

/// Selected month provider for dashboard
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Dashboard Screen - Redesigned with animations
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final summary = ref.watch(monthlySummaryProvider(selectedMonth));
    final totalBalance = ref.watch(totalBalanceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Profile and Settings
          SliverAppBar(
            expandedHeight: 60,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Row(
              children: [
                // Profile Avatar - synced from settings
                const ProfileAvatar(radius: 18),
                const SizedBox(width: 12),
                Text(
                  'Spendora',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0D4A3E),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: context.colorScheme.onSurface,
                ),
                onPressed: () => context.push(AppRoutes.settings),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Total Balance Card with animation
          SliverToBoxAdapter(
            child: AnimatedFadeSlide(
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildBalanceCard(context, totalBalance, summary),
              ),
            ),
          ),

          // Weekly Trend Chart with animation
          SliverToBoxAdapter(
            child: AnimatedFadeSlide(
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SpendingChartCard(month: selectedMonth),
              ),
            ),
          ),

          // Category Breakdown with animation
          SliverToBoxAdapter(
            child: AnimatedFadeSlide(
              delay: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CategoryBreakdownCard(month: selectedMonth),
              ),
            ),
          ),

          // Monthly Budgets Section with animation
          SliverToBoxAdapter(
            child: AnimatedFadeSlide(
              delay: const Duration(milliseconds: 400),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BudgetOverviewCard(month: selectedMonth),
              ),
            ),
          ),

          // Recent Transactions with animation
          SliverToBoxAdapter(
            child: AnimatedFadeSlide(
              delay: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: RecentTransactionsCard(month: selectedMonth),
              ),
            ),
          ),

          // Bottom spacing for FAB
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
      BuildContext context, double totalBalance, MonthlySummary summary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1A3A34),
                  const Color(0xFF0D524A),
                  const Color(0xFF0A3D36)
                ]
              : [
                  const Color(0xFF0D6B5E),
                  const Color(0xFF14A085),
                  const Color(0xFF0D6B5E)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D6B5E).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glossy overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL BALANCE',
                style: context.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: totalBalance),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppFormatters.formatCurrency(value),
                      style: context.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _BalanceBadge(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Income',
                      amount: summary.income,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      textColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BalanceBadge(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Expenses',
                      amount: summary.expense,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Badge widget for income/expense in balance card
class _BalanceBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color backgroundColor;
  final Color textColor;

  const _BalanceBadge({
    required this.icon,
    required this.label,
    required this.amount,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: textColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppFormatters.formatCurrency(amount),
                    style: context.textTheme.titleSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
