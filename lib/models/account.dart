enum AccountType { vadesiz, krediKarti, kmh }

class AppAccount {
  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final double balance;
  final double creditLimit;
  final double interestRate;

  AppAccount({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.balance = 0.0,
    this.creditLimit = 0.0,
    this.interestRate = 0.0,
  });

  factory AppAccount.fromJson(Map<String, dynamic> json) {
    return AppAccount(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      type: AccountType.values.firstWhere((e) {
        final val = json['type'] as String;
        if (val == 'kredi_karti') return e == AccountType.krediKarti;
        return e.toString().split('.').last == val;
      }),
      balance: (json['balance'] as num).toDouble(),
      creditLimit: (json['credit_limit'] as num).toDouble(),
      interestRate: (json['interest_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type == AccountType.krediKarti ? 'kredi_karti' : type.toString().split('.').last,
      'balance': balance,
      'credit_limit': creditLimit,
      'interest_rate': interestRate,
    };
  }
}
