import 'package:uuid/uuid.dart';

/// Goal Model for Savings Targets
class GoalModel {
  final String id;
  final String name;
  final String? notes;
  final double targetAmount;
  final double savedAmount;
  final DateTime? targetDate;
  final int iconCodePoint;
  final int colorValue;
  final String? imageUrl;
  final bool isCompleted;
  final String currencyCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  GoalModel({
    String? id,
    required this.name,
    this.notes,
    required this.targetAmount,
    this.savedAmount = 0.0,
    this.targetDate,
    required this.iconCodePoint,
    required this.colorValue,
    this.imageUrl,
    this.isCompleted = false,
    this.currencyCode = 'BDT',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Calculate progress percentage
  double get progress =>
      targetAmount > 0 ? (savedAmount / targetAmount * 100).clamp(0, 100) : 0;

  /// Remaining amount
  double get remaining =>
      (targetAmount - savedAmount).clamp(0, double.infinity);

  /// Check if goal is achieved
  bool get isAchieved => savedAmount >= targetAmount;

  /// Days remaining to target date
  int? get daysRemaining {
    if (targetDate == null) return null;
    return targetDate!.difference(DateTime.now()).inDays;
  }

  /// Required daily savings to reach goal
  double? get dailySavingsRequired {
    if (targetDate == null || daysRemaining == null || daysRemaining! <= 0) {
      return null;
    }
    return remaining / daysRemaining!;
  }

  GoalModel copyWith({
    String? id,
    String? name,
    String? notes,
    double? targetAmount,
    double? savedAmount,
    DateTime? targetDate,
    int? iconCodePoint,
    int? colorValue,
    String? imageUrl,
    bool? isCompleted,
    String? currencyCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      imageUrl: imageUrl ?? this.imageUrl,
      isCompleted: isCompleted ?? this.isCompleted,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'targetDate': targetDate?.toIso8601String(),
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'imageUrl': imageUrl,
      'isCompleted': isCompleted,
      'currencyCode': currencyCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      notes: json['notes'] as String?,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      iconCodePoint: json['iconCodePoint'] as int,
      colorValue: json['colorValue'] as int,
      imageUrl: json['imageUrl'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      currencyCode: json['currencyCode'] as String? ?? 'BDT',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'GoalModel(id: $id, name: $name, targetAmount: $targetAmount, savedAmount: $savedAmount)';
  }
}
