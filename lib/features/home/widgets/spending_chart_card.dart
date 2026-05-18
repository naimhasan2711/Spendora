import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../transactions/providers/transactions_provider.dart';

/// Spending Chart Card - Line chart showing daily spending trend
class SpendingChartCard extends ConsumerWidget {
  final DateTime month;

  const SpendingChartCard({super.key, required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(monthlyTransactionsProvider(month));
    final dailyData = _calculateDailySpending(transactions, month);

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
            'Spending Trend',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: _hasNoSpending(dailyData)
                ? _buildEmptyState(context)
                : LineChart(
                    _buildLineChartData(context, dailyData),
                    duration: const Duration(milliseconds: 250),
                  ),
          ),
        ],
      ),
    );
  }

  /// Check if there's no spending data
  bool _hasNoSpending(Map<int, double> dailyData) {
    return dailyData.values.every((v) => v == 0);
  }

  Map<int, double> _calculateDailySpending(
    List<TransactionModel> transactions,
    DateTime month,
  ) {
    final dailySpending = <int, double>{};
    final daysInMonth = DateHelpers.daysInMonth(month);

    // Initialize all days to 0
    for (int day = 1; day <= daysInMonth; day++) {
      dailySpending[day] = 0;
    }

    // Sum expenses for each day
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        final day = transaction.dateTime.day;
        dailySpending[day] = (dailySpending[day] ?? 0) + transaction.amount;
      }
    }

    return dailySpending;
  }

  LineChartData _buildLineChartData(
    BuildContext context,
    Map<int, double> dailyData,
  ) {
    final spots = dailyData.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final maxY = dailyData.values.isEmpty
        ? 1000.0
        : dailyData.values.reduce((a, b) => a > b ? a : b) * 1.2;

    // Ensure interval is never 0
    final interval = maxY > 0 ? maxY / 4 : 250.0;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (value) => FlLine(
          color: context.colorScheme.outline.withValues(alpha: 0.1),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: interval,
            getTitlesWidget: (value, meta) {
              return Text(
                AppFormatters.formatCompactCurrency(value),
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: 7,
            getTitlesWidget: (value, meta) {
              if (value % 7 == 1 || value == 1) {
                return Text(
                  value.toInt().toString(),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 1,
      maxX: dailyData.length.toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: context.colorScheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.colorScheme.primary.withValues(alpha: 0.3),
                context.colorScheme.primary.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => context.colorScheme.surface,
          getTooltipItems: (spots) {
            return spots.map((spot) {
              return LineTooltipItem(
                'Day ${spot.x.toInt()}\n${AppFormatters.formatCurrency(spot.y)}',
                context.textTheme.bodySmall!.copyWith(
                  color: context.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart_rounded,
            size: 48,
            color: context.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'No spending data',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
