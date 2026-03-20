import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';

class MonthlyStatusChart extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const MonthlyStatusChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aylık Durum (Son 6 Ay)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Canlı',
                  style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF334155),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = history[groupIndex];
                      return BarTooltipItem(
                        "${item['month']}\n",
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: Formatters.formatCurrency(rod.toY),
                            style: TextStyle(
                              color: rod.toY >= 0 ? AppColors.success : AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                        if (value.toInt() >= history.length) return const SizedBox();
                        final monthStr = history[value.toInt()]['month'] as String;
                        final month = monthStr.split('-')[1];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _getMonthName(month),
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: history.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final net = data['net'] as double;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: net,
                        color: net >= 0 ? AppColors.success : AppColors.warning,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: _getMaxY(),
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY() {
    double max = 1000;
    for (var h in history) {
      if ((h['net'] as double).abs() > max) max = (h['net'] as double).abs();
    }
    return max * 1.2;
  }

  String _getMonthName(String month) {
    const names = {
      '01': 'Oca', '02': 'Şub', '03': 'Mar', '04': 'Nis',
      '05': 'May', '06': 'Haz', '07': 'Tem', '08': 'Ağu',
      '09': 'Eyl', '10': 'Eki', '11': 'Kas', '12': 'Ara',
    };
    return names[month] ?? month;
  }
}
