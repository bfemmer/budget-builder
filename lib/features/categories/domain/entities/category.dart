class CategoryEntity {
  final int? id;
  final String name;
  final double monthlyLimit;
  final String iconName;
  final int colorValue;
  final bool isIncome;

  CategoryEntity({
    this.id,
    required this.name,
    required this.monthlyLimit,
    this.iconName = 'category',
    this.colorValue = 0xFF0066FF,
    this.isIncome = false,
  });
}
