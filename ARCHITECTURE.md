# Spendora - Technical Architecture Reference

A detailed technical reference for the Spendora codebase architecture, file structure, and implementation details.

---

## File Structure Reference

### Core Module (`lib/core/`)

```
lib/core/
├── constants/
│   └── app_constants.dart      # App-wide constants (box names, default values)
│
├── models/
│   ├── models.dart             # Barrel file (exports all models)
│   ├── transaction_model.dart  # Transaction data model
│   ├── category_model.dart     # Category data model
│   ├── account_model.dart      # Account data model
│   ├── budget_model.dart       # Budget data model
│   ├── goal_model.dart         # Savings goal data model
│   ├── debt_model.dart         # Debt tracking model
│   ├── currency_model.dart     # Currency data model
│   └── settings_model.dart     # App settings model
│
├── router/
│   └── app_router.dart         # GoRouter configuration & route definitions
│
├── services/
│   ├── hive_service.dart       # Hive database service (singleton)
│   └── hive_adapters.dart      # Manual TypeAdapters for Hive
│
├── theme/
│   └── app_theme.dart          # Light/Dark theme definitions
│
└── utils/
    ├── formatters.dart         # Date, currency, number formatters
    └── helpers.dart            # Utility helper functions
```

### Features Module (`lib/features/`)

Each feature follows the same structure:

```
lib/features/<feature_name>/
├── providers/
│   └── <feature>_provider.dart    # Riverpod providers for state
├── screens/
│   ├── <feature>_screen.dart      # Main screen
│   ├── add_<feature>_screen.dart  # Create/Edit screen
│   └── <feature>_details_screen.dart
└── widgets/
    └── <feature>_widget.dart      # Feature-specific widgets
```

---

## Implementation Details by Feature

### Transactions Feature

**Files:**

- `lib/features/transactions/providers/transactions_provider.dart`
- `lib/features/transactions/screens/transactions_list_screen.dart`
- `lib/features/transactions/screens/add_transaction_screen.dart`
- `lib/features/transactions/screens/transaction_details_screen.dart`

**Providers:**

```dart
// Main transactions list
transactionsProvider → StateNotifierProvider<TransactionsNotifier, List<TransactionModel>>

// Filtering
transactionFilterProvider → StateProvider<TransactionFilter>
filteredMonthlyTransactionsProvider → Provider.family
filteredDailyGroupedTransactionsProvider → Provider.family

// Computed values
monthlyTransactionsProvider → Provider.family
recentTransactionsProvider → Provider
dailyGroupedTransactionsProvider → Provider.family
```

**Key Features:**

- Image attachment support (camera/gallery via image_picker)
- Recurring transactions
- Tags support
- Filter by type (income/expense/transfer)
- Filter by category, account, date range

---

### Accounts Feature

**Files:**

- `lib/features/accounts/providers/accounts_provider.dart`
- `lib/features/accounts/screens/accounts_screen.dart`
- `lib/features/accounts/screens/add_account_screen.dart`

**Providers:**

```dart
accountsProvider → StateNotifierProvider<AccountsNotifier, List<AccountModel>>
accountByIdProvider → Provider.family
totalBalanceProvider → Provider<double>
```

**Account Types:**

- Cash
- Bank Account
- Credit Card
- Wallet (e-wallet)
- Investment
- Other

---

### Categories Feature

**Files:**

- `lib/features/categories/providers/categories_provider.dart`
- `lib/features/categories/screens/categories_screen.dart`
- `lib/features/categories/screens/add_category_screen.dart`

**Providers:**

```dart
categoriesProvider → StateNotifierProvider<CategoriesNotifier, List<CategoryModel>>
expenseCategoriesProvider → Provider (filtered)
incomeCategoriesProvider → Provider (filtered)
categoryByIdProvider → Provider.family
```

**Features:**

- Custom icons
- Custom colors
- Subcategories support
- Parent category linking

---

### Budgets Feature

**Files:**

- `lib/features/budgets/providers/budgets_provider.dart`
- `lib/features/budgets/screens/budgets_screen.dart`
- `lib/features/budgets/screens/add_budget_screen.dart`

**Providers:**

```dart
budgetsProvider → StateNotifierProvider<BudgetsNotifier, List<BudgetModel>>
activeBudgetsProvider → Provider
budgetProgressProvider → Provider.family
```

**Budget Periods:**

- Weekly
- Monthly
- Yearly
- Custom date range

---

### Goals Feature

**Files:**

- `lib/features/goals/providers/goals_provider.dart`
- `lib/features/goals/screens/goals_screen.dart`
- `lib/features/goals/screens/add_goal_screen.dart`

**Providers:**

```dart
goalsProvider → StateNotifierProvider<GoalsNotifier, List<GoalModel>>
activeGoalsProvider → Provider
goalProgressProvider → Provider.family
```

---

### Reports Feature

**Files:**

- `lib/features/reports/providers/reports_provider.dart`
- `lib/features/reports/screens/reports_screen.dart`
- `lib/features/reports/widgets/` (various chart widgets)

**Chart Types (fl_chart):**

- Pie charts (category breakdown)
- Bar charts (daily/monthly comparison)
- Line charts (trend over time)

---

### Settings Feature

**Files:**

- `lib/features/settings/providers/settings_provider.dart`
- `lib/features/settings/screens/settings_screen.dart`
- `lib/features/settings/screens/backup_restore_screen.dart`

**Settings Options:**

- Theme mode (light/dark/system)
- Default currency
- PIN/Biometric lock
- Default account
- Backup & Restore (JSON export)
- Export to PDF/CSV

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                           USER INTERACTION                          │
│                    (Tap button, enter form data)                    │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                              UI LAYER                                │
│              ConsumerWidget / ConsumerStatefulWidget                 │
│                                                                      │
│   ref.watch(provider)  ◄────── Rebuilds UI when state changes       │
│   ref.read(provider.notifier) ──────► Calls methods on notifier     │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                           STATE LAYER                                │
│                     StateNotifierProvider                            │
│                                                                      │
│   TransactionsNotifier                                               │
│   ├── state: List<TransactionModel>                                  │
│   ├── addTransaction()  ────────► Updates Hive + state              │
│   ├── updateTransaction() ──────► Updates Hive + state              │
│   └── deleteTransaction() ──────► Updates Hive + state              │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          SERVICE LAYER                               │
│                        HiveService (Singleton)                       │
│                                                                      │
│   HiveService.instance                                               │
│   ├── transactionsBox.put(id, data)                                  │
│   ├── transactionsBox.get(id)                                        │
│   └── transactionsBox.delete(id)                                     │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                           DATA LAYER                                 │
│                        Hive Database Files                           │
│                                                                      │
│   .hive files stored in app documents directory                      │
│   ├── transactions.hive                                              │
│   ├── categories.hive                                                │
│   ├── accounts.hive                                                  │
│   └── ...                                                            │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Provider Dependency Graph

```
                    ┌─────────────────────┐
                    │  settingsProvider   │
                    │  (SettingsModel)    │
                    └──────────┬──────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
              ▼                ▼                ▼
    ┌─────────────────┐ ┌──────────────┐ ┌─────────────────┐
    │ appRouterProvider│ │ Theme Mode  │ │ currencyProvider│
    │    (GoRouter)    │ │  in App     │ │   (String)      │
    └─────────────────┘ └──────────────┘ └─────────────────┘

              ┌─────────────────────┐
              │ transactionsProvider│
              │ List<Transaction>   │
              └──────────┬──────────┘
                         │
    ┌────────────────────┼────────────────────┐
    │                    │                    │
    ▼                    ▼                    ▼
┌────────────┐  ┌─────────────────┐  ┌──────────────────┐
│ monthly    │  │ recent          │  │ filtered         │
│ Transactions│ │ Transactions    │  │ Transactions     │
└────────────┘  └─────────────────┘  └──────────────────┘
                                              │
                                              ▼
                                    ┌──────────────────┐
                                    │ transactionFilter│
                                    │ Provider         │
                                    └──────────────────┘

              ┌───────────────────┐
              │  accountsProvider │
              │  List<Account>    │
              └─────────┬─────────┘
                        │
                        ▼
              ┌───────────────────┐
              │totalBalanceProvider│
              │     (double)      │
              └───────────────────┘

              ┌────────────────────┐
              │ categoriesProvider │
              │  List<Category>    │
              └─────────┬──────────┘
                        │
          ┌─────────────┼─────────────┐
          ▼             │             ▼
┌──────────────┐        │    ┌──────────────┐
│expenseCateg  │        │    │incomeCateg   │
│ories         │        │    │ories        │
└──────────────┘        │    └──────────────┘
                        ▼
              ┌──────────────────┐
              │ categoryById     │
              │ Provider.family  │
              └──────────────────┘
```

---

## Key Patterns Reference

### 1. Provider with Ref for Cross-Provider Communication

```dart
// In transactions_provider.dart
class TransactionsNotifier extends StateNotifier<List<TransactionModel>> {
  final Ref _ref;  // Store ref to access other providers

  TransactionsNotifier(this._ref) : super([]);

  Future<void> addTransaction(TransactionModel transaction) async {
    // ... save transaction ...

    // Refresh accounts balance after transaction
    _ref.read(accountsProvider.notifier).refresh();
  }
}
```

### 2. Provider.family for Parameterized Providers

```dart
// Get transactions for a specific month
final monthlyTransactionsProvider = Provider.family<List<TransactionModel>, DateTime>(
  (ref, month) {
    final transactions = ref.watch(transactionsProvider);
    final startOfMonth = DateHelpers.startOfMonth(month);
    final endOfMonth = DateHelpers.endOfMonth(month);

    return transactions.where((t) {
      return t.dateTime.isAfter(startOfMonth) &&
             t.dateTime.isBefore(endOfMonth);
    }).toList();
  },
);

// Usage in widget
final transactions = ref.watch(monthlyTransactionsProvider(DateTime.now()));
```

### 3. Computed/Derived Providers

```dart
// Provider that depends on another provider
final totalBalanceProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider);
  return accounts
      .where((a) => !a.excludeFromTotal)
      .fold(0.0, (sum, a) => sum + a.balance);
});

// Filtered list provider
final expenseCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final categories = ref.watch(categoriesProvider);
  return categories.where((c) => c.type == CategoryType.expense).toList();
});
```

### 4. StateProvider for Simple State

```dart
// Simple state for UI
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());
final transactionFilterProvider = StateProvider<TransactionFilter>(
  (ref) => const TransactionFilter(),
);

// Update in widget
ref.read(selectedMonthProvider.notifier).state = newMonth;
```

### 5. Immutable State Updates

```dart
// WRONG - mutating state directly
state.add(newItem);  // ❌

// CORRECT - creating new list
state = [...state, newItem];  // ✅

// For updates
state = state.map((item) =>
  item.id == updatedItem.id ? updatedItem : item
).toList();

// For deletions
state = state.where((item) => item.id != deletedId).toList();
```

---

## Hive Adapter Type IDs

| Type ID | Model/Enum       |
| ------- | ---------------- |
| 0       | TransactionType  |
| 1       | TransactionModel |
| 2       | RecurrenceType   |
| 3       | CategoryType     |
| 4       | CategoryModel    |
| 5       | AccountType      |
| 6       | AccountModel     |
| 7       | BudgetModel      |
| 8       | BudgetPeriod     |
| 9       | GoalModel        |
| 10      | DebtModel        |
| 11      | DebtType         |
| 12      | CurrencyModel    |
| 13      | SettingsModel    |

**Important:** Type IDs must be unique and should never be reused once assigned.

---

## Common Utility Functions

### Date Helpers (`lib/core/utils/formatters.dart`)

```dart
class DateHelpers {
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}
```

### Currency Formatter

```dart
class CurrencyFormatter {
  static String format(double amount, {String currency = 'BDT'}) {
    final formatter = NumberFormat.currency(
      locale: 'en_BD',
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String _getCurrencySymbol(String code) {
    switch (code) {
      case 'BDT': return '৳';
      case 'USD': return '\$';
      case 'EUR': return '€';
      default: return code;
    }
  }
}
```

---

## Testing Patterns

### Unit Testing Providers

```dart
void main() {
  test('totalBalanceProvider calculates correct sum', () {
    final container = ProviderContainer(
      overrides: [
        accountsProvider.overrideWith((ref) => AccountsNotifier()),
      ],
    );

    // Add test accounts
    container.read(accountsProvider.notifier).addAccount(
      AccountModel(name: 'Cash', balance: 1000),
    );
    container.read(accountsProvider.notifier).addAccount(
      AccountModel(name: 'Bank', balance: 5000),
    );

    // Verify total
    expect(container.read(totalBalanceProvider), 6000);

    container.dispose();
  });
}
```

### Widget Testing

```dart
void main() {
  testWidgets('Dashboard shows total balance', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          totalBalanceProvider.overrideWithValue(10000),
        ],
        child: MaterialApp(home: DashboardScreen()),
      ),
    );

    expect(find.text('৳10,000.00'), findsOneWidget);
  });
}
```

---

## Performance Tips

1. **Use `const` constructors** - Reduces widget rebuilds

   ```dart
   const SizedBox(height: 16)  // ✅
   SizedBox(height: 16)        // ❌
   ```

2. **Select specific fields** with `select()`:

   ```dart
   // Only rebuild when name changes
   final name = ref.watch(settingsProvider.select((s) => s.userName));
   ```

3. **Avoid rebuilding entire lists**:

   ```dart
   // Use .family for individual items
   final category = ref.watch(categoryByIdProvider(categoryId));
   ```

4. **Dispose controllers**:

   ```dart
   @override
   void dispose() {
     _controller.dispose();
     super.dispose();
   }
   ```

5. **Use `ListView.builder`** for long lists:
   ```dart
   ListView.builder(
     itemCount: items.length,
     itemBuilder: (context, index) => ItemWidget(items[index]),
   )
   ```

---

## Common Issues & Solutions

| Issue                   | Solution                                  |
| ----------------------- | ----------------------------------------- |
| Hive adapter not found  | Register adapter before opening box       |
| Provider not rebuilding | Use `ref.watch()` instead of `ref.read()` |
| Type ID conflict        | Ensure unique typeId for each adapter     |
| Memory leak             | Dispose controllers in `dispose()` method |
| Widget rebuild loops    | Avoid modifying state in `build()` method |

---

_This document provides technical reference for the Spendora codebase._
