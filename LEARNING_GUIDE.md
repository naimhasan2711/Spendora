# Spendora - Flutter Learning Guide

A comprehensive guide to understand the technologies, architecture, and code patterns used in the Spendora expense tracker app. This document will help you learn Flutter development through practical examples.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Technologies & Packages](#2-technologies--packages)
3. [Project Architecture](#3-project-architecture)
4. [State Management (Riverpod)](#4-state-management-riverpod)
5. [Local Database (Hive)](#5-local-database-hive)
6. [Navigation (GoRouter)](#6-navigation-gorouter)
7. [Theming & Styling](#7-theming--styling)
8. [Data Models](#8-data-models)
9. [UI Components & Widgets](#9-ui-components--widgets)
10. [Key Code Patterns](#10-key-code-patterns)
11. [Learning Resources](#11-learning-resources)

---

## 1. Project Overview

**Spendora** is a fully offline, production-ready expense tracker app built with Flutter. It demonstrates:

- Clean Architecture with feature-first folder structure
- State management with Riverpod
- Local storage with Hive NoSQL database
- Material Design 3 theming
- Charts and data visualization
- CRUD operations
- Form validation
- Navigation with GoRouter

### App Features

| Feature      | Description                                   |
| ------------ | --------------------------------------------- |
| Transactions | Add, edit, delete income/expense/transfers    |
| Categories   | Custom categories with icons and colors       |
| Accounts     | Multiple accounts (cash, bank, wallet)        |
| Budgets      | Set spending limits per category/overall      |
| Goals        | Financial saving goals with progress tracking |
| Debts        | Track money you owe or are owed               |
| Reports      | Charts and analytics for spending patterns    |
| Calendar     | View transactions by date                     |
| Search       | Full-text search across transactions          |
| Themes       | Light/Dark mode support                       |
| Security     | PIN/Biometric authentication                  |
| Export       | PDF and CSV export                            |

---

## 2. Technologies & Packages

### Core Framework

| Package | Version | Purpose              | Documentation                           |
| ------- | ------- | -------------------- | --------------------------------------- |
| Flutter | 3.5.0+  | UI Framework         | [flutter.dev](https://flutter.dev/docs) |
| Dart    | 3.5.0+  | Programming Language | [dart.dev](https://dart.dev/guides)     |

### State Management

| Package            | Purpose                                | Documentation                                                          |
| ------------------ | -------------------------------------- | ---------------------------------------------------------------------- |
| `flutter_riverpod` | State management, dependency injection | [riverpod.dev](https://riverpod.dev/docs/introduction/getting_started) |

**Why Riverpod?**

- Compile-time safety (catches errors before runtime)
- No BuildContext needed to read providers
- Easy testing and mocking
- Supports async data (FutureProvider, StreamProvider)
- Auto-disposal of unused providers

### Database & Storage

| Package         | Purpose                          | Documentation                                                            |
| --------------- | -------------------------------- | ------------------------------------------------------------------------ |
| `hive`          | Fast, lightweight NoSQL database | [docs.hivedb.dev](https://docs.hivedb.dev/)                              |
| `hive_flutter`  | Flutter integration for Hive     | [pub.dev/packages/hive_flutter](https://pub.dev/packages/hive_flutter)   |
| `path_provider` | Access device file paths         | [pub.dev/packages/path_provider](https://pub.dev/packages/path_provider) |

**Why Hive?**

- No native dependencies
- Extremely fast (written in pure Dart)
- Supports encryption
- Works offline
- Type-safe with adapters

### Navigation

| Package     | Purpose             | Documentation                                                    |
| ----------- | ------------------- | ---------------------------------------------------------------- |
| `go_router` | Declarative routing | [pub.dev/packages/go_router](https://pub.dev/packages/go_router) |

**Why GoRouter?**

- Official Flutter routing package
- Deep linking support
- Type-safe routing
- URL-based navigation
- Nested routes support

### UI & Visualization

| Package                 | Purpose                     | Documentation                                                                            |
| ----------------------- | --------------------------- | ---------------------------------------------------------------------------------------- |
| `fl_chart`              | Beautiful charts            | [pub.dev/packages/fl_chart](https://pub.dev/packages/fl_chart)                           |
| `percent_indicator`     | Progress indicators         | [pub.dev/packages/percent_indicator](https://pub.dev/packages/percent_indicator)         |
| `flutter_slidable`      | Swipe actions on list items | [pub.dev/packages/flutter_slidable](https://pub.dev/packages/flutter_slidable)           |
| `table_calendar`        | Calendar widget             | [pub.dev/packages/table_calendar](https://pub.dev/packages/table_calendar)               |
| `flex_color_picker`     | Color picker dialog         | [pub.dev/packages/flex_color_picker](https://pub.dev/packages/flex_color_picker)         |
| `smooth_page_indicator` | Page indicators             | [pub.dev/packages/smooth_page_indicator](https://pub.dev/packages/smooth_page_indicator) |
| `flutter_animate`       | Declarative animations      | [pub.dev/packages/flutter_animate](https://pub.dev/packages/flutter_animate)             |

### Utilities

| Package        | Purpose                         | Documentation                                                          |
| -------------- | ------------------------------- | ---------------------------------------------------------------------- |
| `intl`         | Date/number formatting, i18n    | [pub.dev/packages/intl](https://pub.dev/packages/intl)                 |
| `uuid`         | Generate unique IDs             | [pub.dev/packages/uuid](https://pub.dev/packages/uuid)                 |
| `image_picker` | Pick images from gallery/camera | [pub.dev/packages/image_picker](https://pub.dev/packages/image_picker) |
| `share_plus`   | Share content                   | [pub.dev/packages/share_plus](https://pub.dev/packages/share_plus)     |
| `local_auth`   | Biometric/PIN authentication    | [pub.dev/packages/local_auth](https://pub.dev/packages/local_auth)     |
| `pdf`          | Generate PDF documents          | [pub.dev/packages/pdf](https://pub.dev/packages/pdf)                   |
| `csv`          | CSV file generation             | [pub.dev/packages/csv](https://pub.dev/packages/csv)                   |

---

## 3. Project Architecture

### Feature-First Structure

```
lib/
├── main.dart                 # App entry point
├── core/                     # Shared code across features
│   ├── constants/           # App-wide constants
│   ├── models/              # Data models
│   ├── router/              # Navigation configuration
│   ├── services/            # Business logic services
│   ├── theme/               # App theming
│   └── utils/               # Utility functions
│
└── features/                 # Feature modules
    ├── accounts/            # Account management
    │   ├── providers/       # State management
    │   ├── screens/         # UI screens
    │   └── widgets/         # Feature-specific widgets
    ├── budgets/
    ├── categories/
    ├── debts/
    ├── goals/
    ├── home/
    ├── reports/
    ├── search/
    ├── settings/
    └── transactions/
```

### Architecture Layers

```
┌─────────────────────────────────────────────┐
│                    UI Layer                  │
│              (Screens, Widgets)              │
├─────────────────────────────────────────────┤
│                State Layer                   │
│            (Riverpod Providers)              │
├─────────────────────────────────────────────┤
│               Service Layer                  │
│           (HiveService, etc.)                │
├─────────────────────────────────────────────┤
│                Data Layer                    │
│              (Models, Hive)                  │
└─────────────────────────────────────────────┘
```

### Key Principles

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Feature-First**: Related code is grouped by feature, not type
3. **Dependency Injection**: Riverpod provides dependencies
4. **Immutability**: Data models use `copyWith` for updates

---

## 4. State Management (Riverpod)

### Provider Types Used

```dart
// 1. Provider - For computed/derived values
final totalBalanceProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider);
  return accounts.fold(0.0, (sum, account) => sum + account.balance);
});

// 2. StateProvider - For simple mutable state
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// 3. StateNotifierProvider - For complex state with methods
final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<TransactionModel>>(
  (ref) => TransactionsNotifier(ref),
);

// 4. Provider.family - For parameterized providers
final categoryByIdProvider = Provider.family<CategoryModel?, String>((ref, id) {
  final categories = ref.watch(categoriesProvider);
  return categories.firstWhereOrNull((c) => c.id == id);
});
```

### StateNotifier Example

```dart
/// File: lib/features/transactions/providers/transactions_provider.dart

class TransactionsNotifier extends StateNotifier<List<TransactionModel>> {
  final Ref _ref;

  TransactionsNotifier(this._ref) : super([]) {
    _loadTransactions();
  }

  final _hiveService = HiveService.instance;

  // Load data from Hive
  void _loadTransactions() {
    state = _hiveService.transactionsBox.values.toList();
  }

  // Add transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    await _hiveService.transactionsBox.put(transaction.id, transaction);
    state = [...state, transaction];  // Immutable update
  }

  // Update transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _hiveService.transactionsBox.put(transaction.id, transaction);
    state = state.map((t) => t.id == transaction.id ? transaction : t).toList();
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    await _hiveService.transactionsBox.delete(id);
    state = state.where((t) => t.id != id).toList();
  }
}
```

### Using Providers in Widgets

```dart
/// ConsumerWidget - Widget that can read providers
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch - rebuilds when value changes
    final transactions = ref.watch(transactionsProvider);
    final totalBalance = ref.watch(totalBalanceProvider);

    // Read - one-time read, doesn't rebuild
    final notifier = ref.read(transactionsProvider.notifier);

    return Scaffold(
      body: Text('Balance: $totalBalance'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => notifier.addTransaction(newTransaction),
      ),
    );
  }
}

/// ConsumerStatefulWidget - Stateful widget with providers
class AddTransactionScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    // ...
  }
}
```

### Learning Resources for Riverpod

- 📚 [Official Documentation](https://riverpod.dev/docs/introduction/getting_started)
- 📺 [Riverpod 2.0 Course by Code With Andrea](https://codewithandrea.com/courses/flutter-riverpod/)
- 📝 [Riverpod Cheat Sheet](https://codewithandrea.com/articles/flutter-state-management-riverpod/)

---

## 5. Local Database (Hive)

### Hive Setup

```dart
/// File: lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await HiveService.instance.init();

  runApp(const ProviderScope(child: SpendoraApp()));
}
```

### Singleton Service Pattern

```dart
/// File: lib/core/services/hive_service.dart

class HiveService {
  // Private constructor
  HiveService._();

  // Singleton instance
  static final HiveService instance = HiveService._();

  // Typed boxes for each data type
  late Box<TransactionModel> _transactionsBox;
  late Box<CategoryModel> _categoriesBox;
  late Box<AccountModel> _accountsBox;

  // Public getters
  Box<TransactionModel> get transactionsBox => _transactionsBox;
  Box<CategoryModel> get categoriesBox => _categoriesBox;
  Box<AccountModel> get accountsBox => _accountsBox;

  Future<void> init() async {
    _registerAdapters();
    await _openBoxes();
    await _initializeDefaultData();
  }

  void _registerAdapters() {
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    // ... register all adapters
  }

  Future<void> _openBoxes() async {
    _transactionsBox = await Hive.openBox<TransactionModel>('transactions');
    _categoriesBox = await Hive.openBox<CategoryModel>('categories');
    // ... open all boxes
  }
}
```

### Manual Type Adapters

```dart
/// File: lib/core/services/hive_adapters.dart

/// Adapter for TransactionModel
class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 1;  // Unique ID for this type

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return TransactionModel(
      id: fields[0] as String,
      amount: fields[1] as double,
      type: fields[2] as TransactionType,
      // ... read all fields
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(15)  // Number of fields
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.amount)
      ..writeByte(2)..write(obj.type)
      // ... write all fields
  }
}

/// Adapter for Enums
class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 0;

  @override
  TransactionType read(BinaryReader reader) {
    return TransactionType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    writer.writeByte(obj.index);
  }
}
```

### CRUD Operations

```dart
// CREATE
await hiveService.transactionsBox.put(transaction.id, transaction);

// READ (single item)
final transaction = hiveService.transactionsBox.get(id);

// READ (all items)
final allTransactions = hiveService.transactionsBox.values.toList();

// UPDATE (same as create - uses same key)
await hiveService.transactionsBox.put(transaction.id, updatedTransaction);

// DELETE
await hiveService.transactionsBox.delete(id);

// DELETE ALL
await hiveService.transactionsBox.clear();
```

### Learning Resources for Hive

- 📚 [Official Hive Documentation](https://docs.hivedb.dev/)
- 📺 [Hive Tutorial by Reso Coder](https://www.youtube.com/watch?v=R1GSrrItqUs)
- 📝 [Hive vs SQLite Comparison](https://blog.logrocket.com/handling-local-data-persistence-flutter-hive/)

---

## 6. Navigation (GoRouter)

### Router Configuration

```dart
/// File: lib/core/router/app_router.dart

// Define route paths as constants
class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String addTransaction = '/add-transaction';
  static const String editTransaction = '/edit-transaction/:id';
  static const String transactionDetails = '/transaction/:id';
}

// Create router as a Riverpod provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,  // Logs navigation events
    routes: [
      // Basic route
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Route with path parameters
      GoRoute(
        path: AppRoutes.transactionDetails,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TransactionDetailsScreen(transactionId: id);
        },
      ),

      // Route with query parameters
      GoRoute(
        path: AppRoutes.addTransaction,
        builder: (context, state) {
          final type = state.uri.queryParameters['type'];
          return AddTransactionScreen(initialType: type);
        },
      ),
    ],
  );
});
```

### Navigation Methods

```dart
// Import go_router
import 'package:go_router/go_router.dart';

// Navigate to a route
context.go('/home');

// Push a route (adds to stack)
context.push('/add-transaction');

// Push with path parameters
context.push('/transaction/123');

// Push with query parameters
context.push('/add-transaction?type=expense');

// Pop (go back)
context.pop();

// Replace current route
context.replace('/home');
```

### Using Router in MaterialApp

```dart
class SpendoraApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      routerConfig: router,  // Use GoRouter
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
    );
  }
}
```

### Learning Resources for GoRouter

- 📚 [GoRouter Documentation](https://pub.dev/packages/go_router)
- 📺 [GoRouter Tutorial by Flutter](https://www.youtube.com/watch?v=b6Z885Z46cU)
- 📝 [Navigation Cookbook](https://docs.flutter.dev/cookbook/navigation)

---

## 7. Theming & Styling

### Theme Configuration

```dart
/// File: lib/core/theme/app_theme.dart

class AppTheme {
  AppTheme._();

  // Color Definitions
  static const Color _primaryLight = Color(0xFF6C63FF);
  static const Color _primaryDark = Color(0xFF8B83FF);
  static const Color income = Color(0xFF22C55E);
  static const Color expense = Color(0xFFEF4444);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryLight,
        secondary: _secondaryLight,
        surface: _surfaceLight,
        error: error,
        onPrimary: Colors.white,
        onSurface: _textPrimaryLight,
      ),
      scaffoldBackgroundColor: _backgroundLight,

      // Component themes
      appBarTheme: AppBarTheme(...),
      cardTheme: CardTheme(...),
      elevatedButtonTheme: ElevatedButtonThemeData(...),
      inputDecorationTheme: InputDecorationTheme(...),
      chipTheme: ChipThemeData(...),

      // Text theme
      textTheme: _textTheme,
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // ... similar structure
    );
  }
}
```

### Theme Extension for Easy Access

```dart
/// Extension for quick theme access
extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

// Usage in widgets
Text(
  'Hello',
  style: context.textTheme.titleLarge?.copyWith(
    color: context.colorScheme.primary,
  ),
);

// Check dark mode
if (context.isDarkMode) {
  // Dark mode specific code
}
```

### Dynamic Theme Switching

```dart
/// In settings provider
class SettingsNotifier extends StateNotifier<SettingsModel> {
  void setThemeMode(int index) {
    final updated = state.copyWith(themeModeIndex: index);
    _saveSettings(updated);
    state = updated;
  }
}

/// In main app
MaterialApp.router(
  themeMode: settings.themeMode,  // ThemeMode.system, .light, or .dark
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
);
```

### Learning Resources for Theming

- 📚 [Material 3 Design](https://m3.material.io/)
- 📺 [Flutter Theming Tutorial](https://www.youtube.com/watch?v=8-szcYzFVao)
- 📝 [ThemeData Class Reference](https://api.flutter.dev/flutter/material/ThemeData-class.html)

---

## 8. Data Models

### Model Structure

```dart
/// File: lib/core/models/transaction_model.dart

class TransactionModel {
  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime dateTime;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor with defaults
  TransactionModel({
    String? id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.dateTime,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),  // Auto-generate ID
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // copyWith for immutable updates
  TransactionModel copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    // ... all fields
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      // ... all fields
    );
  }

  // Optional: JSON serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'type': type.name,
    // ...
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: json['amount'],
      type: TransactionType.values.byName(json['type']),
      // ...
    );
  }
}
```

### Enum Usage

```dart
enum TransactionType {
  expense,
  income,
  transfer,
}

enum AccountType {
  cash,
  bank,
  creditCard,
  wallet,
  investment,
  other,
}

// Usage
if (transaction.type == TransactionType.expense) {
  // Show in red
}
```

---

## 9. UI Components & Widgets

### Stateless vs Stateful Widgets

```dart
// StatelessWidget - No internal state
class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;

  const SummaryCard({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Card(child: Text('$title: $amount'));
  }
}

// StatefulWidget - Has internal state
class TransactionForm extends StatefulWidget {
  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [...]),
    );
  }
}
```

### Common Widget Patterns

```dart
// Container with decoration
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: ...,
)

// List with builder
ListView.builder(
  itemCount: transactions.length,
  itemBuilder: (context, index) {
    final transaction = transactions[index];
    return TransactionTile(transaction: transaction);
  },
)

// Conditional rendering
if (isLoading)
  const CircularProgressIndicator()
else
  ContentWidget()

// Null safety with ??
Text(user?.name ?? 'Guest')
```

### Form Validation

```dart
class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null) {
                return 'Invalid number';
              }
              return null;  // Valid
            },
          ),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, save data
      final amount = double.parse(_amountController.text);
      // ...
    }
  }

  @override
  void dispose() {
    _amountController.dispose();  // Always dispose controllers!
    super.dispose();
  }
}
```

---

## 10. Key Code Patterns

### Singleton Pattern

```dart
class HiveService {
  HiveService._();  // Private constructor
  static final HiveService instance = HiveService._();  // Single instance
}

// Usage
HiveService.instance.transactionsBox.get(id);
```

### Builder Pattern (copyWith)

```dart
final updated = transaction.copyWith(
  amount: 150.0,
  notes: 'Updated notes',
);
```

### Extension Methods

```dart
extension ThemeExtension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

extension DateHelpers on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
```

### Async/Await Pattern

```dart
Future<void> loadData() async {
  setState(() => _isLoading = true);

  try {
    final data = await _fetchData();
    setState(() {
      _data = data;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _error = e.toString();
      _isLoading = false;
    });
  }
}
```

### Modal Bottom Sheet Pattern

```dart
void _showAddOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Content
          ListTile(
            title: const Text('Add Expense'),
            onTap: () {
              Navigator.pop(context);
              context.push('/add-transaction?type=expense');
            },
          ),
        ],
      ),
    ),
  );
}
```

---

## 11. Learning Resources

### Official Documentation

| Resource           | Link                                          |
| ------------------ | --------------------------------------------- |
| Flutter Docs       | [docs.flutter.dev](https://docs.flutter.dev/) |
| Dart Language      | [dart.dev/guides](https://dart.dev/guides)    |
| Material Design    | [m3.material.io](https://m3.material.io/)     |
| Pub.dev (Packages) | [pub.dev](https://pub.dev/)                   |

### Free Courses & Tutorials

| Resource                                                       | Description                  |
| -------------------------------------------------------------- | ---------------------------- |
| [Flutter YouTube Channel](https://www.youtube.com/@flutterdev) | Official tutorials           |
| [Flutter Codelabs](https://docs.flutter.dev/codelabs)          | Hands-on tutorials           |
| [Reso Coder](https://www.youtube.com/@ResoCoder)               | Clean architecture tutorials |
| [Code With Andrea](https://codewithandrea.com/)                | Riverpod & best practices    |
| [FilledStacks](https://www.youtube.com/@FilledStacks)          | Production app tutorials     |
| [The Net Ninja](https://www.youtube.com/c/TheNetNinja)         | Beginner-friendly tutorials  |

### Books

| Book                       | Description         |
| -------------------------- | ------------------- |
| Flutter in Action          | Comprehensive guide |
| Flutter Complete Reference | Deep dive reference |
| Dart Apprentice            | Learn Dart language |

### Practice Projects

After understanding this codebase, try building:

1. **Todo App** - Basic CRUD operations
2. **Weather App** - API integration
3. **Chat App** - Real-time data with Firebase
4. **E-commerce App** - Complex state management
5. **Social Media App** - Full-stack Flutter

### Community

| Platform        | Link                                                              |
| --------------- | ----------------------------------------------------------------- |
| Flutter Discord | [discord.gg/flutter](https://discord.gg/flutter)                  |
| Reddit          | [r/FlutterDev](https://www.reddit.com/r/FlutterDev/)              |
| Stack Overflow  | [flutter tag](https://stackoverflow.com/questions/tagged/flutter) |
| Twitter/X       | [@FlutterDev](https://twitter.com/FlutterDev)                     |

---

## Quick Reference Commands

```bash
# Create new Flutter project
flutter create my_app

# Run app
flutter run

# Run on specific device
flutter run -d chrome
flutter run -d windows
flutter run -d <device_id>

# List connected devices
flutter devices

# Get dependencies
flutter pub get

# Build APK
flutter build apk

# Build iOS
flutter build ios

# Analyze code
flutter analyze

# Run tests
flutter test

# Clean build
flutter clean
```

---

## Summary

This Spendora app demonstrates a production-ready Flutter application with:

✅ **Clean Architecture** - Organized, maintainable code  
✅ **Riverpod** - Modern state management  
✅ **Hive** - Fast local storage  
✅ **GoRouter** - Declarative navigation  
✅ **Material 3** - Modern UI design  
✅ **Charts** - Data visualization  
✅ **Forms** - Input validation  
✅ **Theming** - Light/Dark modes

Study each feature module, understand the patterns, and apply them to your own projects. Happy learning! 🚀

---

_Document created for Spendora v1.0.0_
_Last updated: May 2026_
