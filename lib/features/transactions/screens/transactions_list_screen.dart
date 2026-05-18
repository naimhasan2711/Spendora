import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../providers/transactions_provider.dart';
import '../../categories/providers/categories_provider.dart';
import '../../accounts/providers/accounts_provider.dart';
import '../../home/screens/dashboard_screen.dart';

/// Transactions List Screen (Tab in Main Screen)
class TransactionsListScreen extends ConsumerWidget {
  const TransactionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final filter = ref.watch(transactionFilterProvider);
    final groupedTransactions =
        ref.watch(filteredDailyGroupedTransactionsProvider(selectedMonth));

    // Sort dates in descending order
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push(AppRoutes.search),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () => _showFilterSheet(context, ref),
              ),
              if (filter.hasFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: sortedDates.isEmpty
          ? _buildEmptyState(context, filter.hasFilters)
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final transactions = groupedTransactions[date]!;

                return _DaySection(
                  date: date,
                  transactions: transactions,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool hasFilters) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters
                  ? Icons.filter_alt_off_outlined
                  : Icons.receipt_long_outlined,
              size: 80,
              color: context.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters ? 'No Matching Transactions' : 'No Transactions',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your filters to see more transactions'
                  : 'Start tracking your expenses by adding your first transaction',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (!hasFilters)
              ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.addTransaction),
                icon: const Icon(Icons.add),
                label: const Text('Add Transaction'),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterSheet(),
    );
  }
}

/// Day Section with grouped transactions
class _DaySection extends ConsumerWidget {
  final DateTime date;
  final List<TransactionModel> transactions;

  const _DaySection({
    required this.date,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate day totals
    double income = 0;
    double expense = 0;

    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else if (t.type == TransactionType.expense) {
        expense += t.amount;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                AppFormatters.formatRelativeDate(date),
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppFormatters.formatDate(date),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const Spacer(),
              if (income > 0)
                Text(
                  '+${AppFormatters.formatCurrency(income)}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppTheme.income,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (income > 0 && expense > 0)
                Text(
                  '  ',
                  style: context.textTheme.bodySmall,
                ),
              if (expense > 0)
                Text(
                  '-${AppFormatters.formatCurrency(expense)}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppTheme.expense,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),

        // Transactions
        ...transactions.map(
          (transaction) => _TransactionItem(transaction: transaction),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

/// Individual Transaction Item with swipe actions
class _TransactionItem extends ConsumerWidget {
  final TransactionModel transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryByIdProvider(transaction.categoryId));
    final account = ref.watch(accountByIdProvider(transaction.accountId));

    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? AppTheme.expense : AppTheme.income;
    final sign = isExpense ? '-' : '+';

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _editTransaction(context),
            backgroundColor: AppTheme.info,
            foregroundColor: Colors.white,
            icon: Icons.edit_rounded,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) => _deleteTransaction(context, ref),
            backgroundColor: AppTheme.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Delete',
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/transaction/${transaction.id}'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category != null
                      ? Color(category.colorValue).withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  category != null
                      ? IconData(category.iconCodePoint,
                          fontFamily: 'MaterialIcons')
                      : Icons.category,
                  color: category != null
                      ? Color(category.colorValue)
                      : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category?.name ?? 'Unknown',
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          IconData(account?.iconCodePoint ?? 0xe850,
                              fontFamily: 'MaterialIcons'),
                          size: 12,
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          account?.name ?? '',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        if (transaction.notes != null &&
                            transaction.notes!.isNotEmpty) ...[
                          Text(
                            ' • ',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              transaction.notes!,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign${AppFormatters.formatCurrency(transaction.amount)}',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    AppFormatters.formatTime(transaction.dateTime),
                    style: context.textTheme.labelSmall?.copyWith(
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editTransaction(BuildContext context) {
    context.push('/edit-transaction/${transaction.id}');
  }

  Future<void> _deleteTransaction(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content:
            const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(transactionsProvider.notifier)
          .deleteTransaction(transaction.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaction deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // Re-add the transaction
              ref
                  .read(transactionsProvider.notifier)
                  .addTransaction(transaction);
            },
          ),
        ),
      );
    }
  }
}

/// Filter Sheet
class _FilterSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  TransactionType? _selectedType;
  String? _selectedCategoryId;
  String? _selectedAccountId;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    // Initialize with current filter state
    final currentFilter = ref.read(transactionFilterProvider);
    _selectedType = currentFilter.type;
    _selectedCategoryId = currentFilter.categoryId;
    _selectedAccountId = currentFilter.accountId;
    if (currentFilter.dateRange != null) {
      _dateRange = currentFilter.dateRange;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reserved for future filter functionality
    ref.watch(categoriesProvider);
    ref.watch(accountsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Transactions',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = null;
                        _selectedCategoryId = null;
                        _selectedAccountId = null;
                        _dateRange = null;
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Transaction Type
                  Text(
                    'Type',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        selected: _selectedType == null,
                        label: Text(
                          'All',
                          style: TextStyle(
                            color: _selectedType == null
                                ? Colors.white
                                : context.colorScheme.onSurface,
                            fontWeight: _selectedType == null
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        selectedColor: context.colorScheme.primary,
                        backgroundColor: context.isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                        onSelected: (selected) {
                          setState(() => _selectedType = null);
                        },
                      ),
                      ChoiceChip(
                        selected: _selectedType == TransactionType.expense,
                        label: Text(
                          'Expense',
                          style: TextStyle(
                            color: _selectedType == TransactionType.expense
                                ? Colors.white
                                : context.colorScheme.onSurface,
                            fontWeight: _selectedType == TransactionType.expense
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        selectedColor: context.colorScheme.primary,
                        backgroundColor: context.isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                        onSelected: (selected) {
                          setState(() => _selectedType =
                              selected ? TransactionType.expense : null);
                        },
                      ),
                      ChoiceChip(
                        selected: _selectedType == TransactionType.income,
                        label: Text(
                          'Income',
                          style: TextStyle(
                            color: _selectedType == TransactionType.income
                                ? Colors.white
                                : context.colorScheme.onSurface,
                            fontWeight: _selectedType == TransactionType.income
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        selectedColor: context.colorScheme.primary,
                        backgroundColor: context.isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                        onSelected: (selected) {
                          setState(() => _selectedType =
                              selected ? TransactionType.income : null);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Date Range
                  Text(
                    'Date Range',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (range != null) {
                        setState(() => _dateRange = DateTimeRange(
                              start: range.start,
                              end: range.end,
                            ));
                      }
                    },
                    icon: const Icon(Icons.date_range),
                    label: Text(_dateRange == null
                        ? 'Select date range'
                        : '${AppFormatters.formatDate(_dateRange!.start)} - ${AppFormatters.formatDate(_dateRange!.end)}'),
                  ),
                  if (_dateRange != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: () => setState(() => _dateRange = null),
                        child: const Text('Clear date range'),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Apply filters to the provider
                    ref.read(transactionFilterProvider.notifier).state =
                        TransactionFilter(
                      type: _selectedType,
                      categoryId: _selectedCategoryId,
                      accountId: _selectedAccountId,
                      dateRange: _dateRange,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
