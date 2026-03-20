import 'package:flutter/material.dart';
import '../../../models/transaction_model.dart';
import '../../../models/category.dart';
import '../../../models/account.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';

class TransactionListItem extends StatelessWidget {
  final AppTransaction transaction;
  final AppCategory? category;
  final AppAccount? account;
  final VoidCallback? onDelete;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.category,
    this.account,
    this.onDelete,
  });

  Color _parseColor(String? hex) {
    if (hex == null) return AppColors.textSecondary;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.textSecondary;
    }
  }

  IconData _parseIcon(String? name) {
    switch (name) {
      case 'restaurant':    return Icons.restaurant_rounded;
      case 'directions_car': return Icons.directions_car_rounded;
      case 'receipt':       return Icons.receipt_long_rounded;
      case 'celebration':   return Icons.celebration_rounded;
      case 'health':        return Icons.favorite_rounded;
      case 'payments':      return Icons.payments_rounded;
      case 'work':          return Icons.work_rounded;
      case 'card_giftcard': return Icons.card_giftcard_rounded;
      default:              return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.amount > 0;
    final catColor = _parseColor(category?.color);
    final amountColor = isIncome ? AppColors.success : AppColors.danger;
    final amountStr = isIncome
        ? '+${Formatters.formatCurrency(transaction.amount)}'
        : Formatters.formatCurrency(transaction.amount);

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 28),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_rounded, color: AppColors.danger, size: 22),
            SizedBox(height: 2),
            Text('Sil', style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [catColor.withValues(alpha: 0.25), catColor.withValues(alpha: 0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: catColor.withValues(alpha: 0.3), width: 1),
                ),
                child: Icon(_parseIcon(category?.icon), color: catColor, size: 22),
              ),
              const SizedBox(width: 13),
              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.note ?? category?.name ?? 'İşlem',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (category != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              category!.name,
                              style: TextStyle(color: catColor, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          Formatters.formatDate(transaction.date),
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountStr,
                    style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (account != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.credit_card_rounded, size: 10, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          account!.name.length > 12 ? '${account!.name.substring(0, 12)}…' : account!.name,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
