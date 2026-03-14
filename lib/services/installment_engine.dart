import '../models/transaction_model.dart';
import 'package:uuid/uuid.dart';

class InstallmentEngine {
  /// Takes a total amount and splits it into N installments.
  /// Returns a list of AppTransaction objects representing each installment.
  static List<AppTransaction> generateInstallments({
    required String userId,
    required String accountId,
    required String? categoryId,
    required double totalAmount,
    required int installmentCount,
    required DateTime startDate,
    String? note,
  }) {
    if (installmentCount <= 1) {
      return [
        AppTransaction(
          id: const Uuid().v4(),
          userId: userId,
          accountId: accountId,
          categoryId: categoryId,
          amount: totalAmount,
          note: note,
          date: startDate,
          isInstallment: false,
        )
      ];
    }

    final List<AppTransaction> installments = [];
    final double installmentAmount = double.parse((totalAmount / installmentCount).toStringAsFixed(2));
    final double lastInstallmentAdjustment = double.parse(
      (totalAmount - (installmentAmount * (installmentCount - 1))).toStringAsFixed(2),
    );

    final String parentId = const Uuid().v4();

    for (int i = 1; i <= installmentCount; i++) {
      final isLast = (i == installmentCount);
      final currentAmount = isLast ? lastInstallmentAdjustment : installmentAmount;
      
      // Calculate date for each month (simple +30 days or month increment)
      final installmentDate = DateTime(
        startDate.year,
        startDate.month + (i - 1),
        startDate.day,
      );

      installments.add(
        AppTransaction(
          id: isLast && i == 1 ? parentId : const Uuid().v4(), // If i=1 is only one, but logic above handles count <=1
          userId: userId,
          accountId: accountId,
          categoryId: categoryId,
          amount: currentAmount,
          note: note != null ? '$note ($i/$installmentCount)' : 'Taksit ($i/$installmentCount)',
          date: installmentDate,
          isInstallment: true,
          totalInstallments: installmentCount,
          currentInstallment: i,
          parentTransactionId: i == 1 ? null : parentId,
        ),
      );
    }

    return installments;
  }
}
