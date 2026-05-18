import 'package:uuid/uuid.dart';

/// Debt Type Enum
enum DebtType {
  borrowed, // Money I borrowed (I owe)
  lent, // Money I lent (Others owe me)
}

/// Debt Model for tracking borrowed and lent money
class DebtModel {
  final String id;
  final String personName;
  final String? personContact;
  final DebtType type;
  final double amount;
  final double paidAmount;
  final String? description;
  final DateTime date;
  final DateTime? dueDate;
  final bool isSettled;
  final String currencyCode;
  final String? accountId;
  final List<DebtPaymentModel> payments;
  final DateTime createdAt;
  final DateTime updatedAt;

  DebtModel({
    String? id,
    required this.personName,
    this.personContact,
    required this.type,
    required this.amount,
    this.paidAmount = 0.0,
    this.description,
    required this.date,
    this.dueDate,
    this.isSettled = false,
    this.currencyCode = 'BDT',
    this.accountId,
    List<DebtPaymentModel>? payments,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        payments = payments ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Remaining amount
  double get remaining => (amount - paidAmount).clamp(0, double.infinity);

  /// Progress percentage
  double get progress =>
      amount > 0 ? (paidAmount / amount * 100).clamp(0, 100) : 0;

  /// Check if overdue
  bool get isOverdue {
    if (dueDate == null || isSettled) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Days until due date (negative if overdue)
  int? get daysUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  DebtModel copyWith({
    String? id,
    String? personName,
    String? personContact,
    DebtType? type,
    double? amount,
    double? paidAmount,
    String? description,
    DateTime? date,
    DateTime? dueDate,
    bool? isSettled,
    String? currencyCode,
    List<DebtPaymentModel>? payments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DebtModel(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      personContact: personContact ?? this.personContact,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      description: description ?? this.description,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      isSettled: isSettled ?? this.isSettled,
      currencyCode: currencyCode ?? this.currencyCode,
      payments: payments ?? this.payments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personName': personName,
      'personContact': personContact,
      'type': type.index,
      'amount': amount,
      'paidAmount': paidAmount,
      'description': description,
      'date': date.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isSettled': isSettled,
      'currencyCode': currencyCode,
      'payments': payments.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'] as String,
      personName: json['personName'] as String,
      personContact: json['personContact'] as String?,
      type: DebtType.values[json['type'] as int],
      amount: (json['amount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      isSettled: json['isSettled'] as bool? ?? false,
      currencyCode: json['currencyCode'] as String? ?? 'BDT',
      payments: (json['payments'] as List<dynamic>?)
              ?.map((e) => DebtPaymentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'DebtModel(id: $id, personName: $personName, type: $type, amount: $amount)';
  }
}

/// Debt Payment Model
class DebtPaymentModel {
  final String id;
  final double amount;
  final DateTime date;
  final String? note;

  DebtPaymentModel({
    String? id,
    required this.amount,
    required this.date,
    this.note,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory DebtPaymentModel.fromJson(Map<String, dynamic> json) {
    return DebtPaymentModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }
}
