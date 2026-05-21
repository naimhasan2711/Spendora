import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/services/export_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../categories/providers/categories_provider.dart';
import '../../home/screens/dashboard_screen.dart';

/// Period toggle provider
final reportPeriodProvider =
    StateProvider<int>((ref) => 0); // 0: Monthly, 1: Yearly

/// Reports & Analytics Screen - Redesigned to match Figma
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _isExporting = false;

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Export Reports',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded,
                    color: AppTheme.error),
              ),
              title: const Text('Download PDF'),
              subtitle: const Text('Detailed Visual Report'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _exportPDF();
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.table_chart_rounded,
                    color: AppTheme.success),
              ),
              title: const Text('Download CSV'),
              subtitle: const Text('Raw Data for Excel'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _exportCSV();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPDF() async {
    setState(() => _isExporting = true);

    try {
      final selectedMonth = ref.read(selectedMonthProvider);
      final startDate = DateTime(selectedMonth.year, selectedMonth.month, 1);
      final endDate = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

      final success = await ExportService.instance.sharePDFReport(
        startDate: startDate,
        endDate: endDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'PDF report generated successfully!'
                  : 'Failed to generate PDF report',
            ),
            backgroundColor: success ? AppTheme.success : AppTheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportCSV() async {
    setState(() => _isExporting = true);

    try {
      final selectedMonth = ref.read(selectedMonthProvider);
      final startDate = DateTime(selectedMonth.year, selectedMonth.month, 1);
      final endDate = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

      final success = await ExportService.instance.shareCSV(
        startDate: startDate,
        endDate: endDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'CSV exported successfully!' : 'Failed to export CSV',
            ),
            backgroundColor: success ? AppTheme.success : AppTheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final period = ref.watch(reportPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const ProfileAvatar(radius: 16),
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
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row with Export Button - animated
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Financial Analytics',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _isExporting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : OutlinedButton.icon(
                          onPressed: _showExportOptions,
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Export'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Period Toggle with animation
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 150),
              child: Row(
                children: [
                  _PeriodTab(
                    label: 'Monthly',
                    isSelected: period == 0,
                    onTap: () =>
                        ref.read(reportPeriodProvider.notifier).state = 0,
                  ),
                  const SizedBox(width: 8),
                  _PeriodTab(
                    label: 'Yearly',
                    isSelected: period == 1,
                    onTap: () =>
                        ref.read(reportPeriodProvider.notifier).state = 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Income vs Expenses Card with animation
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 200),
              child: const _IncomeExpensesCard(),
            ),
            const SizedBox(height: 16),

            // Weekly Expenses Card with animation
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 225),
              child: const _WeeklyExpensesCard(),
            ),
            const SizedBox(height: 16),

            // Average Daily Spending Card with animation
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 250),
              child: const _AvgDailySpendingCard(),
            ),
            const SizedBox(height: 24),

            // Reports & Statements Section with animation
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reports & Statements',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ReportOptionTile(
                    icon: Icons.picture_as_pdf_rounded,
                    iconColor: AppTheme.error,
                    title: 'Download PDF',
                    subtitle: 'Detailed Visual Report',
                    onTap: _exportPDF,
                  ),
                  const SizedBox(height: 8),
                  _ReportOptionTile(
                    icon: Icons.table_chart_rounded,
                    iconColor: AppTheme.success,
                    title: 'Download CSV',
                    subtitle: 'Raw Data for Excel',
                    onTap: _exportCSV,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Top Spending Categories with animation
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 350),
              child: const _TopCategoriesSection(),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

/// Period Tab Widget
class _PeriodTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF252538) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.15),
                )
              : null,
        ),
        child: Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? context.colorScheme.onSurface
                : context.colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Income vs Expenses Card with Bar Chart
class _IncomeExpensesCard extends ConsumerWidget {
  const _IncomeExpensesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chartData = _getMonthlyData(ref, selectedMonth);

    // Calculate net balance
    double totalIncome = 0;
    double totalExpense = 0;
    for (final data in chartData) {
      totalIncome += data['income'] as double;
      totalExpense += data['expense'] as double;
    }
    final netBalance = totalIncome - totalExpense;

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Income vs Expenses',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Net Balance: ',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        '${netBalance >= 0 ? '+' : ''}${AppFormatters.formatCurrency(netBalance)}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: netBalance >= 0
                              ? AppTheme.income
                              : AppTheme.expense,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Legend
          Row(
            children: [
              _LegendItem(
                color: const Color(0xFF0D4A3E),
                label: 'Expenses',
              ),
              const SizedBox(width: 16),
              _LegendItem(
                color: const Color(0xFFB8D4CE),
                label: 'Income',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bar Chart
          SizedBox(
            height: 180,
            child: BarChart(
              _buildBarChartData(context, chartData),
              swapAnimationDuration: const Duration(milliseconds: 250),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMonthlyData(
      WidgetRef ref, DateTime currentMonth) {
    final result = <Map<String, dynamic>>[];

    // Get last 6 months data
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(currentMonth.year, currentMonth.month - i, 1);
      final summary = ref.watch(monthlySummaryProvider(month));

      result.add({
        'month': _getMonthAbbr(month.month),
        'income': summary.income,
        'expense': summary.expense,
      });
    }

    return result;
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  BarChartData _buildBarChartData(
    BuildContext context,
    List<Map<String, dynamic>> data,
  ) {
    final maxY = data.fold<double>(0, (max, item) {
          final income = item['income'] as double;
          final expense = item['expense'] as double;
          return [max, income, expense].reduce((a, b) => a > b ? a : b);
        }) *
        1.2;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY > 0 ? maxY : 1000,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => context.colorScheme.surface,
          tooltipPadding: const EdgeInsets.all(8),
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final item = data[groupIndex];
            final label = rodIndex == 0 ? 'Expenses' : 'Income';
            final value = rodIndex == 0
                ? item['expense'] as double
                : item['income'] as double;
            return BarTooltipItem(
              '$label\n${AppFormatters.formatCurrency(value)}',
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
              if (index >= 0 && index < data.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    data[index]['month'] as String,
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
      barGroups: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: (item['expense'] as double) > 0
                  ? item['expense'] as double
                  : 0,
              color: const Color(0xFF0D4A3E),
              width: 16,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            BarChartRodData(
              toY:
                  (item['income'] as double) > 0 ? item['income'] as double : 0,
              color: const Color(0xFFB8D4CE),
              width: 16,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
          barsSpace: 4,
        );
      }).toList(),
    );
  }
}

/// Legend Item
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

/// Average Daily Spending Card
/// Weekly Expenses Card with Bar Chart
class _WeeklyExpensesCard extends ConsumerWidget {
  const _WeeklyExpensesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weeklyData = _getWeeklyData(ref, selectedMonth);

    // Calculate total weekly expense
    double totalWeeklyExpense = 0;
    for (final data in weeklyData) {
      totalWeeklyExpense += data['expense'] as double;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A3A34), const Color(0xFF0D524A)]
              : [const Color(0xFF0D6B5E), const Color(0xFF14A085)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D6B5E).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
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
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    Colors.white.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Expenses',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last 7 days breakdown',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppFormatters.formatCurrency(totalWeeklyExpense),
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Bar Chart
              SizedBox(
                height: 140,
                child: BarChart(
                  _buildWeeklyBarChartData(context, weeklyData),
                  swapAnimationDuration: const Duration(milliseconds: 250),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getWeeklyData(
      WidgetRef ref, DateTime currentMonth) {
    final result = <Map<String, dynamic>>[];
    final now = DateTime.now();

    // Get last 7 days data
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final transactions = ref.watch(transactionsProvider);

      double dayExpense = 0;
      for (final t in transactions) {
        if (t.type == TransactionType.expense &&
            t.dateTime.year == date.year &&
            t.dateTime.month == date.month &&
            t.dateTime.day == date.day) {
          dayExpense += t.amount;
        }
      }

      result.add({
        'day': _getDayAbbr(date.weekday),
        'expense': dayExpense,
        'isToday': i == 0,
      });
    }

    return result;
  }

  String _getDayAbbr(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  BarChartData _buildWeeklyBarChartData(
    BuildContext context,
    List<Map<String, dynamic>> data,
  ) {
    final maxY = data.fold<double>(0, (max, item) {
          final expense = item['expense'] as double;
          return expense > max ? expense : max;
        }) *
        1.3;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY > 0 ? maxY : 1000,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.white,
          tooltipPadding: const EdgeInsets.all(8),
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final item = data[groupIndex];
            return BarTooltipItem(
              AppFormatters.formatCurrency(item['expense'] as double),
              const TextStyle(
                color: Color(0xFF0D4A3E),
                fontWeight: FontWeight.w600,
                fontSize: 12,
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
              if (index >= 0 && index < data.length) {
                final isToday = data[index]['isToday'] as bool;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    data[index]['day'] as String,
                    style: TextStyle(
                      color: isToday
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.6),
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      fontSize: 11,
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
      barGroups: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isToday = item['isToday'] as bool;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: (item['expense'] as double) > 0
                  ? item['expense'] as double
                  : 0,
              color:
                  isToday ? Colors.white : Colors.white.withValues(alpha: 0.5),
              width: 28,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY > 0 ? maxY : 1000,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _AvgDailySpendingCard extends ConsumerWidget {
  const _AvgDailySpendingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final summary = ref.watch(monthlySummaryProvider(selectedMonth));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate average daily spending
    final daysInMonth = DateHelpers.daysInMonth(selectedMonth);
    final daysPassed = selectedMonth.month == DateTime.now().month
        ? DateTime.now().day
        : daysInMonth;
    final avgDaily = daysPassed > 0 ? summary.expense / daysPassed : 0.0;

    // Get previous month for comparison
    final prevMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
    final prevSummary = ref.watch(monthlySummaryProvider(prevMonth));
    final prevDays = DateHelpers.daysInMonth(prevMonth);
    final prevAvgDaily = prevDays > 0 ? prevSummary.expense / prevDays : 0.0;

    // Calculate percentage change
    final percentChange = prevAvgDaily > 0
        ? ((avgDaily - prevAvgDaily) / prevAvgDaily * 100)
        : 0.0;
    final isUp = percentChange >= 0;

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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.trending_up_rounded,
              color: context.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avg. Daily Spending',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppFormatters.formatCurrency(avgDaily),
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isUp ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: isUp ? AppTheme.expense : AppTheme.income,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${percentChange.abs().toStringAsFixed(0)}% from last month',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: isUp ? AppTheme.expense : AppTheme.income,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Report Option Tile
class _ReportOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ReportOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top Spending Categories Section
class _TopCategoriesSection extends ConsumerWidget {
  const _TopCategoriesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final categorySpending = ref.watch(categorySpendingProvider(selectedMonth));
    final categories = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sort categories by spending and take top 5
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(5).toList();

    if (topCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get max spending for progress calculation
    final maxSpending =
        topCategories.isNotEmpty ? topCategories.first.value : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Spending Categories',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full categories view
              },
              child: Text(
                'View All',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...topCategories.map((entry) {
          final category = categories.firstWhere(
            (c) => c.id == entry.key,
            orElse: () => CategoryModel(
              id: entry.key,
              name: 'Unknown',
              iconCodePoint: Icons.category.codePoint,
              colorValue: Colors.grey.value,
              type: TransactionType.expense,
            ),
          );
          final progress = entry.value / maxSpending;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
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
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color:
                              Color(category.colorValue).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          IconData(category.iconCodePoint,
                              fontFamily: 'MaterialIcons'),
                          color: Color(category.colorValue),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category.name,
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        AppFormatters.formatCurrency(entry.value),
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor:
                          context.colorScheme.onSurface.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(category.colorValue),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
