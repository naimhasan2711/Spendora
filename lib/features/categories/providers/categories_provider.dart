import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/category_model.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/services/hive_service.dart';

/// All categories provider
final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<CategoryModel>>(
  (ref) => CategoriesNotifier(),
);

/// Expense categories provider
final expenseCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final categories = ref.watch(categoriesProvider);
  return categories.where((c) => c.type == TransactionType.expense).toList()
    ..sort((a, b) => a.order.compareTo(b.order));
});

/// Income categories provider
final incomeCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final categories = ref.watch(categoriesProvider);
  return categories.where((c) => c.type == TransactionType.income).toList()
    ..sort((a, b) => a.order.compareTo(b.order));
});

/// Get category by ID provider
final categoryByIdProvider = Provider.family<CategoryModel?, String>((ref, id) {
  final categories = ref.watch(categoriesProvider);
  try {
    return categories.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});

/// Categories Notifier
class CategoriesNotifier extends StateNotifier<List<CategoryModel>> {
  CategoriesNotifier() : super([]) {
    _loadCategories();
  }

  final _hiveService = HiveService.instance;

  /// Load categories from Hive
  void _loadCategories() {
    state = _hiveService.categoriesBox.values.toList();
  }

  /// Add a new category
  Future<void> addCategory(CategoryModel category) async {
    await _hiveService.categoriesBox.put(category.id, category);
    state = [...state, category];
  }

  /// Update an existing category
  Future<void> updateCategory(CategoryModel category) async {
    await _hiveService.categoriesBox.put(category.id, category);
    state = state.map((c) => c.id == category.id ? category : c).toList();
  }

  /// Delete a category
  Future<void> deleteCategory(String id) async {
    await _hiveService.categoriesBox.delete(id);
    state = state.where((c) => c.id != id).toList();
  }

  /// Get category by ID
  CategoryModel? getCategory(String id) {
    return _hiveService.categoriesBox.get(id);
  }

  /// Reorder categories
  Future<void> reorderCategories(List<CategoryModel> categories) async {
    for (int i = 0; i < categories.length; i++) {
      final updated = categories[i].copyWith(order: i);
      await _hiveService.categoriesBox.put(updated.id, updated);
    }
    _loadCategories();
  }

  /// Add subcategory
  Future<void> addSubcategory(
      String categoryId, SubcategoryModel subcategory) async {
    final category = _hiveService.categoriesBox.get(categoryId);
    if (category != null) {
      final updated = category.copyWith(
        subcategories: [...category.subcategories, subcategory],
      );
      await _hiveService.categoriesBox.put(categoryId, updated);
      state = state.map((c) => c.id == categoryId ? updated : c).toList();
    }
  }

  /// Remove subcategory
  Future<void> removeSubcategory(
      String categoryId, String subcategoryId) async {
    final category = _hiveService.categoriesBox.get(categoryId);
    if (category != null) {
      final updated = category.copyWith(
        subcategories:
            category.subcategories.where((s) => s.id != subcategoryId).toList(),
      );
      await _hiveService.categoriesBox.put(categoryId, updated);
      state = state.map((c) => c.id == categoryId ? updated : c).toList();
    }
  }

  /// Refresh categories from Hive
  void refresh() {
    _loadCategories();
  }
}
