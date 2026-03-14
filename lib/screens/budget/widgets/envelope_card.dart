import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';

class EnvelopeCard extends StatelessWidget {
  final String name;
  final double limit;
  final double spent;
  final Color? color;
  final IconData? icon;

  const EnvelopeCard({
    super.key,
    required this.name,
    required this.limit,
    required this.spent,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = limit - spent;
    final progress = (spent / limit).clamp(0.0, 1.0);
    final isOverSpent = spent > limit;
    final themeColor = color ?? AppColors.primary;

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon ?? Icons.folder_open, color: themeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
              ),
              Text(
                Formatters.formatCurrency(remaining),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isOverSpent ? AppColors.danger : AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.card,
              color: isOverSpent ? AppColors.danger : themeColor,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Harcanan: ${Formatters.formatCurrency(spent)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                'Toplam: ${Formatters.formatCurrency(limit)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
