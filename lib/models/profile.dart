class AppProfile {
  final String id;
  final String? displayName;
  final String currency;
  final DateTime createdAt;

  AppProfile({
    required this.id,
    this.displayName,
    this.currency = 'TRY',
    required this.createdAt,
  });

  factory AppProfile.fromJson(Map<String, dynamic> json) {
    return AppProfile(
      id: json['id'],
      displayName: json['display_name'],
      currency: json['currency'] ?? 'TRY',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
