import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';
import '../../../models/budget.dart';
import '../../../models/category.dart';

class BudgetSummaryCard extends StatelessWidget {
  final List<AppBudget> budgets;
  final List<AppCategory> categories;

  const BudgetSummaryCard({super.key, required this.budgets, required this.categories});

  IconData _parseIcon(String? name) {
    switch (name) {
      case 'restaurant':     return Icons.restaurant_rounded;
      case 'directions_car': return Icons.directions_car_rounded;
      case 'receipt':        return Icons.receipt_long_rounded;
      case 'celebration':    return Icons.celebration_rounded;
      default:               return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) return const SizedBox();

    final totalAllocated = budgets.fold(0.0, (s, b) => s + b.allocated);
    final totalSpent = budgets.fold(0.0, (s, b) => s + b.spent);
    final overBudget = budgets.where((b) => b.spent > b.allocated).length;
    final overallPct = totalAllocated > 0 ? (totalSpent / totalAllocated).clamp(0.0, 1.0) : 0.0;
    final isOver = totalSpent > totalAllocated;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentStart.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.donut_large_rounded, color: AppColors.accentStart, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bütçe Özeti', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Bu ay bütçe kullanımı', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              if (overBudget > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '$overBudget aşıldı',
                        style: const TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Overall big progress
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          Formatters.formatCurrency(totalSpent),
                          style: TextStyle(
                            color: isOver ? AppColors.danger : Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          ' / ${Formatters.formatCurrency(totalAllocated)}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: overallPct,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isOver
                                    ? [AppColors.danger, AppColors.warning]
                                    : [AppColors.accentStart, AppColors.accentEnd],
                              ),
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: (isOver ? AppColors.danger : AppColors.accentStart).withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '%${(overallPct * 100).toStringAsFixed(0)} kullanıldı',
                      style: TextStyle(
                        color: isOver ? AppColors.danger : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isOver ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Divider(color: Colors.white.withValues(alpha: 0.07), height: 1),
          const SizedBox(height: 16),

          // Per-category
          ...budgets.take(3).map((b) {
            final cat = categories.where((c) => c.id == b.categoryId).firstOrNull;
            final name = cat?.name ?? 'Kategori';
            Color catColor = AppColors.accentStart;
            if (cat?.color != null) {
              try { catColor = Color(int.parse(cat!.color!.replaceFirst('#', '0xFF'))); } catch (_) {}
            }
            final pct = b.allocated > 0 ? (b.spent / b.allocated).clamp(0.0, 1.0) : 0.0;
            final isItemOver = b.spent > b.allocated;
            final itemColor = isItemOver ? AppColors.danger : catColor;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: catColor.withValues(alpha: 0.25)),
                    ),
                    child: Icon(_parseIcon(cat?.icon), color: catColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                            const Spacer(),
                            Text(
                              Formatters.formatCurrency(b.spent),
                              style: TextStyle(color: itemColor, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              ' / ${Formatters.formatCurrency(b.allocated)}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Stack(
                          children: [
                            Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: pct,
                              child: Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  color: itemColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
