import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../categories/providers/categories_provider.dart';
import '../../accounts/providers/accounts_provider.dart';

/// Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered Transactions Provider
final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final transactions = ref.watch(transactionsProvider);
  final categories = ref.watch(categoriesProvider);

  if (query.isEmpty) return [];

  return transactions.where((t) {
    // Search by notes
    if (t.notes?.toLowerCase().contains(query) ?? false) return true;

    // Search by amount
    if (t.amount.toString().contains(query)) return true;

    // Search by category name
    final category = categories.cast<CategoryModel?>().firstWhere(
          (c) => c?.id == t.categoryId,
          orElse: () => null,
        );
    if (category?.name.toLowerCase().contains(query) ?? false) return true;

    // Search by tags
    if (t.tags.any((tag) => tag.toLowerCase().contains(query))) return true;

    // Search by payment method
    if (t.paymentMethod.toLowerCase().contains(query)) return true;

    return false;
  }).toList();
});

/// Search Screen
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(filteredTransactionsProvider);
    final recentSearches = ['Food', 'Shopping', 'Transport', 'Bills'];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search transactions...',
            border: InputBorder.none,
            filled: false,
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
      ),
      body: query.isEmpty
          ? _buildSuggestions(context, recentSearches)
          : _buildResults(context, results),
    );
  }

  Widget _buildSuggestions(BuildContext context, List<String> recent) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick Filters
        Text(
          'QUICK FILTERS',
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChip(
              label: 'This Week',
              icon: Icons.date_range,
              onTap: () => _applyFilter('this week'),
            ),
            _FilterChip(
              label: 'This Month',
              icon: Icons.calendar_month,
              onTap: () => _applyFilter('this month'),
            ),
            _FilterChip(
              label: 'Expenses Only',
              icon: Icons.arrow_upward,
              onTap: () => _applyFilter('expense'),
            ),
            _FilterChip(
              label: 'Income Only',
              icon: Icons.arrow_downward,
              onTap: () => _applyFilter('income'),
            ),
            _FilterChip(
              label: 'Large Amount',
              icon: Icons.trending_up,
              onTap: () => _applyFilter('large'),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Recent Searches
        if (recent.isNotEmpty) ...[
          Text(
            'RECENT SEARCHES',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...recent.map((search) => ListTile(
                leading: const Icon(Icons.history),
                title: Text(search),
                trailing: const Icon(Icons.north_west, size: 16),
                onTap: () {
                  _searchController.text = search;
                  ref.read(searchQueryProvider.notifier).state = search;
                },
              )),
        ],
      ],
    );
  }

  Widget _buildResults(BuildContext context, List<TransactionModel> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: context.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${results.length} result${results.length == 1 ? '' : 's'}',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return _SearchResultItem(transaction: results[index]);
            },
          ),
        ),
      ],
    );
  }

  void _applyFilter(String filter) {
    _searchController.text = filter;
    ref.read(searchQueryProvider.notifier).state = filter;
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _SearchResultItem extends ConsumerWidget {
  final TransactionModel transaction;

  const _SearchResultItem({required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryByIdProvider(transaction.categoryId));
    final account = ref.watch(accountByIdProvider(transaction.accountId));

    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? AppTheme.expense : AppTheme.income;
    final sign = isExpense ? '-' : '+';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push('/transaction/${transaction.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
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
                  color: category != null
                      ? Color(category.colorValue)
                      : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
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
                        Text(
                          account?.name ?? '',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          ' • ${AppFormatters.formatDate(transaction.dateTime)}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    if (transaction.notes != null &&
                        transaction.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          transaction.notes!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '$sign${AppFormatters.formatCurrency(transaction.amount)}',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
