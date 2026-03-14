import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class ReportCard extends StatelessWidget {
  final String content;

  const ReportCard({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentStart.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.accentStart, size: 20),
              SizedBox(width: 8),
              Text(
                'AI Analizi',
                style: TextStyle(color: AppColors.accentStart, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(color: AppColors.textPrimary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
