import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../categories/providers/categories_provider.dart';
import '../../home/screens/dashboard_screen.dart';

/// Reports & Analytics Screen
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'By Category'),
            Tab(text: 'Trends'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _OverviewTab(),
          _CategoryTab(),
          _TrendsTab(),
        ],
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final summary = ref.watch(monthlySummaryProvider(selectedMonth));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  ref.read(selectedMonthProvider.notifier).state = DateTime(
                    selectedMonth.year,
                    selectedMonth.month - 1,
                  );
                },
              ),
              Text(
                AppFormatters.formatMonthYear(selectedMonth),
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  ref.read(selectedMonthProvider.notifier).state = DateTime(
                    selectedMonth.year,
                    selectedMonth.month + 1,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Income',
                  amount: summary.income,
                  color: AppTheme.income,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Expense',
                  amount: summary.expense,
                  color: AppTheme.expense,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: 'Net Balance',
            amount: summary.balance,
            color: summary.balance >= 0 ? AppTheme.income : AppTheme.expense,
            icon: summary.balance >= 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
          ),
          const SizedBox(height: 24),

          // Balance Chart
          Text(
            'Daily Balance',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _DailyBalanceChart(),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodySmall?.copyWith(
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    AppFormatters.formatCurrency(amount),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyBalanceChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final transactions = ref.watch(monthlyTransactionsProvider(selectedMonth));

    // Group by day
    final Map<int, double> dailyBalance = {};
    for (final t in transactions) {
      final day = t.dateTime.day;
      final amount = t.type == TransactionType.income ? t.amount : -t.amount;
      dailyBalance[day] = (dailyBalance[day] ?? 0) + amount;
    }

    final spots = dailyBalance.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    if (spots.isEmpty) {
      return const Center(child: Text('No data'));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: context.colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: context.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTab extends ConsumerWidget {
  const _CategoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final categorySpending = ref.watch(categorySpendingProvider(selectedMonth));

    if (categorySpending.isEmpty) {
      return const Center(child: Text('No expenses this month'));
    }

    // Sort by amount
    final sorted = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sorted.fold<double>(0, (sum, e) => sum + e.value);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Pie Chart
          return SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: sorted.take(5).map((entry) {
                  final category = ref.watch(categoryByIdProvider(entry.key));
                  final percent =
                      (entry.value / total * 100).toStringAsFixed(1);
                  return PieChartSectionData(
                    color: category != null
                        ? Color(category.colorValue)
                        : Colors.grey,
                    value: entry.value,
                    title: '$percent%',
                    radius: 30,
                    titleStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }

        final entry = sorted[index - 1];
        final category = ref.watch(categoryByIdProvider(entry.key));
        final percent = entry.value / total * 100;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: category != null
                    ? Color(category.colorValue).withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category != null
                    ? IconData(category.iconCodePoint,
                        fontFamily: 'MaterialIcons')
                    : Icons.category,
                color:
                    category != null ? Color(category.colorValue) : Colors.grey,
              ),
            ),
            title: Text(category?.name ?? 'Unknown'),
            subtitle: Text('${percent.toStringAsFixed(1)}%'),
            trailing: Text(
              AppFormatters.formatCurrency(entry.value),
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TrendsTab extends ConsumerWidget {
  const _TrendsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up_rounded,
            size: 64,
            color: context.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Trend Analysis',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Compare income and expenses over time',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
