class AppGoal {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime? deadline;
  final String? icon;

  AppGoal({
    required this.id,
    required this.userId,
    required this.name,
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
      targetAmount: (json['target_amount'] as num).toDouble(),
      savedAmount: (json['saved_amount'] as num).toDouble(),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'target_amount': targetAmount,
      'saved_amount': savedAmount,
      'deadline': deadline?.toIso8601String(),
      'icon': icon,
    };
  }
}
