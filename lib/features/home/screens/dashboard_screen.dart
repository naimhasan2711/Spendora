import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../accounts/providers/accounts_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/recent_transactions_card.dart';
import '../widgets/spending_chart_card.dart';
import '../widgets/category_breakdown_card.dart';
import '../widgets/budget_overview_card.dart';

/// Selected month provider for dashboard
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Dashboard Screen
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final summary = ref.watch(monthlySummaryProvider(selectedMonth));
    final totalBalance = ref.watch(totalBalanceProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Total Balance
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colorScheme.primary.withValues(alpha: 0.1),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Hello! 👋',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: (totalBalance >= 0
                                        ? AppTheme.income
                                        : AppTheme.expense)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    totalBalance >= 0
                                        ? Icons.trending_up_rounded
                                        : Icons.trending_down_rounded,
                                    size: 16,
                                    color: totalBalance >= 0
                                        ? AppTheme.income
                                        : AppTheme.expense,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    totalBalance >= 0 ? 'Healthy' : 'Low',
                                    style:
                                        context.textTheme.labelSmall?.copyWith(
                                      color: totalBalance >= 0
                                          ? AppTheme.income
                                          : AppTheme.expense,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Balance',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppFormatters.formatCurrency(totalBalance),
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: totalBalance >= 0
                                ? AppTheme.income
                                : AppTheme.expense,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: context.colorScheme.primary,
                    size: 20,
                  ),
                ),
                onPressed: () => context.push(AppRoutes.search),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: context.colorScheme.primary,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  // TODO: Show notifications
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Month Selector
          SliverToBoxAdapter(
            child: _MonthSelector(
              selectedMonth: selectedMonth,
              onPreviousMonth: () {
                ref.read(selectedMonthProvider.notifier).state =
                    DateHelpers.previousMonth(selectedMonth);
              },
              onNextMonth: () {
                final nextMonth = DateHelpers.nextMonth(selectedMonth);
                if (nextMonth
                    .isBefore(DateTime.now().add(const Duration(days: 32)))) {
                  ref.read(selectedMonthProvider.notifier).state = nextMonth;
                }
              },
            ),
          ),

          // Summary Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Income',
                      amount: summary.income,
                      icon: Icons.arrow_downward_rounded,
                      color: AppTheme.income,
                      trend: '+12%', // TODO: Calculate actual trend
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      title: 'Expense',
                      amount: summary.expense,
                      icon: Icons.arrow_upward_rounded,
                      color: AppTheme.expense,
                      trend: '-5%',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Balance Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: context.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Balance',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppFormatters.formatCurrency(summary.balance),
                          style: context.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            summary.savingsRate >= 0
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${summary.savingsRate.toStringAsFixed(0)}% saved',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Spending Chart
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SpendingChartCard(month: selectedMonth),
            ),
          ),

          // Category Breakdown
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CategoryBreakdownCard(month: selectedMonth),
            ),
          ),

          // Budget Overview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BudgetOverviewCard(month: selectedMonth),
            ),
          ),

          // Recent Transactions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: RecentTransactionsCard(month: selectedMonth),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}

/// Month Selector Widget
class _MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const _MonthSelector({
    required this.selectedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentMonth =
        DateHelpers.isSameMonth(selectedMonth, DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: onPreviousMonth,
          ),
          GestureDetector(
            onTap: () => _showMonthPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppFormatters.formatMonthYear(selectedMonth),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.primary,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              color: isCurrentMonth
                  ? context.colorScheme.onSurface.withValues(alpha: 0.3)
                  : null,
            ),
            onPressed: isCurrentMonth ? null : onNextMonth,
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    // TODO: Implement month picker dialog
  }
}
