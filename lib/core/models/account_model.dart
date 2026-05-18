import 'package:uuid/uuid.dart';

/// Account Type Enum
enum AccountType {
  cash,
  bank,
  wallet,
  creditCard,
  savings,
  investment,
  other,
}

/// Account Model
class AccountModel {
  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final double initialBalance;
  final int iconCodePoint;
  final int colorValue;
  final String currencyCode;
  final bool isDefault;
  final bool excludeFromTotal;
  final String? description;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccountModel({
    String? id,
    required this.name,
    required this.type,
    this.balance = 0.0,
    this.initialBalance = 0.0,
    required this.iconCodePoint,
    required this.colorValue,
    this.currencyCode = 'BDT',
    this.isDefault = false,
    this.excludeFromTotal = false,
    this.description,
    this.order = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? balance,
    double? initialBalance,
    int? iconCodePoint,
    int? colorValue,
    String? currencyCode,
    bool? isDefault,
    bool? excludeFromTotal,
    String? description,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      initialBalance: initialBalance ?? this.initialBalance,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      currencyCode: currencyCode ?? this.currencyCode,
      isDefault: isDefault ?? this.isDefault,
      excludeFromTotal: excludeFromTotal ?? this.excludeFromTotal,
      description: description ?? this.description,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'balance': balance,
      'initialBalance': initialBalance,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'currencyCode': currencyCode,
      'isDefault': isDefault,
      'excludeFromTotal': excludeFromTotal,
      'description': description,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: AccountType.values[json['type'] as int],
      balance: (json['balance'] as num).toDouble(),
      initialBalance: (json['initialBalance'] as num).toDouble(),
      iconCodePoint: json['iconCodePoint'] as int,
      colorValue: json['colorValue'] as int,
      currencyCode: json['currencyCode'] as String? ?? 'BDT',
      isDefault: json['isDefault'] as bool? ?? false,
      excludeFromTotal: json['excludeFromTotal'] as bool? ?? false,
      description: json['description'] as String?,
      order: json['order'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String get typeDisplayName {
    switch (type) {
      case AccountType.cash:
        return 'Cash';
      case AccountType.bank:
        return 'Bank Account';
      case AccountType.wallet:
        return 'Digital Wallet';
      case AccountType.creditCard:
        return 'Credit Card';
      case AccountType.savings:
        return 'Savings';
      case AccountType.investment:
        return 'Investment';
      case AccountType.other:
        return 'Other';
    }
  }

  @override
  String toString() {
    return 'AccountModel(id: $id, name: $name, type: $type, balance: $balance)';
  }
}

/// Default Accounts for Bangladesh
class DefaultAccounts {
  DefaultAccounts._();

  static List<AccountModel> get accounts => [
        AccountModel(
          id: 'cash',
          name: 'Cash',
          type: AccountType.cash,
          iconCodePoint: 0xe850, // account_balance_wallet
          colorValue: 0xFF4CAF50,
          isDefault: true,
        ),
        AccountModel(
          id: 'bkash',
          name: 'bKash',
          type: AccountType.wallet,
          iconCodePoint: 0xe0d0, // phone_android
          colorValue: 0xFFE2136E,
        ),
        AccountModel(
          id: 'nagad',
          name: 'Nagad',
          type: AccountType.wallet,
          iconCodePoint: 0xe0d0,
          colorValue: 0xFFFF6B00,
        ),
        AccountModel(
          id: 'rocket',
          name: 'Rocket',
          type: AccountType.wallet,
          iconCodePoint: 0xe0d0,
          colorValue: 0xFF8B2E8B,
        ),
        AccountModel(
          id: 'bank',
          name: 'Bank Account',
          type: AccountType.bank,
          iconCodePoint: 0xe84f, // account_balance
          colorValue: 0xFF2196F3,
        ),
        AccountModel(
          id: 'credit_card',
          name: 'Credit Card',
          type: AccountType.creditCard,
          iconCodePoint: 0xe870, // credit_card
          colorValue: 0xFF9C27B0,
        ),
      ];
}
