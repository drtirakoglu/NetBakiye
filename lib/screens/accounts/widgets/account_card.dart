import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';

class AccountCard extends StatelessWidget {
  final String name;
  final String type;
  final double balance;
  final IconData icon;
  final Color color;
  final double? limit;
  final double? interestRate;

  const AccountCard({
    super.key,
    required this.name,
    required this.type,
    required this.balance,
    required this.icon,
    required this.color,
    this.limit,
    this.interestRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.card),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(type, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                Formatters.formatCurrency(balance),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: balance >= 0 ? Colors.white : AppColors.danger,
                ),
              ),
            ],
          ),
          if (interestRate != null && balance < 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.show_chart, size: 12, color: AppColors.danger),
                const SizedBox(width: 4),
                Text(
                  'Aylık Faiz: %$interestRate | Projeksiyon: ${Formatters.formatCurrency(balance.abs() * interestRate! / 100)}',
                  style: const TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
          if (limit != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (balance.abs() / limit!).clamp(0.0, 1.0),
                backgroundColor: AppColors.card,
                color: color,
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kullanılan: ${Formatters.formatCurrency(balance.abs())}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                Text(
                  'Limit: ${Formatters.formatCurrency(limit!)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
