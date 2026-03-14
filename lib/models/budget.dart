class AppBudget {
  final String id;
  final String userId;
  final String categoryId;
  final String month; // YYYY-MM
  final double allocated;
  final double spent;

  AppBudget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.month,
    this.allocated = 0.0,
    this.spent = 0.0,
  });

  factory AppBudget.fromJson(Map<String, dynamic> json) {
    return AppBudget(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      month: json['month'],
      allocated: (json['allocated'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'month': month,
      'allocated': allocated,
      'spent': spent,
    };
  }
}
