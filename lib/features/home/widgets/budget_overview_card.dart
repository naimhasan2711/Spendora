import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../core/models/models.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glossy_card.dart';
import '../../budgets/providers/budgets_provider.dart';
import '../../categories/providers/categories_provider.dart';

/// Budget Overview Card
class BudgetOverviewCard extends ConsumerWidget {
  final DateTime month;

  const BudgetOverviewCard({super.key, required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(monthlyBudgetsProvider(month));
    final activeBudgets = budgets.where((b) => b.isActive).toList();

    return GlossyCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget Overview',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.budgets),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.9),
                ),
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (activeBudgets.isEmpty)
            _buildEmptyState(context)
          else
            ...activeBudgets
                .take(3)
                .map((budget) => _BudgetProgressTile(budget: budget)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No budgets set',
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Create a budget to track your spending',
              style: context.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.addBudget),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Create Budget'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual Budget Progress Tile
class _BudgetProgressTile extends ConsumerWidget {
  final BudgetModel budget;

  const _BudgetProgressTile({required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = budget.categoryId != null
        ? ref.watch(categoryByIdProvider(budget.categoryId!))
        : null;

    final progress = budget.progress / 100;
    final color = _getProgressColor(budget.progress);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category != null
                      ? IconData(category.iconCodePoint,
                          fontFamily: 'MaterialIcons')
                      : Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),

              // Budget Name
              Expanded(
                child: Text(
                  budget.categoryId == null
                      ? 'Overall Budget'
                      : category?.name ?? budget.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.formatCurrency(budget.spent),
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  Text(
                    'of ${AppFormatters.formatCurrency(budget.amount)}',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress Bar
          LinearPercentIndicator(
            lineHeight: 8,
            percent: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            progressColor: color,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
          ),

          // Warning if exceeding
          if (budget.isExceeded) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: AppTheme.error,
                ),
                const SizedBox(width: 4),
                Text(
                  'Exceeded by ${AppFormatters.formatCurrency(budget.spent - budget.amount)}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: AppTheme.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 100) return AppTheme.error;
    if (progress >= 80) return AppTheme.warning;
    return AppTheme.success;
  }
}
