import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/categories_provider.dart';

/// Add/Edit Category Screen
class AddCategoryScreen extends ConsumerStatefulWidget {
  final String? categoryId;

  const AddCategoryScreen({super.key, this.categoryId});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  int _selectedIconCodePoint = 0xe5d3; // more_horiz
  Color _selectedColor = const Color(0xFF0D4A3E);

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      _loadCategory();
    }
  }

  void _loadCategory() {
    final category =
        ref.read(categoriesProvider.notifier).getCategory(widget.categoryId!);
    if (category != null) {
      _isEditing = true;
      _nameController.text = category.name;
      _type = category.type;
      _selectedIconCodePoint = category.iconCodePoint;
      _selectedColor = Color(category.colorValue);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Category' : 'Add Category'),
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

            // Category Type
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
                    label: 'Expense',
                    isSelected: _type == TransactionType.expense,
                    color: AppTheme.expense,
                    onTap: () =>
                        setState(() => _type = TransactionType.expense),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeButton(
                    label: 'Income',
                    isSelected: _type == TransactionType.income,
                    color: AppTheme.income,
                    onTap: () => setState(() => _type = TransactionType.income),
                  ),
                ),
              ],
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
                hintText: 'Category name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
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
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveCategory,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(_isEditing ? 'Update' : 'Create Category'),
        ),
      ),
    );
  }

  Widget _buildIconGrid() {
    // Expanded Material Icons library
    final icons = [
      // Food & Dining
      0xe56c, // restaurant_menu
      0xefef, // local_cafe (coffee)
      0xe56e, // fastfood
      0xea6c, // lunch_dining
      0xea60, // bakery_dining
      0xe8cc, // shopping_cart (groceries)

      // Transport
      0xe531, // directions_bus
      0xe1d5, // directions_car
      0xe558, // local_taxi
      0xe54f, // local_parking
      0xe546, // local_gas_station
      0xe539, // flight

      // Shopping
      0xf37d, // shopping_bag
      0xe59d, // local_mall
      0xea77, // checkroom (clothing)
      0xe1b1, // devices (electronics)

      // Home & Bills
      0xe73a, // house
      0xe8e9, // receipt_long
      0xea0b, // electrical_services
      0xe798, // water_drop
      0xe63e, // wifi
      0xe32c, // phone

      // Health & Personal
      0xf109, // medical_services
      0xf3eb, // medication (pill)
      0xeb43, // fitness_center
      0xea21, // spa
      0xe548, // favorite (health)

      // Work & Education
      0xe8f9, // work (briefcase)
      0xe80c, // school
      0xe865, // menu_book
      0xe30a, // laptop_mac

      // Entertainment
      0xea65, // theaters
      0xea28, // sports_esports
      0xeb4f, // sports
      0xe3a2, // music_note

      // Finance
      0xe263, // payments
      0xe84f, // account_balance
      0xe8d3, // savings
      0xe6e1, // show_chart
      0xe870, // credit_card

      // Travel
      0xe53a, // hotel
      0xeb3e, // beach_access
      0xe55f, // luggage

      // Other
      0xea10, // redeem (gift)
      0xe1af, // subscriptions
      0xf00d, // health_and_safety
      0xe5d5, // undo (refund)
      0xe0af, // store
      0xe5d3, // more_horiz
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

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final category = CategoryModel(
        id: _isEditing ? widget.categoryId : null,
        name: _nameController.text.trim(),
        iconCodePoint: _selectedIconCodePoint,
        colorValue: _selectedColor.value,
        type: _type,
      );

      if (_isEditing) {
        await ref.read(categoriesProvider.notifier).updateCategory(category);
      } else {
        await ref.read(categoriesProvider.notifier).addCategory(category);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Category updated' : 'Category created'),
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
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : context.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? color : null,
            ),
          ),
        ),
      ),
    );
  }
}
