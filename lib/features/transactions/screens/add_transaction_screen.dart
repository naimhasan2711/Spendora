import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/transactions_provider.dart';
import '../../categories/providers/categories_provider.dart';
import '../../accounts/providers/accounts_provider.dart';
import '../../settings/providers/settings_provider.dart';

/// Add/Edit Transaction Screen
class AddTransactionScreen extends ConsumerStatefulWidget {
  final bool isIncome;
  final String? transactionId;

  const AddTransactionScreen({
    super.key,
    this.isIncome = false,
    this.transactionId,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  String _selectedAccountId = 'cash';
  String? _toAccountId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _paymentMethod = 'Cash';
  List<String> _tags = [];
  String? _imagePath;
  RecurrenceType _recurrence = RecurrenceType.none;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _type = widget.isIncome ? TransactionType.income : TransactionType.expense;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.isIncome ? 1 : 0,
    );
    _tabController.addListener(_onTabChanged);

    // Load transaction if editing
    if (widget.transactionId != null) {
      _loadTransaction();
    } else {
      // Set default account
      final settings = ref.read(settingsProvider);
      _selectedAccountId = settings.defaultAccountId;
    }
  }

  void _loadTransaction() {
    final transaction = ref
        .read(transactionsProvider.notifier)
        .getTransaction(widget.transactionId!);

    if (transaction != null) {
      _isEditing = true;
      _type = transaction.type;
      _amountController.text = transaction.amount.toString();
      _selectedCategoryId = transaction.categoryId;
      _selectedSubcategoryId = transaction.subcategoryId;
      _selectedAccountId = transaction.accountId;
      _toAccountId = transaction.toAccountId;
      _selectedDate = transaction.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(transaction.dateTime);
      _notesController.text = transaction.notes ?? '';
      _paymentMethod = transaction.paymentMethod;
      _tags = List.from(transaction.tags);
      _imagePath = transaction.imagePath;
      _recurrence = transaction.recurrence;
      _tabController.index = _type == TransactionType.income ? 1 : 0;
    }
  }

  void _onTabChanged() {
    setState(() {
      _type = _tabController.index == 0
          ? TransactionType.expense
          : TransactionType.income;
      _selectedCategoryId = null;
      _selectedSubcategoryId = null;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == TransactionType.expense
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);
    final accounts = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteTransaction,
            ),
        ],
      ),
      body: Column(
        children: [
          // Type Tabs
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: _type == TransactionType.expense
                    ? AppTheme.expense
                    : AppTheme.income,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: context.colorScheme.onSurface,
              tabs: const [
                Tab(text: 'Expense'),
                Tab(text: 'Income'),
              ],
            ),
          ),

          // Form
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Amount
                  _buildAmountField(),
                  const SizedBox(height: 24),

                  // Category
                  _buildCategorySelector(categories),
                  const SizedBox(height: 16),

                  // Account
                  _buildAccountSelector(accounts),
                  const SizedBox(height: 16),

                  // Date & Time
                  Row(
                    children: [
                      Expanded(child: _buildDatePicker()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTimePicker()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Payment Method
                  _buildPaymentMethodSelector(),
                  const SizedBox(height: 16),

                  // Notes
                  _buildNotesField(),
                  const SizedBox(height: 16),

                  // Tags
                  _buildTagsField(),
                  const SizedBox(height: 16),

                  // Recurrence
                  _buildRecurrenceSelector(),
                  const SizedBox(height: 16),

                  // Photo Attachment
                  _buildPhotoAttachment(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Save Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _type == TransactionType.expense
                      ? AppTheme.expense
                      : AppTheme.income,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isEditing ? 'Update' : 'Save Transaction',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: (_type == TransactionType.expense
                ? AppTheme.expense
                : AppTheme.income)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Amount',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '৳',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _type == TransactionType.expense
                      ? AppTheme.expense
                      : AppTheme.income,
                ),
              ),
              const SizedBox(width: 4),
              IntrinsicWidth(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: context.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid amount';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(List<CategoryModel> categories) {
    final selectedCategory = _selectedCategoryId != null
        ? categories.cast<CategoryModel?>().firstWhere(
              (c) => c?.id == _selectedCategoryId,
              orElse: () => null,
            )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showCategoryPicker(categories),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: context.colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (selectedCategory != null) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(selectedCategory.colorValue)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      IconData(selectedCategory.iconCodePoint,
                          fontFamily: 'MaterialIcons'),
                      color: Color(selectedCategory.colorValue),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedCategory.name,
                      style: context.textTheme.bodyLarge,
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.category_outlined,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select category',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCategoryPicker(List<CategoryModel> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Category',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategoryId == category.id;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = category.id;
                          _selectedSubcategoryId = null;
                        });
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(category.colorValue)
                                  .withValues(alpha: 0.2)
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: Color(category.colorValue), width: 2)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Color(category.colorValue)
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                IconData(category.iconCodePoint,
                                    fontFamily: 'MaterialIcons'),
                                color: Color(category.colorValue),
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.name,
                              style: context.textTheme.labelSmall?.copyWith(
                                fontWeight: isSelected ? FontWeight.w600 : null,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSelector(List<AccountModel> accounts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: accounts.map((account) {
              final isSelected = _selectedAccountId == account.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        IconData(account.iconCodePoint,
                            fontFamily: 'MaterialIcons'),
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : Color(account.colorValue),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        account.name,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : context.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  selectedColor: Color(account.colorValue),
                  backgroundColor: context.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedAccountId = account.id);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: context.colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('MMM d, yyyy').format(_selectedDate),
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectTime,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: context.colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  size: 20,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedTime.format(context),
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    final methods = [
      'Cash',
      'Card',
      'Bank Transfer',
      'Mobile Payment',
      'Check'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: methods.map((method) {
            final isSelected = _paymentMethod == method;
            return ChoiceChip(
              selected: isSelected,
              label: Text(
                method,
                style: TextStyle(
                  color:
                      isSelected ? Colors.white : context.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selectedColor: context.colorScheme.primary,
              backgroundColor: context.isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade100,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _paymentMethod = method);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add a note...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._tags.map((tag) => Chip(
                  label: Text('#$tag'),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => setState(() => _tags.remove(tag)),
                )),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('Add Tag'),
              onPressed: _addTag,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecurrenceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recurring',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RecurrenceType>(
          value: _recurrence,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: RecurrenceType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_getRecurrenceLabel(type)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _recurrence = value);
            }
          },
        ),
      ],
    );
  }

  String _getRecurrenceLabel(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return 'No repeat';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
      case RecurrenceType.custom:
        return 'Custom';
    }
  }

  Widget _buildPhotoAttachment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receipt / Photo',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: context.colorScheme.outline.withValues(alpha: 0.3),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          _imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton.filled(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() => _imagePath = null),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: context.colorScheme.onSurface
                            .withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add receipt or photo',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter tag name',
              prefixText: '# ',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() => _tags.add(controller.text.trim()));
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    // Show bottom sheet to choose between camera and gallery
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Add Receipt Photo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    context: context,
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: const Color(0xFF6C63FF),
                    onTap: () async {
                      Navigator.pop(context);
                      final image = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() => _imagePath = image.path);
                      }
                    },
                  ),
                  _buildImageSourceOption(
                    context: context,
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: const Color(0xFF22C55E),
                    onTap: () async {
                      Navigator.pop(context);
                      final image = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() => _imagePath = image.path);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final transaction = TransactionModel(
        id: _isEditing ? widget.transactionId : null,
        amount: double.parse(_amountController.text),
        type: _type,
        categoryId: _selectedCategoryId!,
        subcategoryId: _selectedSubcategoryId,
        dateTime: dateTime,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        accountId: _selectedAccountId,
        toAccountId: _toAccountId,
        paymentMethod: _paymentMethod,
        tags: _tags,
        imagePath: _imagePath,
        recurrence: _recurrence,
      );

      if (_isEditing) {
        await ref
            .read(transactionsProvider.notifier)
            .updateTransaction(transaction);
      } else {
        await ref
            .read(transactionsProvider.notifier)
            .addTransaction(transaction);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(_isEditing ? 'Transaction updated' : 'Transaction added'),
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

  Future<void> _deleteTransaction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content:
            const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(transactionsProvider.notifier)
          .deleteTransaction(widget.transactionId!);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}
