import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../providers/goals_provider.dart';

/// Add/Edit Goal Screen
class AddGoalScreen extends ConsumerStatefulWidget {
  final String? goalId;

  const AddGoalScreen({super.key, this.goalId});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _savedController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  int _selectedIconCodePoint = 0xe8e5; // savings
  Color _selectedColor = const Color(0xFF0D4A3E);
  DateTime? _targetDate;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.goalId != null) {
      _loadGoal();
    }
  }

  void _loadGoal() {
    final goal = ref.read(goalsProvider.notifier).getGoal(widget.goalId!);
    if (goal != null) {
      _isEditing = true;
      _nameController.text = goal.name;
      _targetController.text = goal.targetAmount.toString();
      _savedController.text = goal.savedAmount.toString();
      _notesController.text = goal.notes ?? '';
      _selectedIconCodePoint = goal.iconCodePoint;
      _selectedColor = Color(goal.colorValue);
      _targetDate = goal.targetDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _savedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Goal' : 'Create Goal'),
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

            // Goal Name
            Text(
              'Goal Name',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g. New Phone, Vacation, Emergency Fund',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Target Amount
            Text(
              'Target Amount',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _targetController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixText: '৳ ',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter target amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Invalid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Already Saved
            Text(
              'Already Saved',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _savedController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixText: '৳ ',
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null) {
                    return 'Invalid amount';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Target Date
            Text(
              'Target Date (Optional)',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _targetDate ??
                      DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (date != null) {
                  setState(() => _targetDate = date);
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(_targetDate == null
                  ? 'Select target date'
                  : AppFormatters.formatDate(_targetDate!)),
            ),
            const SizedBox(height: 24),

            // Notes
            Text(
              'Notes (Optional)',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add any notes about this goal',
              ),
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
          onPressed: _isLoading ? null : _saveGoal,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(_isEditing ? 'Update' : 'Create Goal'),
        ),
      ),
    );
  }

  Widget _buildIconGrid() {
    final icons = [
      0xe8e5, // savings
      0xe88a, // home
      0xe1d5, // directions_car
      0xe539, // flight
      0xe227, // smartphone
      0xe30a, // laptop
      0xe80c, // school
      0xea21, // spa
      0xe548, // favorite
      0xe8f6, // card_giftcard
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

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final goal = GoalModel(
        id: _isEditing ? widget.goalId : null,
        name: _nameController.text.trim(),
        targetAmount: double.parse(_targetController.text),
        savedAmount: double.tryParse(_savedController.text) ?? 0,
        iconCodePoint: _selectedIconCodePoint,
        colorValue: _selectedColor.value,
        targetDate: _targetDate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (_isEditing) {
        await ref.read(goalsProvider.notifier).updateGoal(goal);
      } else {
        await ref.read(goalsProvider.notifier).addGoal(goal);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Goal updated' : 'Goal created'),
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
