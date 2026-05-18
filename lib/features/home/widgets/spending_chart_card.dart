import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../transactions/providers/transactions_provider.dart';

/// Spending Chart Card - Bar chart showing weekly spending trend
class SpendingChartCard extends ConsumerWidget {
  final DateTime month;

  const SpendingChartCard({super.key, required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(monthlyTransactionsProvider(month));
    final weeklyData = _calculateWeeklySpending(transactions);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252538) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Trend',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Last 7 Days',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: _hasNoSpending(weeklyData)
                ? _buildEmptyState(context)
                : BarChart(
                    _buildBarChartData(context, weeklyData),
                    swapAnimationDuration: const Duration(milliseconds: 250),
                  ),
          ),
        ],
      ),
    );
  }

  /// Check if there's no spending data
  bool _hasNoSpending(List<double> weeklyData) {
    return weeklyData.every((v) => v == 0);
  }

  /// Calculate spending for the last 7 days (Mon-Sun)
  List<double> _calculateWeeklySpending(List<TransactionModel> transactions) {
    final now = DateTime.now();
    final weekData = List<double>.filled(7, 0);

    // Calculate spending for each of the last 7 days
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      for (final transaction in transactions) {
        if (transaction.type == TransactionType.expense &&
            transaction.dateTime.isAfter(dayStart) &&
            transaction.dateTime.isBefore(dayEnd)) {
          weekData[i] += transaction.amount;
        }
      }
    }

    return weekData;
  }

  BarChartData _buildBarChartData(
      BuildContext context, List<double> weeklyData) {
    final maxY = weeklyData.isEmpty
        ? 1000.0
        : weeklyData.reduce((a, b) => a > b ? a : b) * 1.2;

    // Day labels for last 7 days
    final now = DateTime.now();
    final dayLabels = <String>[];
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      dayLabels.add(_getDayLabel(date.weekday));
    }

    // Bar color - salmon/peach like in the design
    const barColor = Color(0xFFEBB89C);

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY > 0 ? maxY : 1000,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => context.colorScheme.surface,
          tooltipPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${dayLabels[group.x.toInt()]}\n${AppFormatters.formatCurrency(rod.toY)}',
              context.textTheme.bodySmall!.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < dayLabels.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    dayLabels[index],
                    style: context.textTheme.labelSmall?.copyWith(
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: weeklyData.asMap().entries.map((entry) {
        final index = entry.key;
        final value = entry.value;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value > 0 ? value : 0,
              color: barColor,
              width: 28,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY > 0 ? maxY : 1000,
                color: context.colorScheme.onSurface.withValues(alpha: 0.05),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getDayLabel(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 48,
            color: context.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'No spending this week',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
