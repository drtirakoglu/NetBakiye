class AppProfile {
  final String id;
  final String? displayName;
  final String? email;
  final String currency;
  final String? themeColor; // 'teal', 'purple', 'blue', 'orange', 'rose'
  final DateTime createdAt;

  AppProfile({
    required this.id,
    this.displayName,
    this.email,
    this.currency = 'TRY',
    this.themeColor,
    required this.createdAt,
  });

  factory AppProfile.fromJson(Map<String, dynamic> json) {
    return AppProfile(
      id: json['id'],
      displayName: json['display_name'],
      email: json['email'],
      currency: json['currency'] ?? 'TRY',
      themeColor: json['theme_color'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'email': email,
      'currency': currency,
      'theme_color': themeColor,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AppProfile copyWith({
    String? displayName,
    String? email,
    String? currency,
    String? themeColor,
  }) {
    return AppProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      currency: currency ?? this.currency,
      themeColor: themeColor ?? this.themeColor,
      createdAt: createdAt,
    );
  }
}
