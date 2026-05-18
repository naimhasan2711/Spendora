import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/account_model.dart';
import '../../../core/services/hive_service.dart';

/// All accounts provider
final accountsProvider =
    StateNotifierProvider<AccountsNotifier, List<AccountModel>>(
  (ref) => AccountsNotifier(),
);

/// Total balance provider (from all accounts included in total)
final totalBalanceProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider);
  return accounts
      .where((a) => !a.excludeFromTotal)
      .fold(0.0, (sum, account) => sum + account.balance);
});

/// Get account by ID provider
final accountByIdProvider = Provider.family<AccountModel?, String>((ref, id) {
  final accounts = ref.watch(accountsProvider);
  try {
    return accounts.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
});

/// Default account provider
final defaultAccountProvider = Provider<AccountModel?>((ref) {
  final accounts = ref.watch(accountsProvider);
  try {
    return accounts.firstWhere((a) => a.isDefault);
  } catch (_) {
    return accounts.isNotEmpty ? accounts.first : null;
  }
});

/// Accounts Notifier
class AccountsNotifier extends StateNotifier<List<AccountModel>> {
  AccountsNotifier() : super([]) {
    _loadAccounts();
  }

  final _hiveService = HiveService.instance;

  /// Load accounts from Hive
  void _loadAccounts() {
    state = _hiveService.accountsBox.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Add a new account
  Future<void> addAccount(AccountModel account) async {
    await _hiveService.accountsBox.put(account.id, account);
    state = [...state, account]..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Update an existing account
  Future<void> updateAccount(AccountModel account) async {
    await _hiveService.accountsBox.put(account.id, account);
    state = state.map((a) => a.id == account.id ? account : a).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Delete an account
  Future<void> deleteAccount(String id) async {
    await _hiveService.accountsBox.delete(id);
    state = state.where((a) => a.id != id).toList();
  }

  /// Get account by ID
  AccountModel? getAccount(String id) {
    return _hiveService.accountsBox.get(id);
  }

  /// Set default account
  Future<void> setDefaultAccount(String id) async {
    final updatedAccounts = <AccountModel>[];
    for (final account in state) {
      final updated = account.copyWith(isDefault: account.id == id);
      await _hiveService.accountsBox.put(account.id, updated);
      updatedAccounts.add(updated);
    }
    state = updatedAccounts;
  }

  /// Update account balance
  Future<void> updateBalance(String id, double amount,
      {bool add = true}) async {
    final account = _hiveService.accountsBox.get(id);
    if (account != null) {
      final newBalance =
          add ? account.balance + amount : account.balance - amount;
      final updated = account.copyWith(balance: newBalance);
      await _hiveService.accountsBox.put(id, updated);
      state = state.map((a) => a.id == id ? updated : a).toList();
    }
  }

  /// Transfer between accounts
  Future<void> transfer(String fromId, String toId, double amount) async {
    await updateBalance(fromId, amount, add: false);
    await updateBalance(toId, amount, add: true);
  }

  /// Reorder accounts
  Future<void> reorderAccounts(List<AccountModel> accounts) async {
    for (int i = 0; i < accounts.length; i++) {
      final updated = accounts[i].copyWith(order: i);
      await _hiveService.accountsBox.put(updated.id, updated);
    }
    _loadAccounts();
  }

  /// Refresh accounts from Hive
  void refresh() {
    _loadAccounts();
  }
}
