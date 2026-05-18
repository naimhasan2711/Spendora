import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/pin_screen.dart';
import '../../features/home/screens/main_screen.dart';
import '../../features/transactions/screens/add_transaction_screen.dart';
import '../../features/transactions/screens/transaction_details_screen.dart';
import '../../features/transactions/screens/all_transactions_screen.dart';
import '../../features/categories/screens/categories_screen.dart';
import '../../features/categories/screens/add_category_screen.dart';
import '../../features/accounts/screens/accounts_screen.dart';
import '../../features/accounts/screens/add_account_screen.dart';
import '../../features/budgets/screens/budgets_screen.dart';
import '../../features/budgets/screens/add_budget_screen.dart';
import '../../features/goals/screens/goals_screen.dart';
import '../../features/goals/screens/add_goal_screen.dart';
import '../../features/debts/screens/debts_screen.dart';
import '../../features/debts/screens/add_debt_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/backup_restore_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/search/screens/search_screen.dart';

/// Route names
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String pin = '/pin';
  static const String home = '/home';
  static const String addTransaction = '/add-transaction';
  static const String editTransaction = '/edit-transaction/:id';
  static const String transactionDetails = '/transaction/:id';
  static const String allTransactions = '/transactions';
  static const String categories = '/categories';
  static const String addCategory = '/add-category';
  static const String editCategory = '/edit-category/:id';
  static const String accounts = '/accounts';
  static const String addAccount = '/add-account';
  static const String editAccount = '/edit-account/:id';
  static const String budgets = '/budgets';
  static const String addBudget = '/add-budget';
  static const String editBudget = '/edit-budget/:id';
  static const String goals = '/goals';
  static const String addGoal = '/add-goal';
  static const String editGoal = '/edit-goal/:id';
  static const String debts = '/debts';
  static const String addDebt = '/add-debt';
  static const String editDebt = '/edit-debt/:id';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String backupRestore = '/backup-restore';
  static const String calendar = '/calendar';
  static const String search = '/search';
}

/// GoRouter Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // PIN Screen
      GoRoute(
        path: AppRoutes.pin,
        name: 'pin',
        builder: (context, state) {
          final isSetup = state.uri.queryParameters['setup'] == 'true';
          return PinScreen(isSetup: isSetup);
        },
      ),

      // Main Screen (Home with Bottom Navigation)
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const MainScreen(),
      ),

      // Add Transaction
      GoRoute(
        path: AppRoutes.addTransaction,
        name: 'addTransaction',
        builder: (context, state) {
          final isIncome = state.uri.queryParameters['type'] == 'income';
          return AddTransactionScreen(isIncome: isIncome);
        },
      ),

      // Edit Transaction
      GoRoute(
        path: AppRoutes.editTransaction,
        name: 'editTransaction',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AddTransactionScreen(transactionId: id);
        },
      ),

      // Transaction Details
      GoRoute(
        path: AppRoutes.transactionDetails,
        name: 'transactionDetails',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TransactionDetailsScreen(transactionId: id);
        },
      ),

      // All Transactions
      GoRoute(
        path: AppRoutes.allTransactions,
        name: 'allTransactions',
        builder: (context, state) => const AllTransactionsScreen(),
      ),

      // Categories
      GoRoute(
        path: AppRoutes.categories,
        name: 'categories',
        builder: (context, state) => const CategoriesScreen(),
      ),

      // Add Category
      GoRoute(
        path: AppRoutes.addCategory,
        name: 'addCategory',
        builder: (context, state) => const AddCategoryScreen(),
      ),

      // Accounts
      GoRoute(
        path: AppRoutes.accounts,
        name: 'accounts',
        builder: (context, state) => const AccountsScreen(),
      ),

      // Add Account
      GoRoute(
        path: AppRoutes.addAccount,
        name: 'addAccount',
        builder: (context, state) => const AddAccountScreen(),
      ),

      // Budgets
      GoRoute(
        path: AppRoutes.budgets,
        name: 'budgets',
        builder: (context, state) => const BudgetsScreen(),
      ),

      // Add Budget
      GoRoute(
        path: AppRoutes.addBudget,
        name: 'addBudget',
        builder: (context, state) => const AddBudgetScreen(),
      ),

      // Goals
      GoRoute(
        path: AppRoutes.goals,
        name: 'goals',
        builder: (context, state) => const GoalsScreen(),
      ),

      // Add Goal
      GoRoute(
        path: AppRoutes.addGoal,
        name: 'addGoal',
        builder: (context, state) => const AddGoalScreen(),
      ),

      // Debts
      GoRoute(
        path: AppRoutes.debts,
        name: 'debts',
        builder: (context, state) => const DebtsScreen(),
      ),

      // Add Debt
      GoRoute(
        path: AppRoutes.addDebt,
        name: 'addDebt',
        builder: (context, state) => const AddDebtScreen(),
      ),

      // Reports
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        builder: (context, state) => const ReportsScreen(),
      ),

      // Settings
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Backup & Restore
      GoRoute(
        path: AppRoutes.backupRestore,
        name: 'backupRestore',
        builder: (context, state) => const BackupRestoreScreen(),
      ),

      // Calendar View
      GoRoute(
        path: AppRoutes.calendar,
        name: 'calendar',
        builder: (context, state) => const CalendarScreen(),
      ),

      // Search
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
