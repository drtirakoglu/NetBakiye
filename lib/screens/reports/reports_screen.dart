import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/data_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import 'widgets/expense_pie_chart.dart';
import 'widgets/income_expense_bar_chart.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    final data = ref.watch(reportsDataProvider);

    final totalIncome = data['totalIncome'] as double;
    final totalExpense = data['totalExpense'] as double;
    final netSavings = data['netSavings'] as double;
    final categoryBreakdown = data['categoryBreakdown'] as List<Map<String, dynamic>>;
    final monthlyBars = data['monthlyBars'] as List<Map<String, dynamic>>;

    final periodLabels = {
      ReportPeriod.thisWeek: 'Bu Hafta',
      ReportPeriod.thisMonth: 'Bu Ay',
      ReportPeriod.thisYear: 'Bu Yıl',
      ReportPeriod.custom: 'Özel',
    };

    final savingsRate = totalIncome > 0 ? (netSavings / totalIncome * 100) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Raporlar', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        children: [
          // Period selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: ReportPeriod.values.map((p) {
                final isSelected = period == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ref.read(reportPeriodProvider.notifier).state = p,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [AppColors.accentStart, AppColors.accentEnd],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected
                            ? [BoxShadow(color: AppColors.accentStart.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 2))]
                            : null,
                      ),
                      child: Text(
                        periodLabels[p]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Big summary 3-card row
          Row(
            children: [
              _BigStat(label: 'Gelir', amount: totalIncome, color: AppColors.success, icon: Icons.arrow_downward_rounded),
              const SizedBox(width: 10),
              _BigStat(label: 'Gider', amount: totalExpense, color: AppColors.danger, icon: Icons.arrow_upward_rounded),
              const SizedBox(width: 10),
              _BigStat(
                label: 'Net',
                amount: netSavings,
                color: netSavings >= 0 ? AppColors.accentStart : AppColors.warning,
                icon: netSavings >= 0 ? Icons.savings_rounded : Icons.trending_down_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Savings rate card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                const Icon(Icons.insights_rounded, color: AppColors.accentStart, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Birikim oranı: %${savingsRate.toStringAsFixed(1)}',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  width: 120,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (savingsRate / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.accentStart, AppColors.success]),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pie chart card
          if (categoryBreakdown.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.pie_chart_rounded, color: AppColors.danger, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Harcama Dağılımı', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Kategoriye göre kırılım', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 220,
                    child: ExpensePieChart(categoryBreakdown: categoryBreakdown),
                  ),
                  const SizedBox(height: 16),
                  ...categoryBreakdown.take(6).map((item) {
                    Color catColor;
                    try {
                      catColor = Color(int.parse((item['color'] as String).replaceFirst('#', '0xFF')));
                    } catch (_) {
                      catColor = AppColors.textSecondary;
                    }
                    final pct = item['percent'] as double;
                    final amt = item['amount'] as double;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(3)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item['name'] as String,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                            ),
                          ),
                          // mini bar
                          SizedBox(
                            width: 80,
                            height: 5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: pct / 100,
                                backgroundColor: catColor.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(catColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '%${pct.toStringAsFixed(0)}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 90,
                            child: Text(
                              Formatters.formatCurrency(amt),
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Bar chart card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bar_chart_rounded, color: AppColors.info, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gelir — Gider', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Son 6 aylık karşılaştırma', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _Dot(color: AppColors.success, label: 'Gelir'),
                        const SizedBox(width: 12),
                        _Dot(color: AppColors.danger, label: 'Gider'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 210,
                  child: IncomeExpenseBarChart(monthlyBars: monthlyBars),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _BigStat({required this.label, required this.amount, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 14),
                const SizedBox(width: 4),
                Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              Formatters.formatCurrency(amount.abs()),
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
    ]);
  }
}
