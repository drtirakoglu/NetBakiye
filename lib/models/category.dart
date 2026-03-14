class AppCategory {
  final String id;
  final String userId;
  final String name;
  final String? icon;
  final String? color;
  final bool isIncome;

  AppCategory({
    required this.id,
    required this.userId,
    required this.name,
    this.icon,
    this.color,
    this.isIncome = false,
  });

  factory AppCategory.fromJson(Map<String, dynamic> json) {
    return AppCategory(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
      isIncome: json['is_income'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'icon': icon,
      'color': color,
      'is_income': isIncome,
    };
  }
}
