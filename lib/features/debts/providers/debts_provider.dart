import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/debt_model.dart';
import '../../../core/services/hive_service.dart';

/// All debts provider
final debtsProvider = StateNotifierProvider<DebtsNotifier, List<DebtModel>>(
  (ref) => DebtsNotifier(),
);

/// Active debts provider (not settled)
final activeDebtsProvider = Provider<List<DebtModel>>((ref) {
  final debts = ref.watch(debtsProvider);
  return debts.where((d) => !d.isSettled).toList();
});

/// Settled debts provider
final settledDebtsProvider = Provider<List<DebtModel>>((ref) {
  final debts = ref.watch(debtsProvider);
  return debts.where((d) => d.isSettled).toList();
});

/// Money I owe (borrowed) provider
final borrowedDebtsProvider = Provider<List<DebtModel>>((ref) {
  final debts = ref.watch(activeDebtsProvider);
  return debts.where((d) => d.type == DebtType.borrowed).toList();
});

/// Money owed to me (lent) provider
final lentDebtsProvider = Provider<List<DebtModel>>((ref) {
  final debts = ref.watch(activeDebtsProvider);
  return debts.where((d) => d.type == DebtType.lent).toList();
});

/// Total borrowed amount provider
final totalBorrowedProvider = Provider<double>((ref) {
  final debts = ref.watch(borrowedDebtsProvider);
  return debts.fold(0.0, (sum, d) => sum + d.remaining);
});

/// Total lent amount provider
final totalLentProvider = Provider<double>((ref) {
  final debts = ref.watch(lentDebtsProvider);
  return debts.fold(0.0, (sum, d) => sum + d.remaining);
});

/// Overdue debts provider
final overdueDebtsProvider = Provider<List<DebtModel>>((ref) {
  final debts = ref.watch(activeDebtsProvider);
  return debts.where((d) => d.isOverdue).toList();
});

/// Debts Notifier
class DebtsNotifier extends StateNotifier<List<DebtModel>> {
  DebtsNotifier() : super([]) {
    _loadDebts();
  }

  final _hiveService = HiveService.instance;

  /// Load debts from Hive
  void _loadDebts() {
    state = _hiveService.debtsBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Add a new debt
  Future<void> addDebt(DebtModel debt) async {
    await _hiveService.debtsBox.put(debt.id, debt);
    state = [...state, debt]..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Update an existing debt
  Future<void> updateDebt(DebtModel debt) async {
    await _hiveService.debtsBox.put(debt.id, debt);
    state = state.map((d) => d.id == debt.id ? debt : d).toList();
  }

  /// Delete a debt
  Future<void> deleteDebt(String id) async {
    await _hiveService.debtsBox.delete(id);
    state = state.where((d) => d.id != id).toList();
  }

  /// Get debt by ID
  DebtModel? getDebt(String id) {
    return _hiveService.debtsBox.get(id);
  }

  /// Add payment to debt
  Future<void> addPayment(String id, DebtPaymentModel payment) async {
    final debt = _hiveService.debtsBox.get(id);
    if (debt != null) {
      final newPaidAmount = debt.paidAmount + payment.amount;
      final isSettled = newPaidAmount >= debt.amount;

      final updated = debt.copyWith(
        payments: [...debt.payments, payment],
        paidAmount: newPaidAmount,
        isSettled: isSettled,
      );

      await _hiveService.debtsBox.put(id, updated);
      state = state.map((d) => d.id == id ? updated : d).toList();
    }
  }

  /// Remove payment from debt
  Future<void> removePayment(String debtId, String paymentId) async {
    final debt = _hiveService.debtsBox.get(debtId);
    if (debt != null) {
      final payment = debt.payments.firstWhere((p) => p.id == paymentId);
      final newPaidAmount = debt.paidAmount - payment.amount;

      final updated = debt.copyWith(
        payments: debt.payments.where((p) => p.id != paymentId).toList(),
        paidAmount: newPaidAmount.clamp(0.0, double.infinity),
        isSettled: false,
      );

      await _hiveService.debtsBox.put(debtId, updated);
      state = state.map((d) => d.id == debtId ? updated : d).toList();
    }
  }

  /// Mark debt as settled
  Future<void> markSettled(String id) async {
    final debt = _hiveService.debtsBox.get(id);
    if (debt != null) {
      final updated = debt.copyWith(
        isSettled: true,
        paidAmount: debt.amount,
      );
      await _hiveService.debtsBox.put(id, updated);
      state = state.map((d) => d.id == id ? updated : d).toList();
    }
  }

  /// Reopen a settled debt
  Future<void> reopenDebt(String id) async {
    final debt = _hiveService.debtsBox.get(id);
    if (debt != null) {
      final totalPaid = debt.payments.fold(0.0, (sum, p) => sum + p.amount);
      final updated = debt.copyWith(
        isSettled: false,
        paidAmount: totalPaid,
      );
      await _hiveService.debtsBox.put(id, updated);
      state = state.map((d) => d.id == id ? updated : d).toList();
    }
  }

  /// Refresh debts from Hive
  void refresh() {
    _loadDebts();
  }
}
