import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../providers/debts_provider.dart';
import '../../accounts/providers/accounts_provider.dart';

/// Add/Edit Debt Screen
class AddDebtScreen extends ConsumerStatefulWidget {
  final String? debtId;

  const AddDebtScreen({super.key, this.debtId});

  @override
  ConsumerState<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends ConsumerState<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _personController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DebtType _type = DebtType.borrowed;
  DateTime _date = DateTime.now();
  DateTime? _dueDate;
  String? _selectedAccountId;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.debtId != null) {
      _loadDebt();
    }
  }

  void _loadDebt() {
    final debt = ref.read(debtsProvider.notifier).getDebt(widget.debtId!);
    if (debt != null) {
      _isEditing = true;
      _personController.text = debt.personName;
      _amountController.text = debt.amount.toString();
      _descriptionController.text = debt.description ?? '';
      _type = debt.type;
      _date = debt.date;
      _dueDate = debt.dueDate;
      _selectedAccountId = debt.accountId;
    }
  }

  @override
  void dispose() {
    _personController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Debt' : 'Add Debt'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Debt Type
            Text(
              'Type',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TypeButton(
                    label: 'Borrowed',
                    subtitle: 'Money you owe',
                    isSelected: _type == DebtType.borrowed,
                    color: AppTheme.expense,
                    icon: Icons.trending_down_rounded,
                    onTap: () => setState(() => _type = DebtType.borrowed),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeButton(
                    label: 'Lent',
                    subtitle: 'Money owed to you',
                    isSelected: _type == DebtType.lent,
                    color: AppTheme.income,
                    icon: Icons.trending_up_rounded,
                    onTap: () => setState(() => _type = DebtType.lent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Person Name
            Text(
              'Person Name',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _personController,
              decoration: const InputDecoration(
                hintText: 'Who owes you / you owe',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Amount
            Text(
              'Amount',
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

            // Description
            Text(
              'Description (Optional)',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'What is it for?',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 24),

            // Date
            Text(
              'Date',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _date = date);
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(AppFormatters.formatDate(_date)),
            ),
            const SizedBox(height: 24),

            // Due Date
            Text(
              'Due Date (Optional)',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ??
                            DateTime.now().add(const Duration(days: 30)),
                        firstDate: _date,
                        lastDate:
                            DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (date != null) {
                        setState(() => _dueDate = date);
                      }
                    },
                    icon: const Icon(Icons.event),
                    label: Text(_dueDate == null
                        ? 'Select due date'
                        : AppFormatters.formatDate(_dueDate!)),
                  ),
                ),
                if (_dueDate != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() => _dueDate = null),
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // Account
            Text(
              'Account',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: _selectedAccountId,
              decoration: const InputDecoration(
                hintText: 'Select account',
              ),
              items: accounts.map((account) {
                return DropdownMenuItem(
                  value: account.id,
                  child: Row(
                    children: [
                      Icon(
                        IconData(account.iconCodePoint,
                            fontFamily: 'MaterialIcons'),
                        color: Color(account.colorValue),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(account.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedAccountId = value),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveDebt,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(_isEditing ? 'Update' : 'Add Debt'),
        ),
      ),
    );
  }

  Future<void> _saveDebt() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final debt = DebtModel(
        id: _isEditing ? widget.debtId : null,
        personName: _personController.text.trim(),
        amount: double.parse(_amountController.text),
        paidAmount: 0,
        type: _type,
        date: _date,
        dueDate: _dueDate,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        accountId: _selectedAccountId,
      );

      if (_isEditing) {
        await ref.read(debtsProvider.notifier).updateDebt(debt);
      } else {
        await ref.read(debtsProvider.notifier).addDebt(debt);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Debt updated' : 'Debt added'),
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

class _TypeButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : context.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : null),
            const SizedBox(height: 8),
            Text(
              label,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : null,
              ),
            ),
            Text(
              subtitle,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
