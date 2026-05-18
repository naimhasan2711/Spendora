# Spendora 💰

A complete, production-ready, fully offline Expense Tracker app built with Flutter.

![Flutter](https://img.shields.io/badge/Flutter-3.29+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.7+-0175C2?logo=dart)
![Hive](https://img.shields.io/badge/Hive-4.0+-FFD700)
![Riverpod](https://img.shields.io/badge/Riverpod-2.0+-blue)

## Features

### 📊 Transaction Management

- Track income and expenses
- Multiple categories and subcategories
- Multiple accounts support
- Photo attachments for receipts
- Tags for better organization
- Recurring transactions (daily, weekly, monthly, yearly)
- Payment method tracking

### 💰 Budget Management

- Create budgets by category or overall
- Daily, weekly, monthly, or yearly periods
- Visual progress indicators
- Budget alerts and notifications

### 🎯 Savings Goals

- Set financial goals with target amounts
- Track progress with visual indicators
- Target date reminders
- Add money to goals

### 💳 Debt Tracking

- Track borrowed and lent money
- Payment history
- Due date reminders
- Overdue alerts

### 📈 Reports & Analytics

- Monthly/yearly overview
- Category breakdown with pie charts
- Spending trends with line charts
- Income vs expense comparison

### 📅 Calendar View

- Visual transaction calendar
- Daily transaction summary
- Quick date navigation

### 🔍 Search & Filters

- Full-text search across transactions
- Filter by date range, category, account
- Quick filters for common searches

### ⚙️ Settings & Customization

- Light/Dark theme
- Custom accent colors
- Multiple currency support (BDT default)
- Date/time format options
- PIN/Biometric app lock

### 💾 Data Management

- Local backup & restore
- CSV export
- PDF report generation
- Auto-backup option

## Screenshots

_Coming soon_

## Installation

### Prerequisites

- Flutter SDK 3.29+
- Dart SDK 3.7+
- Android Studio / VS Code

### Steps

1. Clone the repository:

```bash
git clone https://github.com/yourusername/spendora.git
cd spendora
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

### Build APK

```bash
flutter build apk --release
```

### Build iOS

```bash
flutter build ios --release
```

## Architecture

### Folder Structure

```
lib/
├── main.dart                  # App entry point
├── core/                      # Core utilities
│   ├── constants/            # App constants
│   ├── models/               # Data models
│   ├── router/               # GoRouter configuration
│   ├── services/             # Hive database service
│   ├── theme/                # App theme
│   └── utils/                # Formatters & utilities
└── features/                 # Feature modules
    ├── splash/               # Splash screen
    ├── onboarding/           # Onboarding flow
    ├── auth/                 # PIN/biometric auth
    ├── home/                 # Dashboard & main screen
    ├── transactions/         # Transaction management
    ├── categories/           # Category management
    ├── accounts/             # Account management
    ├── budgets/              # Budget tracking
    ├── goals/                # Savings goals
    ├── debts/                # Debt tracking
    ├── reports/              # Analytics & reports
    ├── calendar/             # Calendar view
    ├── search/               # Search functionality
    └── settings/             # App settings
```

### State Management

- **Riverpod 2.0** with StateNotifierProvider pattern
- Immutable state objects
- Derived providers for computed values

### Database

- **Hive** for local storage
- Manual TypeAdapters for custom types
- Offline-first architecture

### Navigation

- **GoRouter** for declarative routing
- Named routes with type-safe parameters

### UI/UX

- **Material 3** design
- Custom theming with light/dark modes
- Smooth animations with flutter_animate
- Responsive layouts

## Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.5.1 # State management
  hive: ^4.0.0 # Local database
  hive_flutter: ^1.1.0 # Hive Flutter integration
  go_router: ^14.6.2 # Navigation
  fl_chart: ^0.69.2 # Charts
  table_calendar: ^3.1.3 # Calendar
  flutter_slidable: ^3.1.1 # Swipe actions
  percent_indicator: ^4.2.3 # Progress indicators
  local_auth: ^2.3.0 # Biometric auth
  image_picker: ^1.1.2 # Photo picker
  intl: ^0.20.1 # Formatting
  uuid: ^4.5.1 # Unique IDs
  pdf: ^3.11.1 # PDF generation
  csv: ^6.0.0 # CSV export
  path_provider: ^2.1.4 # File paths
  share_plus: ^10.1.4 # Sharing
  flutter_animate: ^4.5.0 # Animations
  smooth_page_indicator: ^1.2.0 # Page indicators
  flex_color_picker: ^3.6.0 # Color picker
```

## Data Models

### TransactionModel

- Amount, type (income/expense), category, account
- Date/time, notes, tags, photos
- Recurrence settings, payment method

### CategoryModel

- Name, icon, color, type
- Subcategories support

### AccountModel

- Name, type, balance, icon, color
- Exclude from total option

### BudgetModel

- Name, amount, period
- Category-specific or overall
- Progress tracking

### GoalModel

- Name, target amount, saved amount
- Target date, notes, progress

### DebtModel

- Person name, amount, type (borrowed/lent)
- Due date, payment history

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Flutter](https://flutter.dev) - UI framework
- [Riverpod](https://riverpod.dev) - State management
- [Hive](https://docs.hivedb.dev) - Local database
- [Material Design 3](https://m3.material.io) - Design system

---

Made with ❤️ using Flutter
