class FixedPayment {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final String categoryId;
  final bool isVariable;
  final int dayOfMonth;

  FixedPayment({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.isVariable,
    required this.dayOfMonth,
  });

  factory FixedPayment.fromJson(Map<String, dynamic> json) {
    return FixedPayment(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['category_id'],
      isVariable: json['is_variable'] ?? false,
      dayOfMonth: json['day_of_month'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'amount': amount,
      'category_id': categoryId,
      'is_variable': isVariable,
      'day_of_month': dayOfMonth,
    };
  }

  FixedPayment copyWith({
    String? name,
    double? amount,
    String? categoryId,
    bool? isVariable,
    int? dayOfMonth,
  }) {
    return FixedPayment(
      id: id,
      userId: userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      isVariable: isVariable ?? this.isVariable,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    );
  }
}
