class AppGoal {
  final String id;
  final String userId;
  final String name;
  final String? category; // e.g. "Araba", "Tatil", "Sürpriz Para Girişi"
  final double targetAmount;
  final double savedAmount;
  final DateTime? deadline;
  final String? icon;

  AppGoal({
    required this.id,
    required this.userId,
    required this.name,
    this.category,
    required this.targetAmount,
    this.savedAmount = 0.0,
    this.deadline,
    this.icon,
  });

  factory AppGoal.fromJson(Map<String, dynamic> json) {
    return AppGoal(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      category: json['category'],
      targetAmount: (json['target_amount'] as num).toDouble(),
      savedAmount: (json['saved_amount'] as num?)?.toDouble() ?? 0.0,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category,
      'target_amount': targetAmount,
      'saved_amount': savedAmount,
      'deadline': deadline?.toIso8601String(),
      'icon': icon,
    };
  }
}
