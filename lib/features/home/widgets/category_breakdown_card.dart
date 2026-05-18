import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../categories/providers/categories_provider.dart';

/// Category Breakdown Card - Pie chart showing expense breakdown
class CategoryBreakdownCard extends ConsumerWidget {
  final DateTime month;

  const CategoryBreakdownCard({super.key, required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorySpending = ref.watch(categorySpendingProvider(month));
    final categories = ref.watch(categoriesProvider);

    if (categorySpending.isEmpty) {
      return _buildEmptyCard(context);
    }

    // Sort by amount and take top categories
    final sortedEntries = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topEntries = sortedEntries.take(6).toList();
    final totalExpense = categorySpending.values.fold(0.0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending by Category',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${topEntries.length} categories',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Pie Chart
              SizedBox(
                width: 140,
                height: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 40,
                    sections: topEntries.asMap().entries.map((entry) {
                      final categoryId = entry.value.key;
                      final amount = entry.value.value;
                      final category =
                          categories.cast<CategoryModel?>().firstWhere(
                                (c) => c?.id == categoryId,
                                orElse: () => null,
                              );

                      return PieChartSectionData(
                        value: amount,
                        title: '',
                        radius: 28,
                        color: category != null
                            ? Color(category.colorValue)
                            : Colors.grey,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: topEntries.map((entry) {
                    final category =
                        categories.cast<CategoryModel?>().firstWhere(
                              (c) => c?.id == entry.key,
                              orElse: () => null,
                            );
                    final percentage = (entry.value / totalExpense * 100);
                    final catColor = category != null
                        ? Color(category.colorValue)
                        : Colors.grey;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  catColor,
                                  catColor.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              category?.name ?? 'Other',
                              style: context.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: context.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: catColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Category',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.pie_chart_outline_rounded,
                  size: 48,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'No expenses this month',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
