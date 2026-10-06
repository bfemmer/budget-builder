import '../../domain/entities/category.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    super.id,
    required super.name,
    required super.monthlyLimit,
    super.iconName,
    super.colorValue,
    super.isIncome,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'] ?? '',
      monthlyLimit: (map['monthly_limit'] as num?)?.toDouble() ?? 0.0,
      iconName: map['icon_name'] ?? 'category',
      colorValue: map['color_value'] ?? 0xFF0066FF,
      isIncome: (map['is_income'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'monthly_limit': monthlyLimit,
      'icon_name': iconName,
      'color_value': colorValue,
      'is_income': isIncome ? 1 : 0,
    };
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    double? monthlyLimit,
    String? iconName,
    int? colorValue,
    bool? isIncome,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}
