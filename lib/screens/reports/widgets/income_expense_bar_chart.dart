import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';

class IncomeExpenseBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyBars;
  const IncomeExpenseBarChart({super.key, required this.monthlyBars});

  @override
  Widget build(BuildContext context) {
    if (monthlyBars.isEmpty) return const SizedBox();

    double maxVal = 1;
    for (final m in monthlyBars) {
      final inc = m['income'] as double;
      final exp = m['expense'] as double;
      if (inc > maxVal) maxVal = inc;
      if (exp > maxVal) maxVal = exp;
    }

    return BarChart(
      BarChartData(
        maxY: maxVal * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = rodIndex == 0 ? 'Gelir' : 'Gider';
              return BarTooltipItem(
                '$label\n${Formatters.formatCurrency(rod.toY)}',
                const TextStyle(color: Colors.white, fontSize: 11),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= monthlyBars.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    monthlyBars[idx]['label'] as String,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.textMuted, strokeWidth: 0.5),
        ),
        barGroups: monthlyBars.asMap().entries.map((entry) {
          final i = entry.key;
          final m = entry.value;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (m['income'] as double),
                color: AppColors.success,
                width: 8,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: (m['expense'] as double),
                color: AppColors.danger,
                width: 8,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
