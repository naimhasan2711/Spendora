import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/budgets_provider.dart';
import '../../categories/providers/categories_provider.dart';

/// Add/Edit Budget Screen
class AddBudgetScreen extends ConsumerStatefulWidget {
  final String? budgetId;

  const AddBudgetScreen({super.key, this.budgetId});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  BudgetPeriod _period = BudgetPeriod.monthly;
  String? _selectedCategoryId;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isNotificationEnabled = true;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.budgetId != null) {
      _loadBudget();
    }
  }

  void _loadBudget() {
    final budget =
        ref.read(budgetsProvider.notifier).getBudget(widget.budgetId!);
    if (budget != null) {
      _isEditing = true;
      _nameController.text = budget.name;
      _amountController.text = budget.amount.toString();
      _period = budget.period;
      _selectedCategoryId = budget.categoryId;
      _startDate = budget.startDate;
      _endDate = budget.endDate;
      _isNotificationEnabled = budget.notificationEnabled;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Budget' : 'Create Budget'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Budget Name
            Text(
              'Budget Name',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Monthly Food, Shopping',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Amount
            Text(
              'Budget Limit',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixText: '৳ ',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Invalid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Period
            Text(
              'Period',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BudgetPeriod.values.map((period) {
                final isSelected = _period == period;
                return ChoiceChip(
                  selected: isSelected,
                  label: Text(
                    _getPeriodLabel(period),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : context.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selectedColor: context.colorScheme.primary,
                  backgroundColor: context.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  onSelected: (selected) {
                    if (selected) setState(() => _period = period);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Category (Optional)
            Text(
              'Category (Optional)',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                hintText: 'All categories',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All categories'),
                ),
                ...categories.map((category) => DropdownMenuItem(
                      value: category.id,
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Color(category.colorValue)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              IconData(category.iconCodePoint,
                                  fontFamily: 'MaterialIcons'),
                              color: Color(category.colorValue),
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(category.name),
                        ],
                      ),
                    )),
              ],
              onChanged: (value) => setState(() => _selectedCategoryId = value),
            ),
            const SizedBox(height: 24),

            // Notifications
            SwitchListTile(
              value: _isNotificationEnabled,
              onChanged: (value) =>
                  setState(() => _isNotificationEnabled = value),
              title: const Text('Enable notifications'),
              subtitle:
                  const Text('Get notified when approaching budget limit'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveBudget,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(_isEditing ? 'Update' : 'Create Budget'),
        ),
      ),
    );
  }

  String _getPeriodLabel(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.daily:
        return 'Daily';
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.yearly:
        return 'Yearly';
      case BudgetPeriod.custom:
        return 'Custom';
    }
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final budget = BudgetModel(
        id: _isEditing ? widget.budgetId : null,
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text),
        spent: 0,
        period: _period,
        categoryId: _selectedCategoryId,
        startDate: _startDate,
        endDate: _endDate,
        notificationEnabled: _isNotificationEnabled,
      );

      if (_isEditing) {
        await ref.read(budgetsProvider.notifier).updateBudget(budget);
      } else {
        await ref.read(budgetsProvider.notifier).addBudget(budget);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Budget updated' : 'Budget created'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
