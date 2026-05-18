import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../core/models/models.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../providers/budgets_provider.dart';
import '../../categories/providers/categories_provider.dart';

/// Budgets Screen
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);
    final activeBudgets = ref.watch(activeBudgetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
      ),
      body: budgets.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activeBudgets.length,
              itemBuilder: (context, index) {
                final budget = activeBudgets[index];
                return _BudgetCard(budget: budget);
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'budgetsFAB',
        onPressed: () => context.push(AppRoutes.addBudget),
        child: const Icon(Icons.add),
      ),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                      color: category != null
                          ? Color(category.colorValue).withValues(alpha: 0.15)
                          : progressColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      category != null
                          ? IconData(category.iconCodePoint,
                              fontFamily: 'MaterialIcons')
                          : Icons.pie_chart_rounded,
                      color: category != null
                          ? Color(category.colorValue)
                          : progressColor,
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
                          ),
                        ),
                        Text(
                          _getPeriodLabel(budget.period),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.6),
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
                        color: AppTheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Over Budget',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: AppTheme.error,
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
                backgroundColor:
                    context.colorScheme.outline.withValues(alpha: 0.1),
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
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        AppFormatters.formatCurrency(spent),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
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
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.5),
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
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        AppFormatters.formatCurrency(limit),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
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
