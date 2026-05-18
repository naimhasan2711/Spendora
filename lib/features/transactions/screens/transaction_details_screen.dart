import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../providers/transactions_provider.dart';
import '../../categories/providers/categories_provider.dart';
import '../../accounts/providers/accounts_provider.dart';

/// Transaction Details Screen
class TransactionDetailsScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailsScreen({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final transaction = transactions.cast<TransactionModel?>().firstWhere(
          (t) => t?.id == transactionId,
          orElse: () => null,
        );

    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Transaction not found')),
      );
    }

    final category = ref.watch(categoryByIdProvider(transaction.categoryId));
    final account = ref.watch(accountByIdProvider(transaction.accountId));

    final isExpense = transaction.type == TransactionType.expense;
    final sign = isExpense ? '-' : '+';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push('/edit-transaction/$transactionId'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteTransaction(context, ref, transaction),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Amount Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: isExpense
                    ? AppTheme.expenseGradient
                    : AppTheme.incomeGradient,
              ),
              child: Column(
                children: [
                  Text(
                    isExpense ? 'Expense' : 'Income',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$sign${AppFormatters.formatCurrency(transaction.amount)}',
                    style: context.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppFormatters.formatDateTime(transaction.dateTime),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Category
                  _buildDetailRow(
                    context,
                    icon: category != null
                        ? IconData(category.iconCodePoint,
                            fontFamily: 'MaterialIcons')
                        : Icons.category,
                    iconColor: category != null
                        ? Color(category.colorValue)
                        : Colors.grey,
                    label: 'Category',
                    value: category?.name ?? 'Unknown',
                  ),

                  const Divider(height: 32),

                  // Account
                  _buildDetailRow(
                    context,
                    icon: account != null
                        ? IconData(account.iconCodePoint,
                            fontFamily: 'MaterialIcons')
                        : Icons.account_balance_wallet,
                    iconColor: account != null
                        ? Color(account.colorValue)
                        : Colors.grey,
                    label: 'Account',
                    value: account?.name ?? 'Unknown',
                  ),

                  const Divider(height: 32),

                  // Payment Method
                  _buildDetailRow(
                    context,
                    icon: Icons.payment_rounded,
                    iconColor: context.colorScheme.primary,
                    label: 'Payment Method',
                    value: transaction.paymentMethod,
                  ),

                  if (transaction.notes != null &&
                      transaction.notes!.isNotEmpty) ...[
                    const Divider(height: 32),

                    // Notes
                    _buildDetailRow(
                      context,
                      icon: Icons.notes_rounded,
                      iconColor: context.colorScheme.primary,
                      label: 'Notes',
                      value: transaction.notes!,
                    ),
                  ],

                  if (transaction.tags.isNotEmpty) ...[
                    const Divider(height: 32),

                    // Tags
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_offer_rounded,
                              color: context.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Tags',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: transaction.tags
                              .map((tag) => Chip(label: Text('#$tag')))
                              .toList(),
                        ),
                      ],
                    ),
                  ],

                  if (transaction.recurrence != RecurrenceType.none) ...[
                    const Divider(height: 32),

                    // Recurrence
                    _buildDetailRow(
                      context,
                      icon: Icons.repeat_rounded,
                      iconColor: context.colorScheme.primary,
                      label: 'Recurring',
                      value: _getRecurrenceLabel(transaction.recurrence),
                    ),
                  ],

                  const Divider(height: 32),

                  // Created At
                  _buildDetailRow(
                    context,
                    icon: Icons.schedule_rounded,
                    iconColor:
                        context.colorScheme.onSurface.withValues(alpha: 0.5),
                    label: 'Created',
                    value: AppFormatters.formatDateTime(transaction.createdAt),
                  ),

                  if (transaction.updatedAt != transaction.createdAt) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      icon: Icons.update_rounded,
                      iconColor:
                          context.colorScheme.onSurface.withValues(alpha: 0.5),
                      label: 'Last Updated',
                      value:
                          AppFormatters.formatDateTime(transaction.updatedAt),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getRecurrenceLabel(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return 'No repeat';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
      case RecurrenceType.custom:
        return 'Custom';
    }
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    WidgetRef ref,
    TransactionModel transaction,
  ) async {
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
      if (context.mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transaction deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
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
}
