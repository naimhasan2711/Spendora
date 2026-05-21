import 'package:hive/hive.dart';
import '../models/models.dart';

// ============ ENUM ADAPTERS ============

/// TransactionType Adapter
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

/// RecurrenceType Adapter
class RecurrenceTypeAdapter extends TypeAdapter<RecurrenceType> {
  @override
  final int typeId = 1;

  @override
  RecurrenceType read(BinaryReader reader) {
    return RecurrenceType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, RecurrenceType obj) {
    writer.writeByte(obj.index);
  }
}

/// AccountType Adapter
class AccountTypeAdapter extends TypeAdapter<AccountType> {
  @override
  final int typeId = 5;

  @override
  AccountType read(BinaryReader reader) {
    return AccountType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, AccountType obj) {
    writer.writeByte(obj.index);
  }
}

/// BudgetPeriod Adapter
class BudgetPeriodAdapter extends TypeAdapter<BudgetPeriod> {
  @override
  final int typeId = 7;

  @override
  BudgetPeriod read(BinaryReader reader) {
    return BudgetPeriod.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, BudgetPeriod obj) {
    writer.writeByte(obj.index);
  }
}

/// DebtType Adapter
class DebtTypeAdapter extends TypeAdapter<DebtType> {
  @override
  final int typeId = 10;

  @override
  DebtType read(BinaryReader reader) {
    return DebtType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, DebtType obj) {
    writer.writeByte(obj.index);
  }
}

// ============ MODEL ADAPTERS ============

/// TransactionModel Adapter
class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 2;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      id: fields[0] as String?,
      amount: fields[1] as double,
      type: fields[2] as TransactionType,
      categoryId: fields[3] as String,
      subcategoryId: fields[4] as String?,
      dateTime: fields[5] as DateTime,
      notes: fields[6] as String?,
      accountId: fields[7] as String,
      toAccountId: fields[8] as String?,
      paymentMethod: fields[9] as String,
      tags: (fields[10] as List?)?.cast<String>(),
      imagePath: fields[11] as String?,
      recurrence: fields[12] as RecurrenceType? ?? RecurrenceType.none,
      recurrenceInterval: fields[13] as int?,
      recurrenceEndDate: fields[14] as DateTime?,
      parentTransactionId: fields[15] as String?,
      currencyCode: fields[16] as String? ?? 'BDT',
      createdAt: fields[17] as DateTime?,
      updatedAt: fields[18] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.subcategoryId)
      ..writeByte(5)
      ..write(obj.dateTime)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.accountId)
      ..writeByte(8)
      ..write(obj.toAccountId)
      ..writeByte(9)
      ..write(obj.paymentMethod)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.imagePath)
      ..writeByte(12)
      ..write(obj.recurrence)
      ..writeByte(13)
      ..write(obj.recurrenceInterval)
      ..writeByte(14)
      ..write(obj.recurrenceEndDate)
      ..writeByte(15)
      ..write(obj.parentTransactionId)
      ..writeByte(16)
      ..write(obj.currencyCode)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.updatedAt);
  }
}

/// CategoryModel Adapter
class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 3;

  @override
  CategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      iconCodePoint: fields[2] as int,
      colorValue: fields[3] as int,
      type: fields[4] as TransactionType,
      isDefault: fields[5] as bool? ?? false,
      subcategories: (fields[6] as List?)?.cast<SubcategoryModel>(),
      order: fields[7] as int? ?? 0,
      createdAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconCodePoint)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.isDefault)
      ..writeByte(6)
      ..write(obj.subcategories)
      ..writeByte(7)
      ..write(obj.order)
      ..writeByte(8)
      ..write(obj.createdAt);
  }
}

/// SubcategoryModel Adapter
class SubcategoryModelAdapter extends TypeAdapter<SubcategoryModel> {
  @override
  final int typeId = 4;

  @override
  SubcategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubcategoryModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      iconCodePoint: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SubcategoryModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconCodePoint);
  }
}

/// AccountModel Adapter
class AccountModelAdapter extends TypeAdapter<AccountModel> {
  @override
  final int typeId = 6;

  @override
  AccountModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AccountModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      type: fields[2] as AccountType,
      balance: fields[3] as double? ?? 0.0,
      initialBalance: fields[4] as double? ?? 0.0,
      iconCodePoint: fields[5] as int,
      colorValue: fields[6] as int,
      currencyCode: fields[7] as String? ?? 'BDT',
      isDefault: fields[8] as bool? ?? false,
      excludeFromTotal: !(fields[9] as bool? ?? true),
      description: fields[10] as String?,
      order: fields[11] as int? ?? 0,
      createdAt: fields[12] as DateTime?,
      updatedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AccountModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.balance)
      ..writeByte(4)
      ..write(obj.initialBalance)
      ..writeByte(5)
      ..write(obj.iconCodePoint)
      ..writeByte(6)
      ..write(obj.colorValue)
      ..writeByte(7)
      ..write(obj.currencyCode)
      ..writeByte(8)
      ..write(obj.isDefault)
      ..writeByte(9)
      ..write(!obj.excludeFromTotal)
      ..writeByte(10)
      ..write(obj.description)
      ..writeByte(11)
      ..write(obj.order)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }
}

/// BudgetModel Adapter
class BudgetModelAdapter extends TypeAdapter<BudgetModel> {
  @override
  final int typeId = 8;

  @override
  BudgetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      amount: fields[2] as double,
      spent: fields[3] as double? ?? 0.0,
      categoryId: fields[4] as String?,
      period: fields[5] as BudgetPeriod,
      startDate: fields[6] as DateTime,
      endDate: fields[7] as DateTime?,
      isActive: fields[8] as bool? ?? true,
      notificationEnabled: fields[9] as bool? ?? true,
      notifyAtPercent: fields[10] as double? ?? 80.0,
      colorValue: fields[11] as int? ?? 0xFF0D4A3E,
      createdAt: fields[12] as DateTime?,
      updatedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.spent)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.period)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.endDate)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.notificationEnabled)
      ..writeByte(10)
      ..write(obj.notifyAtPercent)
      ..writeByte(11)
      ..write(obj.colorValue)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }
}

/// GoalModel Adapter
class GoalModelAdapter extends TypeAdapter<GoalModel> {
  @override
  final int typeId = 9;

  @override
  GoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      notes: fields[2] as String?,
      targetAmount: fields[3] as double,
      savedAmount: fields[4] as double? ?? 0.0,
      targetDate: fields[5] as DateTime?,
      iconCodePoint: fields[6] as int,
      colorValue: fields[7] as int,
      imageUrl: fields[8] as String?,
      isCompleted: fields[9] as bool? ?? false,
      currencyCode: fields[10] as String? ?? 'BDT',
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, GoalModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.targetAmount)
      ..writeByte(4)
      ..write(obj.savedAmount)
      ..writeByte(5)
      ..write(obj.targetDate)
      ..writeByte(6)
      ..write(obj.iconCodePoint)
      ..writeByte(7)
      ..write(obj.colorValue)
      ..writeByte(8)
      ..write(obj.imageUrl)
      ..writeByte(9)
      ..write(obj.isCompleted)
      ..writeByte(10)
      ..write(obj.currencyCode)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }
}

/// DebtModel Adapter
class DebtModelAdapter extends TypeAdapter<DebtModel> {
  @override
  final int typeId = 11;

  @override
  DebtModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DebtModel(
      id: fields[0] as String?,
      personName: fields[1] as String,
      personContact: fields[2] as String?,
      type: fields[3] as DebtType,
      amount: fields[4] as double,
      paidAmount: fields[5] as double? ?? 0.0,
      description: fields[6] as String?,
      date: fields[7] as DateTime,
      dueDate: fields[8] as DateTime?,
      isSettled: fields[9] as bool? ?? false,
      currencyCode: fields[10] as String? ?? 'BDT',
      payments: (fields[11] as List?)?.cast<DebtPaymentModel>(),
      createdAt: fields[12] as DateTime?,
      updatedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DebtModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.personName)
      ..writeByte(2)
      ..write(obj.personContact)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.paidAmount)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.date)
      ..writeByte(8)
      ..write(obj.dueDate)
      ..writeByte(9)
      ..write(obj.isSettled)
      ..writeByte(10)
      ..write(obj.currencyCode)
      ..writeByte(11)
      ..write(obj.payments)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }
}

/// DebtPaymentModel Adapter
class DebtPaymentModelAdapter extends TypeAdapter<DebtPaymentModel> {
  @override
  final int typeId = 12;

  @override
  DebtPaymentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DebtPaymentModel(
      id: fields[0] as String?,
      amount: fields[1] as double,
      date: fields[2] as DateTime,
      note: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DebtPaymentModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.note);
  }
}

/// CurrencyModel Adapter
class CurrencyModelAdapter extends TypeAdapter<CurrencyModel> {
  @override
  final int typeId = 13;

  @override
  CurrencyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrencyModel(
      code: fields[0] as String,
      name: fields[1] as String,
      symbol: fields[2] as String,
      exchangeRate: fields[3] as double,
      isDefault: fields[4] as bool? ?? false,
      lastUpdated: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CurrencyModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.symbol)
      ..writeByte(3)
      ..write(obj.exchangeRate)
      ..writeByte(4)
      ..write(obj.isDefault)
      ..writeByte(5)
      ..write(obj.lastUpdated);
  }
}

/// SettingsModel Adapter
class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 14;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      themeModeIndex: fields[0] as int? ?? 0,
      defaultCurrency: fields[1] as String? ?? 'BDT',
      defaultAccountId: fields[2] as String? ?? 'cash',
      pinEnabled: fields[3] as bool? ?? false,
      pinCode: fields[4] as String?,
      biometricEnabled: fields[5] as bool? ?? false,
      onboardingComplete: fields[6] as bool? ?? false,
      firstLaunch: fields[7] as bool? ?? true,
      dateFormat: fields[8] as String? ?? 'dd/MM/yyyy',
      timeFormat: fields[9] as String? ?? 'hh:mm a',
      weekStartDay: fields[10] as int? ?? 0,
      showCents: fields[11] as bool? ?? true,
      hapticFeedback: fields[12] as bool? ?? true,
      lastBackupDate: fields[13] as DateTime?,
      language: fields[14] as String? ?? 'en',
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.themeModeIndex)
      ..writeByte(1)
      ..write(obj.defaultCurrency)
      ..writeByte(2)
      ..write(obj.defaultAccountId)
      ..writeByte(3)
      ..write(obj.pinEnabled)
      ..writeByte(4)
      ..write(obj.pinCode)
      ..writeByte(5)
      ..write(obj.biometricEnabled)
      ..writeByte(6)
      ..write(obj.onboardingComplete)
      ..writeByte(7)
      ..write(obj.firstLaunch)
      ..writeByte(8)
      ..write(obj.dateFormat)
      ..writeByte(9)
      ..write(obj.timeFormat)
      ..writeByte(10)
      ..write(obj.weekStartDay)
      ..writeByte(11)
      ..write(obj.showCents)
      ..writeByte(12)
      ..write(obj.hapticFeedback)
      ..writeByte(13)
      ..write(obj.lastBackupDate)
      ..writeByte(14)
      ..write(obj.language);
  }
}
