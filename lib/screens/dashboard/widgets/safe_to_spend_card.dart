import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';

class SafeToSpendCard extends StatelessWidget {
  final double safeAmount;
  final double netInterest;

  const SafeToSpendCard({
    super.key,
    required this.safeAmount,
    required this.netInterest,
  });

  @override
  Widget build(BuildContext context) {
    final isHealthy = safeAmount > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHealthy
              ? [const Color(0xFF0D4F3C), const Color(0xFF0A3D2E)]
              : [const Color(0xFF4F1A1A), const Color(0xFF3D0A0A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isHealthy ? AppColors.success : AppColors.danger).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: (isHealthy ? AppColors.success : AppColors.danger).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isHealthy ? Icons.shield_rounded : Icons.shield_outlined,
                      color: isHealthy ? AppColors.success : AppColors.danger,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Güvenli Harcama Limiti',
                      style: TextStyle(
                        color: isHealthy ? AppColors.success : AppColors.danger,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  Formatters.formatCurrency(safeAmount),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isHealthy ? Colors.white : AppColors.danger,
                    letterSpacing: -1,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Faiz maliyeti ${Formatters.formatCurrency(netInterest)} düşüldükten sonra',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isHealthy ? AppColors.success : AppColors.danger).withValues(alpha: 0.15),
              border: Border.all(
                color: (isHealthy ? AppColors.success : AppColors.danger).withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Icon(
              isHealthy ? Icons.check_rounded : Icons.priority_high_rounded,
              color: isHealthy ? AppColors.success : AppColors.danger,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
