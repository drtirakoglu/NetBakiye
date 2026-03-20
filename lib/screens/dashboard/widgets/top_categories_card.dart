import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';
import '../../../models/category.dart';
import '../../../models/transaction_model.dart';

class TopCategoriesCard extends StatelessWidget {
  final List<AppTransaction> transactions;
  final List<AppCategory> categories;

  const TopCategoriesCard({
    super.key,
    required this.transactions,
    required this.categories,
  });

  IconData _parseIcon(String? name) {
    switch (name) {
      case 'restaurant':     return Icons.restaurant_rounded;
      case 'directions_car': return Icons.directions_car_rounded;
      case 'receipt':        return Icons.receipt_long_rounded;
      case 'celebration':    return Icons.celebration_rounded;
      case 'health':         return Icons.favorite_rounded;
      case 'payments':       return Icons.payments_rounded;
      case 'work':           return Icons.work_rounded;
      case 'card_giftcard':  return Icons.card_giftcard_rounded;
      default:               return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthTxs = transactions.where((tx) =>
      tx.amount < 0 &&
      tx.date.year == now.year &&
      tx.date.month == now.month);

    final Map<String, double> catTotals = {};
    for (final tx in monthTxs) {
      if (tx.categoryId != null) {
        catTotals[tx.categoryId!] = (catTotals[tx.categoryId!] ?? 0) + tx.amount.abs();
      }
    }

    final sorted = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sorted.take(3).toList();
    if (top3.isEmpty) return const SizedBox();

    final totalSpent = top3.fold(0.0, (s, e) => s + e.value);

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
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_fire_department_rounded, color: AppColors.warning, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('En Yüksek Harcama', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Bu ay kategorilere göre', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                Formatters.formatCurrency(totalSpent),
                style: const TextStyle(color: AppColors.warning, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...top3.asMap().entries.map((entry) {
            final rank = entry.key;
            final e = entry.value;
            final cat = categories.where((c) => c.id == e.key).firstOrNull;
            final name = cat?.name ?? 'Diğer';
            Color catColor = AppColors.textSecondary;
            if (cat?.color != null) {
              try { catColor = Color(int.parse(cat!.color!.replaceFirst('#', '0xFF'))); } catch (_) {}
            }
            final pct = totalSpent > 0 ? e.value / totalSpent : 0.0;
            final rankEmojis = ['🥇', '🥈', '🥉'];

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  // Rank + icon
                  Stack(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [catColor.withValues(alpha: 0.3), catColor.withValues(alpha: 0.1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: catColor.withValues(alpha: 0.4)),
                        ),
                        child: Icon(_parseIcon(cat?.icon), color: catColor, size: 22),
                      ),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Text(rankEmojis[rank], style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Bar + label
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text(
                              Formatters.formatCurrency(e.value),
                              style: TextStyle(color: catColor, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Stack(
                          children: [
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: pct.clamp(0.0, 1.0),
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [catColor, catColor.withValues(alpha: 0.6)],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(color: catColor.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(0, 2)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '%${(pct * 100).toStringAsFixed(0)} toplam harcama',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
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
