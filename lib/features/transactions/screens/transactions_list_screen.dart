import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../providers/transactions_provider.dart';
import '../../categories/providers/categories_provider.dart';
import '../../accounts/providers/accounts_provider.dart';
import '../../home/screens/dashboard_screen.dart';

/// Tab filter state provider
final transactionTabProvider = StateProvider<int>((ref) => 0);

/// Transactions List Screen - Redesigned with animations
class TransactionsListScreen extends ConsumerWidget {
  const TransactionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final filter = ref.watch(transactionFilterProvider);
    final currentTab = ref.watch(transactionTabProvider);
    final groupedTransactions =
        ref.watch(filteredDailyGroupedTransactionsProvider(selectedMonth));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sort dates in descending order
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with title and synced profile
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),

          // Search Bar with animation
          SliverToBoxAdapter(
            child: AnimatedFadeSlide(
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push(AppRoutes.search),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF252538) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: context.colorScheme.onSurface
                                  .withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: context.colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Search transactions...',
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colorScheme.onSurface
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter Button
                    GestureDetector(
                      onTap: () => _showFilterSheet(context, ref),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: filter.hasFilters
                              ? context.colorScheme.primary
                              : (isDark ? const Color(0xFF252538) : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: filter.hasFilters
                              ? null
                              : Border.all(
                                  color: context.colorScheme.onSurface
                                      .withValues(alpha: 0.1),
                                ),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: filter.hasFilters
                              ? Colors.white
                              : context.colorScheme.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter Tabs
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterTab(
                      label: 'All',
                      isSelected: currentTab == 0,
                      onTap: () {
                        ref.read(transactionTabProvider.notifier).state = 0;
                        ref.read(transactionFilterProvider.notifier).state =
                            const TransactionFilter();
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterTab(
                      label: 'Transactions',
                      isSelected: currentTab == 1,
                      onTap: () {
                        ref.read(transactionTabProvider.notifier).state = 1;
                        ref.read(transactionFilterProvider.notifier).state =
                            const TransactionFilter();
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterTab(
                      label: 'Income',
                      isSelected: currentTab == 2,
                      onTap: () {
                        ref.read(transactionTabProvider.notifier).state = 2;
                        ref.read(transactionFilterProvider.notifier).state =
                            const TransactionFilter(
                                type: TransactionType.income);
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterTab(
                      label: 'Expenses',
                      isSelected: currentTab == 3,
                      onTap: () {
                        ref.read(transactionTabProvider.notifier).state = 3;
                        ref.read(transactionFilterProvider.notifier).state =
                            const TransactionFilter(
                                type: TransactionType.expense);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Transaction List
          if (sortedDates.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(context, filter.hasFilters),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final date = sortedDates[index];
                  final transactions = groupedTransactions[date]!;
                  return _DaySection(
                    date: date,
                    transactions: transactions,
                  );
                },
                childCount: sortedDates.length,
              ),
            ),

          // Bottom spacing for FAB
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
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
}

/// Filter Tab Widget
class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
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
              ? (isDark ? const Color(0xFF7C4DFF) : const Color(0xFF0D4A3E))
              : (isDark ? const Color(0xFF252538) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
        ),
        child: Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? Colors.white
                : context.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            AppFormatters.formatRelativeDate(date).toUpperCase(),
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 1.2,
            ),
          ),
        ),

        // Transaction Cards
        ...transactions.map(
          (transaction) => _TransactionCard(transaction: transaction),
        ),
      ],
    );
  }
}

/// Individual Transaction Card - Redesigned to match Figma
class _TransactionCard extends ConsumerWidget {
  final TransactionModel transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryByIdProvider(transaction.categoryId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense ? AppTheme.expense : AppTheme.income;
    final sign = isExpense ? '-' : '+';

    // Get category color or default
    final iconColor = category != null
        ? Color(category.colorValue)
        : (isExpense ? AppTheme.expense : AppTheme.income);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => _editTransaction(context),
              backgroundColor: AppTheme.info,
              foregroundColor: Colors.white,
              icon: Icons.edit_rounded,
              label: 'Edit',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (context) => _deleteTransaction(context, ref),
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              label: 'Delete',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => context.push('/transaction/${transaction.id}'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252538) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colorScheme.onSurface.withValues(alpha: 0.05),
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category != null
                        ? IconData(category.iconCodePoint,
                            fontFamily: 'MaterialIcons')
                        : (isExpense ? Icons.shopping_bag : Icons.attach_money),
                    color: iconColor,
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
                        transaction.notes?.isNotEmpty == true
                            ? transaction.notes!
                            : (category?.name ?? 'Transaction'),
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category?.name ?? 'Unknown'} • ${AppFormatters.formatTime(transaction.dateTime)}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Text(
                  '$sign${AppFormatters.formatCurrency(transaction.amount)}',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editTransaction(BuildContext context) {
    context.push('/edit-transaction/${transaction.id}');
  }

  void _deleteTransaction(BuildContext context, WidgetRef ref) async {
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
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(transactionsProvider.notifier).deleteTransaction(transaction.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
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
