import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/goal_model.dart';
import '../../../core/services/hive_service.dart';

/// All goals provider
final goalsProvider = StateNotifierProvider<GoalsNotifier, List<GoalModel>>(
  (ref) => GoalsNotifier(),
);

/// Active goals provider (not completed)
final activeGoalsProvider = Provider<List<GoalModel>>((ref) {
  final goals = ref.watch(goalsProvider);
  return goals.where((g) => !g.isCompleted).toList();
});

/// Completed goals provider
final completedGoalsProvider = Provider<List<GoalModel>>((ref) {
  final goals = ref.watch(goalsProvider);
  return goals.where((g) => g.isCompleted).toList();
});

/// Total savings progress provider
final totalSavingsProgressProvider = Provider<double>((ref) {
  final goals = ref.watch(activeGoalsProvider);
  if (goals.isEmpty) return 0;

  double totalTarget = 0;
  double totalSaved = 0;

  for (final goal in goals) {
    totalTarget += goal.targetAmount;
    totalSaved += goal.savedAmount;
  }

  return totalTarget > 0 ? (totalSaved / totalTarget * 100) : 0;
});

/// Goals Notifier
class GoalsNotifier extends StateNotifier<List<GoalModel>> {
  GoalsNotifier() : super([]) {
    _loadGoals();
  }

  final _hiveService = HiveService.instance;

  /// Load goals from Hive
  void _loadGoals() {
    state = _hiveService.goalsBox.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Add a new goal
  Future<void> addGoal(GoalModel goal) async {
    await _hiveService.goalsBox.put(goal.id, goal);
    state = [...state, goal]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Update an existing goal
  Future<void> updateGoal(GoalModel goal) async {
    await _hiveService.goalsBox.put(goal.id, goal);
    state = state.map((g) => g.id == goal.id ? goal : g).toList();
  }

  /// Delete a goal
  Future<void> deleteGoal(String id) async {
    await _hiveService.goalsBox.delete(id);
    state = state.where((g) => g.id != id).toList();
  }

  /// Get goal by ID
  GoalModel? getGoal(String id) {
    return _hiveService.goalsBox.get(id);
  }

  /// Add to savings
  Future<void> addSavings(String id, double amount) async {
    final goal = _hiveService.goalsBox.get(id);
    if (goal != null) {
      final newSavedAmount = goal.savedAmount + amount;
      final isCompleted = newSavedAmount >= goal.targetAmount;

      final updated = goal.copyWith(
        savedAmount: newSavedAmount,
        isCompleted: isCompleted,
      );

      await _hiveService.goalsBox.put(id, updated);
      state = state.map((g) => g.id == id ? updated : g).toList();
    }
  }

  /// Withdraw from savings
  Future<void> withdrawSavings(String id, double amount) async {
    final goal = _hiveService.goalsBox.get(id);
    if (goal != null) {
      final newSavedAmount =
          (goal.savedAmount - amount).clamp(0.0, double.infinity);

      final updated = goal.copyWith(
        savedAmount: newSavedAmount,
        isCompleted: false, // Un-complete if withdrawing
      );

      await _hiveService.goalsBox.put(id, updated);
      state = state.map((g) => g.id == id ? updated : g).toList();
    }
  }

  /// Mark goal as completed
  Future<void> markCompleted(String id) async {
    final goal = _hiveService.goalsBox.get(id);
    if (goal != null) {
      final updated = goal.copyWith(isCompleted: true);
      await _hiveService.goalsBox.put(id, updated);
      state = state.map((g) => g.id == id ? updated : g).toList();
    }
  }

  /// Reopen a completed goal
  Future<void> reopenGoal(String id) async {
    final goal = _hiveService.goalsBox.get(id);
    if (goal != null) {
      final updated = goal.copyWith(isCompleted: false);
      await _hiveService.goalsBox.put(id, updated);
      state = state.map((g) => g.id == id ? updated : g).toList();
    }
  }

  /// Refresh goals from Hive
  void refresh() {
    _loadGoals();
  }
}
