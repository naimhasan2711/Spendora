import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/categories_provider.dart';

/// Categories Management Screen
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseCategories = ref.watch(expenseCategoriesProvider);
    final incomeCategories = ref.watch(incomeCategoriesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expense'),
              Tab(text: 'Income'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CategoryList(categories: expenseCategories),
            _CategoryList(categories: incomeCategories),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'categoriesFAB',
          onPressed: () => context.push(AppRoutes.addCategory),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<CategoryModel> categories;

  const _CategoryList({required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: context.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No categories',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      onReorder: (oldIndex, newIndex) {
        // TODO: Implement reorder
      },
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          key: ValueKey(category.id),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Color(category.colorValue).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
                color: Color(category.colorValue),
              ),
            ),
            title: Text(category.name),
            subtitle: category.subcategories.isNotEmpty
                ? Text('${category.subcategories.length} subcategories')
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (category.isDefault)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Default',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.drag_handle),
              ],
            ),
            onTap: () {
              // Edit category
            },
          ),
        );
      },
    );
  }
}
