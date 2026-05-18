import 'package:uuid/uuid.dart';
import 'transaction_model.dart';

/// Category Model
class CategoryModel {
  final String id;
  final String name;
  final int iconCodePoint;
  final int colorValue;
  final TransactionType type;
  final bool isDefault;
  final List<SubcategoryModel> subcategories;
  final int order;
  final DateTime createdAt;

  CategoryModel({
    String? id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    required this.type,
    this.isDefault = false,
    List<SubcategoryModel>? subcategories,
    this.order = 0,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        subcategories = subcategories ?? [],
        createdAt = createdAt ?? DateTime.now();

  CategoryModel copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    int? colorValue,
    TransactionType? type,
    bool? isDefault,
    List<SubcategoryModel>? subcategories,
    int? order,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      subcategories: subcategories ?? this.subcategories,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'type': type.index,
      'isDefault': isDefault,
      'subcategories': subcategories.map((e) => e.toJson()).toList(),
      'order': order,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCodePoint: json['iconCodePoint'] as int,
      colorValue: json['colorValue'] as int,
      type: TransactionType.values[json['type'] as int],
      isDefault: json['isDefault'] as bool? ?? false,
      subcategories: (json['subcategories'] as List<dynamic>?)
              ?.map((e) => SubcategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      order: json['order'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, type: $type)';
  }
}

/// Subcategory Model
class SubcategoryModel {
  final String id;
  final String name;
  final int iconCodePoint;

  SubcategoryModel({
    String? id,
    required this.name,
    required this.iconCodePoint,
  }) : id = id ?? const Uuid().v4();

  SubcategoryModel copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
  }) {
    return SubcategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
    };
  }

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCodePoint: json['iconCodePoint'] as int,
    );
  }
}
