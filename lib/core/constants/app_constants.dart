/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Spendora';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Track your expenses, achieve your goals';

  // Hive Box Names
  static const String transactionsBox = 'transactions';
  static const String categoriesBox = 'categories';
  static const String accountsBox = 'accounts';
  static const String budgetsBox = 'budgets';
  static const String goalsBox = 'goals';
  static const String debtsBox = 'debts';
  static const String settingsBox = 'settings';
  static const String tagsBox = 'tags';
  static const String currenciesBox = 'currencies';
  static const String recurringBox = 'recurring_transactions';

  // Settings Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyDefaultCurrency = 'default_currency';
  static const String keyPinEnabled = 'pin_enabled';
  static const String keyPin = 'pin';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyDefaultAccount = 'default_account';

  // Default Values
  static const String defaultCurrency = 'BDT';
  static const int maxRecentTransactions = 10;
  static const int maxChartCategories = 6;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Splash Screen Duration
  static const Duration splashDuration = Duration(seconds: 2);
}

/// Default category icons mapping
class CategoryIcons {
  CategoryIcons._();

  static const Map<String, int> expense = {
    'Food & Dining': 0xe56c, // restaurant
    'Transport': 0xe1d5, // directions_car
    'Shopping': 0xe59d, // shopping_bag
    'Bills & Utilities': 0xe873, // receipt
    'Entertainment': 0xe5dc, // movie
    'Health': 0xe548, // favorite
    'Education': 0xe80c, // school
    'Travel': 0xe539, // flight
    'Groceries': 0xe8cc, // shopping_cart
    'Rent': 0xe88a, // home
    'Insurance': 0xe8e8, // security
    'Personal Care': 0xea21, // spa
    'Gifts': 0xe8f6, // card_giftcard
    'Subscriptions': 0xe863, // subscriptions
    'Other': 0xe5d3, // more_horiz
  };

  static const Map<String, int> income = {
    'Salary': 0xe850, // account_balance_wallet
    'Business': 0xe0af, // business
    'Freelance': 0xe30a, // laptop
    'Investment': 0xe263, // trending_up
    'Gifts': 0xe8f6, // card_giftcard
    'Rental': 0xe88a, // home
    'Refund': 0xe042, // replay
    'Other': 0xe5d3, // more_horiz
  };
}

/// Default category colors
class CategoryColors {
  CategoryColors._();

  static const Map<String, int> colors = {
    'Food & Dining': 0xFFFF6B6B,
    'Transport': 0xFF4ECDC4,
    'Shopping': 0xFFFFE66D,
    'Bills & Utilities': 0xFF95E1D3,
    'Entertainment': 0xFFDDA0DD,
    'Health': 0xFFFF6F61,
    'Education': 0xFF6B5B95,
    'Travel': 0xFF88B04B,
    'Groceries': 0xFFF7CAC9,
    'Rent': 0xFF92A8D1,
    'Insurance': 0xFF955251,
    'Personal Care': 0xFFB565A7,
    'Gifts': 0xFFDD4124,
    'Subscriptions': 0xFF009B77,
    'Salary': 0xFF45B8AC,
    'Business': 0xFF5B5EA6,
    'Freelance': 0xFF9B2335,
    'Investment': 0xFFDFCFBE,
    'Refund': 0xFFBC243C,
    'Rental': 0xFFC3447A,
    'Other': 0xFF98B4D4,
  };
}
