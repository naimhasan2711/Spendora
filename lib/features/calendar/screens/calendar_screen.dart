import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../categories/providers/categories_provider.dart';
import '../../accounts/providers/accounts_provider.dart';

/// Calendar View Screen
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);

    // Group transactions by date
    final Map<DateTime, List<TransactionModel>> transactionsByDate = {};
    for (final t in transactions) {
      final date = DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
      if (!transactionsByDate.containsKey(date)) {
        transactionsByDate[date] = [];
      }
      transactionsByDate[date]!.add(t);
    }

    // Get selected day transactions
    final selectedTransactions = _selectedDay != null
        ? transactionsByDate[DateTime(
              _selectedDay!.year,
              _selectedDay!.month,
              _selectedDay!.day,
            )] ??
            []
        : <TransactionModel>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          TableCalendar<TransactionModel>(
            firstDay: DateTime(2020),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: (day) {
              return transactionsByDate[
                      DateTime(day.year, day.month, day.day)] ??
                  [];
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: context.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: context.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              markerSize: 6,
              markerMargin: const EdgeInsets.symmetric(horizontal: 1),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                border: Border.all(color: context.colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),

          const Divider(height: 1),

          // Selected Day Summary
          if (_selectedDay != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    AppFormatters.formatDate(_selectedDay!),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _buildDaySummary(selectedTransactions),
                ],
              ),
            ),
          ],

          // Transactions List
          Expanded(
            child: selectedTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 48,
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No transactions on this day',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: selectedTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = selectedTransactions[index];
                      return _TransactionItem(transaction: transaction);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySummary(List<TransactionModel> transactions) {
    double income = 0;
    double expense = 0;

    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else if (t.type == TransactionType.expense) {
        expense += t.amount;
      }
    }

    return Row(
      children: [
        if (income > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.income.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '+${AppFormatters.formatCurrency(income)}',
              style: context.textTheme.labelMedium?.copyWith(
                color: AppTheme.income,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (income > 0 && expense > 0) const SizedBox(width: 8),
        if (expense > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.expense.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '-${AppFormatters.formatCurrency(expense)}',
              style: context.textTheme.labelMedium?.copyWith(
                color: AppTheme.expense,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _TransactionItem extends ConsumerWidget {
  final TransactionModel transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryByIdProvider(transaction.categoryId));
    final account = ref.watch(accountByIdProvider(transaction.accountId));

    final isExpense = transaction.type == TransactionType.expense;
    final sign = isExpense ? '-' : '+';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D6B5E).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/transaction/${transaction.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  category != null
                      ? IconData(category.iconCodePoint,
                          fontFamily: 'MaterialIcons')
                      : Icons.category,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category?.name ?? 'Unknown',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${account?.name ?? ''} • ${AppFormatters.formatTime(transaction.dateTime)}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$sign${AppFormatters.formatCurrency(transaction.amount)}',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isExpense
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF7FFF7F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
