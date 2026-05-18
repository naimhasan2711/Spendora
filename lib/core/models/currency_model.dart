/// Currency Model
class CurrencyModel {
  final String code;
  final String name;
  final String symbol;
  final double exchangeRate; // Rate relative to BDT
  final bool isDefault;
  final DateTime lastUpdated;

  CurrencyModel({
    required this.code,
    required this.name,
    required this.symbol,
    required this.exchangeRate,
    this.isDefault = false,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  CurrencyModel copyWith({
    String? code,
    String? name,
    String? symbol,
    double? exchangeRate,
    bool? isDefault,
    DateTime? lastUpdated,
  }) {
    return CurrencyModel(
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      isDefault: isDefault ?? this.isDefault,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'exchangeRate': exchangeRate,
      'isDefault': isDefault,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      code: json['code'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  /// Format amount with currency symbol
  String format(double amount) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'CurrencyModel(code: $code, name: $name, symbol: $symbol)';
  }
}

/// Default Currencies
class DefaultCurrencies {
  DefaultCurrencies._();

  static List<CurrencyModel> get currencies => [
        CurrencyModel(
          code: 'BDT',
          name: 'Bangladeshi Taka',
          symbol: '৳',
          exchangeRate: 1.0,
          isDefault: true,
        ),
        CurrencyModel(
          code: 'USD',
          name: 'US Dollar',
          symbol: '\$',
          exchangeRate: 0.0091, // 1 BDT = 0.0091 USD
        ),
        CurrencyModel(
          code: 'EUR',
          name: 'Euro',
          symbol: '€',
          exchangeRate: 0.0084,
        ),
        CurrencyModel(
          code: 'GBP',
          name: 'British Pound',
          symbol: '£',
          exchangeRate: 0.0072,
        ),
        CurrencyModel(
          code: 'INR',
          name: 'Indian Rupee',
          symbol: '₹',
          exchangeRate: 0.76,
        ),
        CurrencyModel(
          code: 'AED',
          name: 'UAE Dirham',
          symbol: 'د.إ',
          exchangeRate: 0.033,
        ),
        CurrencyModel(
          code: 'SAR',
          name: 'Saudi Riyal',
          symbol: '﷼',
          exchangeRate: 0.034,
        ),
        CurrencyModel(
          code: 'MYR',
          name: 'Malaysian Ringgit',
          symbol: 'RM',
          exchangeRate: 0.043,
        ),
        CurrencyModel(
          code: 'SGD',
          name: 'Singapore Dollar',
          symbol: 'S\$',
          exchangeRate: 0.012,
        ),
        CurrencyModel(
          code: 'JPY',
          name: 'Japanese Yen',
          symbol: '¥',
          exchangeRate: 1.36,
        ),
      ];
}
