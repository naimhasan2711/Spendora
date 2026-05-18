import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../providers/debts_provider.dart';

/// Debts Screen
class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borrowedDebts = ref.watch(borrowedDebtsProvider);
    final lentDebts = ref.watch(lentDebtsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Debts'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Borrowed'),
              Tab(text: 'Lent'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DebtsList(
              debts: borrowedDebts,
              emptyMessage: 'No borrowed debts',
              emptyIcon: Icons.trending_down_rounded,
            ),
            _DebtsList(
              debts: lentDebts,
              emptyMessage: 'No lent money',
              emptyIcon: Icons.trending_up_rounded,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'debtsFAB',
          onPressed: () => context.push(AppRoutes.addDebt),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _DebtsList extends StatelessWidget {
  final List<DebtModel> debts;
  final String emptyMessage;
  final IconData emptyIcon;

  const _DebtsList({
    required this.debts,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (debts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: context.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: debts.length,
      itemBuilder: (context, index) {
        return _DebtCard(debt: debts[index]);
      },
    );
  }
}

class _DebtCard extends StatelessWidget {
  final DebtModel debt;

  const _DebtCard({required this.debt});

  @override
  Widget build(BuildContext context) {
    final remaining = debt.amount - debt.paidAmount;
    final progress = (debt.paidAmount / debt.amount).clamp(0.0, 1.0);
    final isPaid = remaining <= 0;
    final isBorrowed = debt.type == DebtType.borrowed;

    // Check if overdue
    bool isOverdue = false;
    if (debt.dueDate != null && !isPaid) {
      isOverdue = debt.dueDate!.isBefore(DateTime.now());
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showDebtDetails(context, debt);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        (isBorrowed ? AppTheme.expense : AppTheme.income)
                            .withValues(alpha: 0.15),
                    child: Text(
                      debt.personName.substring(0, 1).toUpperCase(),
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isBorrowed ? AppTheme.expense : AppTheme.income,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          debt.personName,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (debt.description != null)
                          Text(
                            debt.description!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isPaid)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Paid',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: AppTheme.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else if (isOverdue)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Overdue',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: AppTheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress
              LinearProgressIndicator(
                value: progress,
                backgroundColor:
                    context.colorScheme.outline.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(
                  isPaid
                      ? AppTheme.success
                      : (isBorrowed ? AppTheme.expense : AppTheme.income),
                ),
              ),
              const SizedBox(height: 12),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        AppFormatters.formatCurrency(debt.amount),
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Paid',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        AppFormatters.formatCurrency(debt.paidAmount),
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Remaining',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        AppFormatters.formatCurrency(remaining),
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isBorrowed ? AppTheme.expense : AppTheme.income,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Due date and actions
              if (debt.dueDate != null && !isPaid) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(
                      Icons.event_rounded,
                      size: 16,
                      color: isOverdue
                          ? AppTheme.error
                          : context.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${AppFormatters.formatDate(debt.dueDate!)}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: isOverdue
                            ? AppTheme.error
                            : context.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showPaymentDialog(context, debt),
                      child: const Text('Record Payment'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDebtDetails(BuildContext context, DebtModel debt) {
    // TODO: Navigate to debt details
  }

  void _showPaymentDialog(BuildContext context, DebtModel debt) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '৳ ',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                // TODO: Record payment
                Navigator.pop(context);
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }
}
