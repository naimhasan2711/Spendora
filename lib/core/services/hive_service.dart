import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import '../models/models.dart';
import 'hive_adapters.dart';

/// Hive Database Service - Singleton
class HiveService {
  HiveService._();
  static final HiveService instance = HiveService._();

  // Boxes
  late Box<TransactionModel> _transactionsBox;
  late Box<CategoryModel> _categoriesBox;
  late Box<AccountModel> _accountsBox;
  late Box<BudgetModel> _budgetsBox;
  late Box<GoalModel> _goalsBox;
  late Box<DebtModel> _debtsBox;
  late Box<CurrencyModel> _currenciesBox;
  late Box<SettingsModel> _settingsBox;
  late Box<String> _tagsBox;

  // Getters
  Box<TransactionModel> get transactionsBox => _transactionsBox;
  Box<CategoryModel> get categoriesBox => _categoriesBox;
  Box<AccountModel> get accountsBox => _accountsBox;
  Box<BudgetModel> get budgetsBox => _budgetsBox;
  Box<GoalModel> get goalsBox => _goalsBox;
  Box<DebtModel> get debtsBox => _debtsBox;
  Box<CurrencyModel> get currenciesBox => _currenciesBox;
  Box<SettingsModel> get settingsBox => _settingsBox;
  Box<String> get tagsBox => _tagsBox;

  /// Initialize Hive and register adapters
  Future<void> init() async {
    // Register all adapters
    _registerAdapters();

    // Open all boxes
    await _openBoxes();

    // Initialize default data if needed
    await _initializeDefaultData();
  }

  /// Register all Hive type adapters
  void _registerAdapters() {
    // Enums
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(RecurrenceTypeAdapter());
    Hive.registerAdapter(AccountTypeAdapter());
    Hive.registerAdapter(BudgetPeriodAdapter());
    Hive.registerAdapter(DebtTypeAdapter());

    // Models
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(SubcategoryModelAdapter());
    Hive.registerAdapter(AccountModelAdapter());
    Hive.registerAdapter(BudgetModelAdapter());
    Hive.registerAdapter(GoalModelAdapter());
    Hive.registerAdapter(DebtModelAdapter());
    Hive.registerAdapter(DebtPaymentModelAdapter());
    Hive.registerAdapter(CurrencyModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());
  }

  /// Open all Hive boxes
  Future<void> _openBoxes() async {
    _transactionsBox = await Hive.openBox<TransactionModel>(
      AppConstants.transactionsBox,
    );
    _categoriesBox = await Hive.openBox<CategoryModel>(
      AppConstants.categoriesBox,
    );
    _accountsBox = await Hive.openBox<AccountModel>(
      AppConstants.accountsBox,
    );
    _budgetsBox = await Hive.openBox<BudgetModel>(
      AppConstants.budgetsBox,
    );
    _goalsBox = await Hive.openBox<GoalModel>(
      AppConstants.goalsBox,
    );
    _debtsBox = await Hive.openBox<DebtModel>(
      AppConstants.debtsBox,
    );
    _currenciesBox = await Hive.openBox<CurrencyModel>(
      AppConstants.currenciesBox,
    );
    _settingsBox = await Hive.openBox<SettingsModel>(
      AppConstants.settingsBox,
    );
    _tagsBox = await Hive.openBox<String>(
      AppConstants.tagsBox,
    );
  }

  /// Initialize default data
  Future<void> _initializeDefaultData() async {
    // Initialize settings if not exists
    if (_settingsBox.isEmpty) {
      await _settingsBox.put('settings', SettingsModel());
    }

    // Initialize default categories if empty
    if (_categoriesBox.isEmpty) {
      await _initializeDefaultCategories();
    }

    // Initialize default accounts if empty
    if (_accountsBox.isEmpty) {
      await _initializeDefaultAccounts();
    }

    // Initialize default currencies if empty
    if (_currenciesBox.isEmpty) {
      await _initializeDefaultCurrencies();
    }
  }

  /// Initialize default expense and income categories
  Future<void> _initializeDefaultCategories() async {
    // Expense categories
    final expenseCategories = [
      CategoryModel(
        id: 'food',
        name: 'Food & Dining',
        iconCodePoint: 0xe56c,
        colorValue: 0xFFFF6B6B,
        type: TransactionType.expense,
        isDefault: true,
        order: 0,
        subcategories: [
          SubcategoryModel(name: 'Restaurants', iconCodePoint: 0xe56c),
          SubcategoryModel(name: 'Groceries', iconCodePoint: 0xe8cc),
          SubcategoryModel(name: 'Coffee', iconCodePoint: 0xefef),
          SubcategoryModel(name: 'Fast Food', iconCodePoint: 0xe56c),
        ],
      ),
      CategoryModel(
        id: 'transport',
        name: 'Transport',
        iconCodePoint: 0xe1d5,
        colorValue: 0xFF4ECDC4,
        type: TransactionType.expense,
        isDefault: true,
        order: 1,
        subcategories: [
          SubcategoryModel(name: 'Fuel', iconCodePoint: 0xe546),
          SubcategoryModel(name: 'Taxi/Ride Share', iconCodePoint: 0xe558),
          SubcategoryModel(name: 'Public Transport', iconCodePoint: 0xe530),
          SubcategoryModel(name: 'Parking', iconCodePoint: 0xe54f),
        ],
      ),
      CategoryModel(
        id: 'shopping',
        name: 'Shopping',
        iconCodePoint: 0xe59d,
        colorValue: 0xFFFFE66D,
        type: TransactionType.expense,
        isDefault: true,
        order: 2,
        subcategories: [
          SubcategoryModel(name: 'Clothing', iconCodePoint: 0xea77),
          SubcategoryModel(name: 'Electronics', iconCodePoint: 0xe1b1),
          SubcategoryModel(name: 'Home Goods', iconCodePoint: 0xe88a),
        ],
      ),
      CategoryModel(
        id: 'bills',
        name: 'Bills & Utilities',
        iconCodePoint: 0xe873,
        colorValue: 0xFF95E1D3,
        type: TransactionType.expense,
        isDefault: true,
        order: 3,
        subcategories: [
          SubcategoryModel(name: 'Electricity', iconCodePoint: 0xea0b),
          SubcategoryModel(name: 'Water', iconCodePoint: 0xe798),
          SubcategoryModel(name: 'Gas', iconCodePoint: 0xe3f7),
          SubcategoryModel(name: 'Internet', iconCodePoint: 0xe63e),
          SubcategoryModel(name: 'Phone', iconCodePoint: 0xe32c),
        ],
      ),
      CategoryModel(
        id: 'entertainment',
        name: 'Entertainment',
        iconCodePoint: 0xe5dc,
        colorValue: 0xFFDDA0DD,
        type: TransactionType.expense,
        isDefault: true,
        order: 4,
        subcategories: [
          SubcategoryModel(name: 'Movies', iconCodePoint: 0xe5dc),
          SubcategoryModel(name: 'Games', iconCodePoint: 0xea28),
          SubcategoryModel(name: 'Sports', iconCodePoint: 0xeb4f),
          SubcategoryModel(name: 'Concerts', iconCodePoint: 0xe3a2),
        ],
      ),
      CategoryModel(
        id: 'health',
        name: 'Health',
        iconCodePoint: 0xe548,
        colorValue: 0xFFFF6F61,
        type: TransactionType.expense,
        isDefault: true,
        order: 5,
        subcategories: [
          SubcategoryModel(name: 'Doctor', iconCodePoint: 0xe548),
          SubcategoryModel(name: 'Medicine', iconCodePoint: 0xe3f2),
          SubcategoryModel(name: 'Gym', iconCodePoint: 0xeb43),
        ],
      ),
      CategoryModel(
        id: 'education',
        name: 'Education',
        iconCodePoint: 0xe80c,
        colorValue: 0xFF6B5B95,
        type: TransactionType.expense,
        isDefault: true,
        order: 6,
        subcategories: [
          SubcategoryModel(name: 'Books', iconCodePoint: 0xe865),
          SubcategoryModel(name: 'Courses', iconCodePoint: 0xe80c),
          SubcategoryModel(name: 'Tuition', iconCodePoint: 0xf06f),
        ],
      ),
      CategoryModel(
        id: 'rent',
        name: 'Rent',
        iconCodePoint: 0xe88a,
        colorValue: 0xFF92A8D1,
        type: TransactionType.expense,
        isDefault: true,
        order: 7,
      ),
      CategoryModel(
        id: 'travel',
        name: 'Travel',
        iconCodePoint: 0xe539,
        colorValue: 0xFF88B04B,
        type: TransactionType.expense,
        isDefault: true,
        order: 8,
        subcategories: [
          SubcategoryModel(name: 'Flights', iconCodePoint: 0xe539),
          SubcategoryModel(name: 'Hotels', iconCodePoint: 0xe53a),
          SubcategoryModel(name: 'Vacation', iconCodePoint: 0xeb3e),
        ],
      ),
      CategoryModel(
        id: 'personal',
        name: 'Personal Care',
        iconCodePoint: 0xea21,
        colorValue: 0xFFB565A7,
        type: TransactionType.expense,
        isDefault: true,
        order: 9,
        subcategories: [
          SubcategoryModel(name: 'Haircut', iconCodePoint: 0xe87c),
          SubcategoryModel(name: 'Spa', iconCodePoint: 0xea21),
          SubcategoryModel(name: 'Cosmetics', iconCodePoint: 0xef55),
        ],
      ),
      CategoryModel(
        id: 'gifts',
        name: 'Gifts',
        iconCodePoint: 0xe8f6,
        colorValue: 0xFFDD4124,
        type: TransactionType.expense,
        isDefault: true,
        order: 10,
      ),
      CategoryModel(
        id: 'subscriptions',
        name: 'Subscriptions',
        iconCodePoint: 0xe863,
        colorValue: 0xFF009B77,
        type: TransactionType.expense,
        isDefault: true,
        order: 11,
      ),
      CategoryModel(
        id: 'other_expense',
        name: 'Other',
        iconCodePoint: 0xe5d3,
        colorValue: 0xFF98B4D4,
        type: TransactionType.expense,
        isDefault: true,
        order: 12,
      ),
    ];

    // Income categories
    final incomeCategories = [
      CategoryModel(
        id: 'salary',
        name: 'Salary',
        iconCodePoint: 0xe850,
        colorValue: 0xFF45B8AC,
        type: TransactionType.income,
        isDefault: true,
        order: 0,
      ),
      CategoryModel(
        id: 'business',
        name: 'Business',
        iconCodePoint: 0xe0af,
        colorValue: 0xFF5B5EA6,
        type: TransactionType.income,
        isDefault: true,
        order: 1,
      ),
      CategoryModel(
        id: 'freelance',
        name: 'Freelance',
        iconCodePoint: 0xe30a,
        colorValue: 0xFF9B2335,
        type: TransactionType.income,
        isDefault: true,
        order: 2,
      ),
      CategoryModel(
        id: 'investment',
        name: 'Investment',
        iconCodePoint: 0xe263,
        colorValue: 0xFFDFCFBE,
        type: TransactionType.income,
        isDefault: true,
        order: 3,
      ),
      CategoryModel(
        id: 'gift_income',
        name: 'Gifts',
        iconCodePoint: 0xe8f6,
        colorValue: 0xFFBC243C,
        type: TransactionType.income,
        isDefault: true,
        order: 4,
      ),
      CategoryModel(
        id: 'rental_income',
        name: 'Rental Income',
        iconCodePoint: 0xe88a,
        colorValue: 0xFFC3447A,
        type: TransactionType.income,
        isDefault: true,
        order: 5,
      ),
      CategoryModel(
        id: 'refund',
        name: 'Refund',
        iconCodePoint: 0xe042,
        colorValue: 0xFF6B5B95,
        type: TransactionType.income,
        isDefault: true,
        order: 6,
      ),
      CategoryModel(
        id: 'other_income',
        name: 'Other',
        iconCodePoint: 0xe5d3,
        colorValue: 0xFF98B4D4,
        type: TransactionType.income,
        isDefault: true,
        order: 7,
      ),
    ];

    // Save all categories
    for (final category in [...expenseCategories, ...incomeCategories]) {
      await _categoriesBox.put(category.id, category);
    }
  }

  /// Initialize default accounts
  Future<void> _initializeDefaultAccounts() async {
    for (final account in DefaultAccounts.accounts) {
      await _accountsBox.put(account.id, account);
    }
  }

  /// Initialize default currencies
  Future<void> _initializeDefaultCurrencies() async {
    for (final currency in DefaultCurrencies.currencies) {
      await _currenciesBox.put(currency.code, currency);
    }
  }

  /// Get settings
  SettingsModel get settings => _settingsBox.get('settings') ?? SettingsModel();

  /// Update settings
  Future<void> updateSettings(SettingsModel settings) async {
    await _settingsBox.put('settings', settings);
  }

  /// Clear all data
  Future<void> clearAllData() async {
    await _transactionsBox.clear();
    await _categoriesBox.clear();
    await _accountsBox.clear();
    await _budgetsBox.clear();
    await _goalsBox.clear();
    await _debtsBox.clear();
    await _tagsBox.clear();

    // Re-initialize default data
    await _initializeDefaultCategories();
    await _initializeDefaultAccounts();
  }

  /// Close all boxes
  Future<void> close() async {
    await _transactionsBox.close();
    await _categoriesBox.close();
    await _accountsBox.close();
    await _budgetsBox.close();
    await _goalsBox.close();
    await _debtsBox.close();
    await _currenciesBox.close();
    await _settingsBox.close();
    await _tagsBox.close();
  }
}
