import 'package:uuid/uuid.dart';

/// Budget Period Enum
enum BudgetPeriod {
  daily,
  weekly,
  monthly,
  yearly,
  custom,
}

/// Budget Model
class BudgetModel {
  final String id;
  final String name;
  final double amount;
  final double spent;
  final String? categoryId; // null for overall budget
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final bool notificationEnabled;
  final double notifyAtPercent;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetModel({
    String? id,
    required this.name,
    required this.amount,
    this.spent = 0.0,
    this.categoryId,
    required this.period,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.notificationEnabled = true,
    this.notifyAtPercent = 80.0,
    this.colorValue = 0xFF0D4A3E,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Calculate progress percentage
  double get progress => amount > 0 ? (spent / amount * 100).clamp(0, 100) : 0;

  /// Check if budget is exceeded
  bool get isExceeded => spent > amount;

  /// Check if approaching limit
  bool get isApproachingLimit => progress >= notifyAtPercent && !isExceeded;

  /// Remaining amount
  double get remaining => (amount - spent).clamp(0, double.infinity);

  /// Check if budget period is current
  bool get isCurrent {
    final now = DateTime.now();
    if (endDate == null) return now.isAfter(startDate);
    return now.isAfter(startDate) && now.isBefore(endDate!);
  }

  BudgetModel copyWith({
    String? id,
    String? name,
    double? amount,
    double? spent,
    String? categoryId,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? notificationEnabled,
    double? notifyAtPercent,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      categoryId: categoryId ?? this.categoryId,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notifyAtPercent: notifyAtPercent ?? this.notifyAtPercent,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'spent': spent,
      'categoryId': categoryId,
      'period': period.index,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'notificationEnabled': notificationEnabled,
      'notifyAtPercent': notifyAtPercent,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      categoryId: json['categoryId'] as String?,
      period: BudgetPeriod.values[json['period'] as int],
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      notificationEnabled: json['notificationEnabled'] as bool? ?? true,
      notifyAtPercent: (json['notifyAtPercent'] as num?)?.toDouble() ?? 80.0,
      colorValue: json['colorValue'] as int? ?? 0xFF0D4A3E,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'BudgetModel(id: $id, name: $name, amount: $amount, spent: $spent)';
  }
}
