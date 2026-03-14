class AppTransaction {
  final String id;
  final String userId;
  final String accountId;
  final String? categoryId;
  final double amount;
  final String? note;
  final DateTime date;
  final bool isInstallment;
  final int totalInstallments;
  final int currentInstallment;
  final String? parentTransactionId;

  AppTransaction({
    required this.id,
    required this.userId,
    required this.accountId,
    this.categoryId,
    required this.amount,
    this.note,
    required this.date,
    this.isInstallment = false,
    this.totalInstallments = 1,
    this.currentInstallment = 1,
    this.parentTransactionId,
  });

  factory AppTransaction.fromJson(Map<String, dynamic> json) {
    return AppTransaction(
      id: json['id'],
      userId: json['user_id'],
      accountId: json['account_id'],
      categoryId: json['category_id'],
      amount: (json['amount'] as num).toDouble(),
      note: json['note'],
      date: DateTime.parse(json['date']),
      isInstallment: json['is_installment'] ?? false,
      totalInstallments: json['total_installments'] ?? 1,
      currentInstallment: json['current_installment'] ?? 1,
      parentTransactionId: json['parent_transaction_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
      'is_installment': isInstallment,
      'total_installments': totalInstallments,
      'current_installment': currentInstallment,
      'parent_transaction_id': parentTransactionId,
    };
  }
}
