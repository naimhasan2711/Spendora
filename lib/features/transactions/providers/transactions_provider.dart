import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/transaction_model.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/utils/formatters.dart';
import '../../accounts/providers/accounts_provider.dart';

/// All transactions provider
final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<TransactionModel>>(
  (ref) => TransactionsNotifier(ref),
);

/// Transaction filter state
class TransactionFilter {
  final TransactionType? type;
  final String? categoryId;
  final String? accountId;
  final DateTimeRange? dateRange;

  const TransactionFilter({
    this.type,
    this.categoryId,
    this.accountId,
    this.dateRange,
  });

  TransactionFilter copyWith({
    TransactionType? type,
    String? categoryId,
    String? accountId,
    DateTimeRange? dateRange,
    bool clearType = false,
    bool clearCategory = false,
    bool clearAccount = false,
    bool clearDateRange = false,
  }) {
    return TransactionFilter(
      type: clearType ? null : (type ?? this.type),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      accountId: clearAccount ? null : (accountId ?? this.accountId),
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
    );
  }

  bool get hasFilters =>
      type != null ||
      categoryId != null ||
      accountId != null ||
      dateRange != null;

  TransactionFilter clear() => const TransactionFilter();
}

/// Transaction filter provider
final transactionFilterProvider =
    StateProvider<TransactionFilter>((ref) => const TransactionFilter());

/// Transactions for a specific month
final monthlyTransactionsProvider =
    Provider.family<List<TransactionModel>, DateTime>(
  (ref, month) {
    final transactions = ref.watch(transactionsProvider);
    final startOfMonth = DateHelpers.startOfMonth(month);
    final endOfMonth = DateHelpers.endOfMonth(month);

    return transactions.where((t) {
      return t.dateTime
              .isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
          t.dateTime.isBefore(endOfMonth.add(const Duration(seconds: 1)));
    }).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  },
);

/// Recent transactions provider
final recentTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final sorted = List<TransactionModel>.from(transactions)
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  return sorted.take(10).toList();
});

/// Monthly summary provider
final monthlySummaryProvider =
    Provider.family<MonthlySummary, DateTime>((ref, month) {
  final transactions = ref.watch(monthlyTransactionsProvider(month));

  double income = 0;
  double expense = 0;

  for (final transaction in transactions) {
    if (transaction.type == TransactionType.income) {
      income += transaction.amount;
    } else if (transaction.type == TransactionType.expense) {
      expense += transaction.amount;
    }
  }

  return MonthlySummary(
    income: income,
    expense: expense,
    balance: income - expense,
    savingsRate:
        income > 0 ? ((income - expense) / income * 100).clamp(0, 100) : 0,
    transactionCount: transactions.length,
  );
});

/// Daily transactions grouped
final dailyGroupedTransactionsProvider =
    Provider.family<Map<DateTime, List<TransactionModel>>, DateTime>(
  (ref, month) {
    final transactions = ref.watch(monthlyTransactionsProvider(month));
    final grouped = <DateTime, List<TransactionModel>>{};

    for (final transaction in transactions) {
      final date = DateHelpers.startOfDay(transaction.dateTime);
      if (grouped.containsKey(date)) {
        grouped[date]!.add(transaction);
      } else {
        grouped[date] = [transaction];
      }
    }

    return grouped;
  },
);

/// Category spending provider
final categorySpendingProvider =
    Provider.family<Map<String, double>, DateTime>((ref, month) {
  final transactions = ref.watch(monthlyTransactionsProvider(month));
  final spending = <String, double>{};

  for (final transaction in transactions) {
    if (transaction.type == TransactionType.expense) {
      spending[transaction.categoryId] =
          (spending[transaction.categoryId] ?? 0) + transaction.amount;
    }
  }

  return spending;
});

/// Filtered transactions for a specific month
final filteredMonthlyTransactionsProvider =
    Provider.family<List<TransactionModel>, DateTime>(
  (ref, month) {
    final transactions = ref.watch(monthlyTransactionsProvider(month));
    final filter = ref.watch(transactionFilterProvider);

    if (!filter.hasFilters) {
      return transactions;
    }

    return transactions.where((t) {
      // Type filter
      if (filter.type != null && t.type != filter.type) return false;

      // Category filter
      if (filter.categoryId != null && t.categoryId != filter.categoryId)
        return false;

      // Account filter
      if (filter.accountId != null && t.accountId != filter.accountId)
        return false;

      // Date range filter
      if (filter.dateRange != null) {
        if (t.dateTime.isBefore(filter.dateRange!.start)) return false;
        if (t.dateTime
            .isAfter(filter.dateRange!.end.add(const Duration(days: 1))))
          return false;
      }

      return true;
    }).toList();
  },
);

/// Filtered daily grouped transactions
final filteredDailyGroupedTransactionsProvider =
    Provider.family<Map<DateTime, List<TransactionModel>>, DateTime>(
  (ref, month) {
    final transactions = ref.watch(filteredMonthlyTransactionsProvider(month));
    final grouped = <DateTime, List<TransactionModel>>{};

    for (final transaction in transactions) {
      final date = DateHelpers.startOfDay(transaction.dateTime);
      if (grouped.containsKey(date)) {
        grouped[date]!.add(transaction);
      } else {
        grouped[date] = [transaction];
      }
    }

    return grouped;
  },
);

/// Transactions Notifier
class TransactionsNotifier extends StateNotifier<List<TransactionModel>> {
  final Ref _ref;

  TransactionsNotifier(this._ref) : super([]) {
    _loadTransactions();
  }

  final _hiveService = HiveService.instance;

  /// Load all transactions from Hive
  void _loadTransactions() {
    state = _hiveService.transactionsBox.values.toList();
  }

  /// Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    await _hiveService.transactionsBox.put(transaction.id, transaction);

    // Update account balance
    await _updateAccountBalance(transaction);

    state = [...state, transaction];
  }

  /// Update an existing transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    // Get the old transaction to reverse its effect
    final oldTransaction = _hiveService.transactionsBox.get(transaction.id);
    if (oldTransaction != null) {
      await _reverseAccountBalance(oldTransaction);
    }

    await _hiveService.transactionsBox.put(transaction.id, transaction);

    // Apply new transaction effect
    await _updateAccountBalance(transaction);

    state = state.map((t) => t.id == transaction.id ? transaction : t).toList();
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String id) async {
    final transaction = _hiveService.transactionsBox.get(id);
    if (transaction != null) {
      await _reverseAccountBalance(transaction);
      await _hiveService.transactionsBox.delete(id);
    }

    state = state.where((t) => t.id != id).toList();
  }

  /// Get transaction by ID
  TransactionModel? getTransaction(String id) {
    return _hiveService.transactionsBox.get(id);
  }

  /// Search transactions
  List<TransactionModel> searchTransactions({
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? accountId,
    TransactionType? type,
    List<String>? tags,
    double? minAmount,
    double? maxAmount,
  }) {
    return state.where((t) {
      // Query search in notes
      if (query != null && query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        final matchesNotes =
            t.notes?.toLowerCase().contains(lowerQuery) ?? false;
        final matchesTags =
            t.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
        if (!matchesNotes && !matchesTags) return false;
      }

      // Date range filter
      if (startDate != null && t.dateTime.isBefore(startDate)) return false;
      if (endDate != null && t.dateTime.isAfter(endDate)) return false;

      // Category filter
      if (categoryId != null && t.categoryId != categoryId) return false;

      // Account filter
      if (accountId != null && t.accountId != accountId) return false;

      // Type filter
      if (type != null && t.type != type) return false;

      // Tags filter
      if (tags != null && tags.isNotEmpty) {
        if (!t.tags.any((tag) => tags.contains(tag))) return false;
      }

      // Amount range filter
      if (minAmount != null && t.amount < minAmount) return false;
      if (maxAmount != null && t.amount > maxAmount) return false;

      return true;
    }).toList();
  }

  /// Update account balance based on transaction
  Future<void> _updateAccountBalance(TransactionModel transaction) async {
    final account = _hiveService.accountsBox.get(transaction.accountId);
    if (account == null) return;

    double newBalance = account.balance;

    switch (transaction.type) {
      case TransactionType.income:
        newBalance += transaction.amount;
        break;
      case TransactionType.expense:
        newBalance -= transaction.amount;
        break;
      case TransactionType.transfer:
        newBalance -= transaction.amount;
        // Add to destination account
        if (transaction.toAccountId != null) {
          final toAccount =
              _hiveService.accountsBox.get(transaction.toAccountId);
          if (toAccount != null) {
            await _hiveService.accountsBox.put(
              toAccount.id,
              toAccount.copyWith(
                  balance: toAccount.balance + transaction.amount),
            );
          }
        }
        break;
    }

    await _hiveService.accountsBox.put(
      account.id,
      account.copyWith(balance: newBalance),
    );

    // Refresh accounts provider to update total balance
    _ref.read(accountsProvider.notifier).refresh();
  }

  /// Reverse account balance (for delete/update)
  Future<void> _reverseAccountBalance(TransactionModel transaction) async {
    final account = _hiveService.accountsBox.get(transaction.accountId);
    if (account == null) return;

    double newBalance = account.balance;

    switch (transaction.type) {
      case TransactionType.income:
        newBalance -= transaction.amount;
        break;
      case TransactionType.expense:
        newBalance += transaction.amount;
        break;
      case TransactionType.transfer:
        newBalance += transaction.amount;
        if (transaction.toAccountId != null) {
          final toAccount =
              _hiveService.accountsBox.get(transaction.toAccountId);
          if (toAccount != null) {
            await _hiveService.accountsBox.put(
              toAccount.id,
              toAccount.copyWith(
                  balance: toAccount.balance - transaction.amount),
            );
          }
        }
        break;
    }

    await _hiveService.accountsBox.put(
      account.id,
      account.copyWith(balance: newBalance),
    );

    // Refresh accounts provider to update total balance
    _ref.read(accountsProvider.notifier).refresh();
  }

  /// Refresh transactions from Hive
  void refresh() {
    _loadTransactions();
  }
}

/// Monthly Summary Model
class MonthlySummary {
  final double income;
  final double expense;
  final double balance;
  final double savingsRate;
  final int transactionCount;

  const MonthlySummary({
    required this.income,
    required this.expense,
    required this.balance,
    required this.savingsRate,
    required this.transactionCount,
  });
}
