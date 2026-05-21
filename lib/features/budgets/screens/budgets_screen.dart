import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../core/models/models.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../providers/budgets_provider.dart';
import '../../categories/providers/categories_provider.dart';

/// Budgets Screen
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);
    final activeBudgets = ref.watch(activeBudgetsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const ProfileAvatar(radius: 16),
            const SizedBox(width: 12),
            Text(
              'Budgets',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0D4A3E),
              ),
            ),
          ],
        ),
        actions: [
          // Add Budget Button in AppBar
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add_rounded,
                color: context.colorScheme.primary,
                size: 20,
              ),
            ),
            onPressed: () => context.push(AppRoutes.addBudget),
            tooltip: 'Add Budget',
          ),
        ],
      ),
      body: budgets.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activeBudgets.length,
              itemBuilder: (context, index) {
                final budget = activeBudgets[index];
                return AnimatedFadeSlide(
                  delay: Duration(milliseconds: 100 + (index * 50)),
                  child: _BudgetCard(budget: budget),
                );
              },
            ),
      // FAB removed to avoid conflict with MainScreen FAB
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              size: 80,
              color: context.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 24),
            Text(
              'No Budgets Yet',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create budgets to control your spending and achieve your financial goals',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.addBudget),
              icon: const Icon(Icons.add),
              label: const Text('Create Budget'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCard extends ConsumerWidget {
  final BudgetModel budget;

  const _BudgetCard({required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = budget.categoryId != null
        ? ref.watch(categoryByIdProvider(budget.categoryId!))
        : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final spent = budget.spent;
    final limit = budget.amount;
    final remaining = limit - spent;
    final progress = (spent / limit).clamp(0.0, 1.0);
    final isOverBudget = spent > limit;

    Color progressColor;
    if (progress < 0.7) {
      progressColor = AppTheme.success;
    } else if (progress < 1.0) {
      progressColor = AppTheme.warning;
    } else {
      progressColor = AppTheme.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D6B5E).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Show budget details
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      category != null
                          ? IconData(category.iconCodePoint,
                              fontFamily: 'MaterialIcons')
                          : Icons.pie_chart_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _getPeriodLabel(budget.period),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOverBudget)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Over Budget',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Progress Bar
              LinearPercentIndicator(
                lineHeight: 12,
                percent: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                progressColor: progressColor,
                barRadius: const Radius.circular(6),
                padding: EdgeInsets.zero,
                animation: true,
              ),
              const SizedBox(height: 16),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spent',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        AppFormatters.formatCurrency(spent),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Remaining',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        AppFormatters.formatCurrency(remaining.abs()),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isOverBudget ? AppTheme.error : AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Budget',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        AppFormatters.formatCurrency(limit),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPeriodLabel(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.daily:
        return 'Daily budget';
      case BudgetPeriod.weekly:
        return 'Weekly budget';
      case BudgetPeriod.monthly:
        return 'Monthly budget';
      case BudgetPeriod.yearly:
        return 'Yearly budget';
      case BudgetPeriod.custom:
        return 'Custom budget';
    }
  }
}
