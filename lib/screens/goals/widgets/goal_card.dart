import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';

class GoalCard extends StatelessWidget {
  final String name;
  final double target;
  final double current;
  final String? category;
  final IconData icon;
  final bool isCompleted;
  final String? goalId;

  const GoalCard({
    super.key,
    required this.name,
    required this.target,
    required this.current,
    this.category,
    required this.icon,
    this.isCompleted = false,
    this.goalId,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / target).clamp(0.0, 1.0);
    final themeColor = isCompleted ? AppColors.success : AppColors.accentStart;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isCompleted ? themeColor.withOpacity(0.5) : AppColors.card, width: isCompleted ? 2 : 1),
        boxShadow: isCompleted ? [
          BoxShadow(color: themeColor.withOpacity(0.1), blurRadius: 20, spreadRadius: 2)
        ] : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: themeColor.withOpacity(0.1),
                child: Icon(isCompleted ? Icons.emoji_events : icon, color: themeColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    Row(
                      children: [
                        if (category != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: themeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              category!,
                              style: TextStyle(color: themeColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            isCompleted ? 'Hedef Tamamlandı!' : 'Hedef: ${Formatters.formatCurrency(target)}',
                            style: TextStyle(color: isCompleted ? themeColor : AppColors.textSecondary, fontSize: 12, fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                isCompleted ? 'DONE' : '%${(progress * 100).toInt()}',
                style: TextStyle(fontWeight: FontWeight.bold, color: themeColor, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.card,
              color: themeColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Biriken: ${Formatters.formatCurrency(current)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              if (!isCompleted)
              Text(
                'Kalan: ${Formatters.formatCurrency(target - current)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
