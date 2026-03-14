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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentStart.withOpacity(0.1),
            AppColors.accentEnd.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentStart.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.security, color: AppColors.accentStart, size: 20),
              SizedBox(width: 8),
              Text(
                'Güvenli Harcama Limiti',
                style: TextStyle(color: AppColors.accentStart, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            Formatters.formatCurrency(safeAmount),
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Zorunlu harcamalar ve ${Formatters.formatCurrency(netInterest)} beklenen faiz düşüldükten sonra.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
