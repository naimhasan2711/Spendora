import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glossy_card.dart';
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

    return GlossyCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
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
                  color: Colors.white,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${topEntries.length} categories',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
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
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: context.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
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
    return GlossyCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Category',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.pie_chart_outline_rounded,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No expenses this month',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
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
