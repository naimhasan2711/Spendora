import 'package:uuid/uuid.dart';

/// Transaction Type Enum
enum TransactionType {
  expense,
  income,
  transfer,
}

/// Recurrence Type Enum
enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
  custom,
}

/// Transaction Model
class TransactionModel {
  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String? subcategoryId;
  final DateTime dateTime;
  final String? notes;
  final String accountId;
  final String? toAccountId; // For transfers
  final String paymentMethod;
  final List<String> tags;
  final String? imagePath;
  final RecurrenceType recurrence;
  final int? recurrenceInterval; // For custom recurrence
  final DateTime? recurrenceEndDate;
  final String? parentTransactionId; // For recurring transactions
  final String currencyCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    String? id,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.subcategoryId,
    required this.dateTime,
    this.notes,
    required this.accountId,
    this.toAccountId,
    required this.paymentMethod,
    List<String>? tags,
    this.imagePath,
    this.recurrence = RecurrenceType.none,
    this.recurrenceInterval,
    this.recurrenceEndDate,
    this.parentTransactionId,
    this.currencyCode = 'BDT',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  TransactionModel copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? subcategoryId,
    DateTime? dateTime,
    String? notes,
    String? accountId,
    String? toAccountId,
    String? paymentMethod,
    List<String>? tags,
    String? imagePath,
    RecurrenceType? recurrence,
    int? recurrenceInterval,
    DateTime? recurrenceEndDate,
    String? parentTransactionId,
    String? currencyCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      tags: tags ?? this.tags,
      imagePath: imagePath ?? this.imagePath,
      recurrence: recurrence ?? this.recurrence,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      parentTransactionId: parentTransactionId ?? this.parentTransactionId,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.index,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
      'accountId': accountId,
      'toAccountId': toAccountId,
      'paymentMethod': paymentMethod,
      'tags': tags,
      'imagePath': imagePath,
      'recurrence': recurrence.index,
      'recurrenceInterval': recurrenceInterval,
      'recurrenceEndDate': recurrenceEndDate?.toIso8601String(),
      'parentTransactionId': parentTransactionId,
      'currencyCode': currencyCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values[json['type'] as int],
      categoryId: json['categoryId'] as String,
      subcategoryId: json['subcategoryId'] as String?,
      dateTime: DateTime.parse(json['dateTime'] as String),
      notes: json['notes'] as String?,
      accountId: json['accountId'] as String,
      toAccountId: json['toAccountId'] as String?,
      paymentMethod: json['paymentMethod'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      imagePath: json['imagePath'] as String?,
      recurrence: RecurrenceType.values[json['recurrence'] as int? ?? 0],
      recurrenceInterval: json['recurrenceInterval'] as int?,
      recurrenceEndDate: json['recurrenceEndDate'] != null
          ? DateTime.parse(json['recurrenceEndDate'] as String)
          : null,
      parentTransactionId: json['parentTransactionId'] as String?,
      currencyCode: json['currencyCode'] as String? ?? 'BDT',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, amount: $amount, type: $type, categoryId: $categoryId, dateTime: $dateTime)';
  }
}
