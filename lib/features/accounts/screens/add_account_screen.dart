import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/accounts_provider.dart';

/// Add/Edit Account Screen
class AddAccountScreen extends ConsumerStatefulWidget {
  final String? accountId;

  const AddAccountScreen({super.key, this.accountId});

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');

  AccountType _type = AccountType.cash;
  int _selectedIconCodePoint = 0xe850; // account_balance_wallet
  Color _selectedColor = const Color(0xFF6C63FF);
  bool _isDefault = false;
  bool _excludeFromTotal = false;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.accountId != null) {
      _loadAccount();
    }
  }

  void _loadAccount() {
    final account =
        ref.read(accountsProvider.notifier).getAccount(widget.accountId!);
    if (account != null) {
      _isEditing = true;
      _nameController.text = account.name;
      _balanceController.text = account.balance.toString();
      _type = account.type;
      _selectedIconCodePoint = account.iconCodePoint;
      _selectedColor = Color(account.colorValue);
      _isDefault = account.isDefault;
      _excludeFromTotal = account.excludeFromTotal;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Account' : 'Add Account'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _selectedColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  IconData(_selectedIconCodePoint, fontFamily: 'MaterialIcons'),
                  color: _selectedColor,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Account Type
            Text(
              'Account Type',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AccountType.values.map((type) {
                final isSelected = _type == type;
                return ChoiceChip(
                  selected: isSelected,
                  label: Text(
                    _getAccountTypeLabel(type),
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
                    if (selected) setState(() => _type = type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Name
            Text(
              'Name',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Account name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Balance
            Text(
              'Initial Balance',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _balanceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixText: '৳ ',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter balance';
                }
                if (double.tryParse(value) == null) {
                  return 'Invalid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Color Picker
            Text(
              'Color',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ColorPicker(
              color: _selectedColor,
              onColorChanged: (color) => setState(() => _selectedColor = color),
              pickersEnabled: const {
                ColorPickerType.primary: true,
                ColorPickerType.accent: true,
              },
              width: 40,
              height: 40,
              borderRadius: 20,
              spacing: 8,
              runSpacing: 8,
            ),
            const SizedBox(height: 24),

            // Icon Picker
            Text(
              'Icon',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildIconGrid(),
            const SizedBox(height: 24),

            // Options
            SwitchListTile(
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value),
              title: const Text('Set as default'),
              subtitle: const Text(
                  'Use this account by default for new transactions'),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              value: _excludeFromTotal,
              onChanged: (value) => setState(() => _excludeFromTotal = value),
              title: const Text('Exclude from total'),
              subtitle: const Text('Don\'t include this balance in total'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveAccount,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(_isEditing ? 'Update' : 'Create Account'),
        ),
      ),
    );
  }

  Widget _buildIconGrid() {
    final icons = [
      0xe850, // account_balance_wallet
      0xe84f, // account_balance
      0xe896, // credit_card
      0xe8e5, // savings
      0xe263, // trending_up
      0xe227, // smartphone
      0xe88a, // home
      0xe1d5, // directions_car
      0xe56c, // restaurant
      0xe59d, // shopping_bag
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: icons.map((codePoint) {
        final isSelected = _selectedIconCodePoint == codePoint;
        return InkWell(
          onTap: () => setState(() => _selectedIconCodePoint = codePoint),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? _selectedColor.withValues(alpha: 0.15)
                  : context.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? _selectedColor
                    : context.colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(
              IconData(codePoint, fontFamily: 'MaterialIcons'),
              color:
                  isSelected ? _selectedColor : context.colorScheme.onSurface,
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final account = AccountModel(
        id: _isEditing ? widget.accountId : null,
        name: _nameController.text.trim(),
        type: _type,
        balance: double.parse(_balanceController.text),
        iconCodePoint: _selectedIconCodePoint,
        colorValue: _selectedColor.value,
        isDefault: _isDefault,
        excludeFromTotal: _excludeFromTotal,
      );

      if (_isEditing) {
        await ref.read(accountsProvider.notifier).updateAccount(account);
      } else {
        await ref.read(accountsProvider.notifier).addAccount(account);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Account updated' : 'Account created'),
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

  String _getAccountTypeLabel(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return 'Cash';
      case AccountType.bank:
        return 'Bank';
      case AccountType.creditCard:
        return 'Credit Card';
      case AccountType.savings:
        return 'Savings';
      case AccountType.investment:
        return 'Investment';
      case AccountType.wallet:
        return 'Wallet';
      case AccountType.other:
        return 'Other';
    }
  }
}
