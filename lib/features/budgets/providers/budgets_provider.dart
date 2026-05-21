import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/budget_model.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/utils/formatters.dart';
import '../../transactions/providers/transactions_provider.dart';

/// All budgets provider
final budgetsProvider =
    StateNotifierProvider<BudgetsNotifier, List<BudgetModel>>(
  (ref) => BudgetsNotifier(ref),
);

/// Active budgets provider
final activeBudgetsProvider = Provider<List<BudgetModel>>((ref) {
  final budgets = ref.watch(budgetsProvider);
  return budgets.where((b) => b.isActive && b.isCurrent).toList();
});

/// Monthly budgets provider
final monthlyBudgetsProvider =
    Provider.family<List<BudgetModel>, DateTime>((ref, month) {
  final budgets = ref.watch(budgetsProvider);
  final startOfMonth = DateHelpers.startOfMonth(month);
  final endOfMonth = DateHelpers.endOfMonth(month);

  return budgets.where((b) {
    final endDate = b.endDate;
    if (endDate == null) return b.startDate.isBefore(endOfMonth);
    return b.startDate.isBefore(endOfMonth) && endDate.isAfter(startOfMonth);
  }).toList();
});

/// Overall budget provider
final overallBudgetProvider = Provider<BudgetModel?>((ref) {
  final budgets = ref.watch(activeBudgetsProvider);
  try {
    return budgets.firstWhere((b) => b.categoryId == null);
  } catch (_) {
    return null;
  }
});

/// Category budget provider
final categoryBudgetProvider =
    Provider.family<BudgetModel?, String>((ref, categoryId) {
  final budgets = ref.watch(activeBudgetsProvider);
  try {
    return budgets.firstWhere((b) => b.categoryId == categoryId);
  } catch (_) {
    return null;
  }
});

/// Budgets Notifier
class BudgetsNotifier extends StateNotifier<List<BudgetModel>> {
  BudgetsNotifier(this._ref) : super([]) {
    _loadBudgets();
    // Listen for transaction changes to recalculate budgets
    _ref.listen<List<TransactionModel>>(transactionsProvider, (_, __) {
      _updateBudgetSpending();
    });
  }

  final Ref _ref;
  final _hiveService = HiveService.instance;

  /// Load budgets from Hive
  void _loadBudgets() {
    state = _hiveService.budgetsBox.values.toList();
    _updateBudgetSpending();
  }

  /// Update spent amounts based on transactions
  void _updateBudgetSpending() {
    for (final budget in state) {
      if (budget.isActive && budget.isCurrent) {
        _calculateBudgetSpending(budget);
      }
    }
  }

  /// Calculate spending for a budget
  Future<void> _calculateBudgetSpending(BudgetModel budget) async {
    final transactions = _ref.read(transactionsProvider);

    double spent = 0;
    for (final transaction in transactions) {
      // Check if transaction is within budget period
      final budgetEndDate = budget.endDate;
      final isWithinPeriod = budgetEndDate == null
          ? transaction.dateTime.isAfter(budget.startDate)
          : transaction.dateTime.isAfter(budget.startDate) &&
              transaction.dateTime.isBefore(budgetEndDate);
      if (isWithinPeriod) {
        // Check if it's an expense and matches category (if category budget)
        if (transaction.type == TransactionType.expense) {
          if (budget.categoryId == null ||
              transaction.categoryId == budget.categoryId) {
            spent += transaction.amount;
          }
        }
      }
    }

    if (spent != budget.spent) {
      final updated = budget.copyWith(spent: spent);
      await _hiveService.budgetsBox.put(budget.id, updated);
      state = state.map((b) => b.id == budget.id ? updated : b).toList();
    }
  }

  /// Add a new budget
  Future<void> addBudget(BudgetModel budget) async {
    await _hiveService.budgetsBox.put(budget.id, budget);
    state = [...state, budget];
    _calculateBudgetSpending(budget);
  }

  /// Update an existing budget
  Future<void> updateBudget(BudgetModel budget) async {
    await _hiveService.budgetsBox.put(budget.id, budget);
    state = state.map((b) => b.id == budget.id ? budget : b).toList();
    _calculateBudgetSpending(budget);
  }

  /// Delete a budget
  Future<void> deleteBudget(String id) async {
    await _hiveService.budgetsBox.delete(id);
    state = state.where((b) => b.id != id).toList();
  }

  /// Get budget by ID
  BudgetModel? getBudget(String id) {
    return _hiveService.budgetsBox.get(id);
  }

  /// Toggle budget active status
  Future<void> toggleActive(String id) async {
    final budget = _hiveService.budgetsBox.get(id);
    if (budget != null) {
      final updated = budget.copyWith(isActive: !budget.isActive);
      await _hiveService.budgetsBox.put(id, updated);
      state = state.map((b) => b.id == id ? updated : b).toList();
    }
  }

  /// Create monthly budget from current month
  Future<BudgetModel> createMonthlyBudget({
    required String name,
    required double amount,
    String? categoryId,
    DateTime? startDate,
  }) async {
    final now = startDate ?? DateTime.now();
    final budget = BudgetModel(
      name: name,
      amount: amount,
      categoryId: categoryId,
      period: BudgetPeriod.monthly,
      startDate: DateHelpers.startOfMonth(now),
      endDate: DateHelpers.endOfMonth(now),
    );

    await addBudget(budget);
    return budget;
  }

  /// Recalculate all budget spending
  Future<void> recalculateAllBudgets() async {
    for (final budget in state) {
      await _calculateBudgetSpending(budget);
    }
  }

  /// Refresh budgets from Hive
  void refresh() {
    _loadBudgets();
  }
}
