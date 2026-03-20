import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';

class CashflowTrendCard extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyHistory;
  const CashflowTrendCard({super.key, required this.monthlyHistory});

  @override
  Widget build(BuildContext context) {
    if (monthlyHistory.isEmpty) return const SizedBox();

    final spots = monthlyHistory.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['net'] as double));
    }).toList();

    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY) * 0.25;
    minY -= pad;
    maxY += pad;
    if ((maxY - minY).abs() < 2000) { minY -= 1000; maxY += 1000; }

    final lastNet = spots.last.y;
    final firstNet = spots.first.y;
    final isPositive = lastNet >= 0;
    final delta = lastNet - firstNet;
    final deltaPositive = delta >= 0;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentStart.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up_rounded, color: AppColors.accentStart, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nakit Akışı Trendi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Son 6 ay net kazanç / kayıp', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency(lastNet),
                    style: TextStyle(
                      color: isPositive ? AppColors.success : AppColors.danger,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        deltaPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        color: deltaPositive ? AppColors.success : AppColors.danger,
                        size: 11,
                      ),
                      Text(
                        Formatters.formatCurrency(delta.abs()),
                        style: TextStyle(
                          color: deltaPositive ? AppColors.success : AppColors.danger,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 130,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= monthlyHistory.length) return const SizedBox();
                        final label = monthlyHistory[idx]['month'] as String;
                        final month = label.split('-')[1];
                        const names = {
                          '01': 'Oca', '02': 'Şub', '03': 'Mar', '04': 'Nis',
                          '05': 'May', '06': 'Haz', '07': 'Tem', '08': 'Ağu',
                          '09': 'Eyl', '10': 'Eki', '11': 'Kas', '12': 'Ara',
                        };
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            names[month] ?? month,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF2D3748),
                    getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                      Formatters.formatCurrency(s.y),
                      TextStyle(
                        color: s.y >= 0 ? AppColors.success : AppColors.danger,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: isPositive ? AppColors.success : AppColors.danger,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: spot == spots.last ? 5 : 3,
                        color: isPositive ? AppColors.success : AppColors.danger,
                        strokeColor: AppColors.card,
                        strokeWidth: 2,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          (isPositive ? AppColors.success : AppColors.danger).withValues(alpha: 0.2),
                          (isPositive ? AppColors.success : AppColors.danger).withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Mini monthly summary row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: monthlyHistory.map((m) {
              final net = m['net'] as double;
              final isPos = net >= 0;
              final label = (m['month'] as String).split('-')[1];
              const names = {
                '01': 'Oca', '02': 'Şub', '03': 'Mar', '04': 'Nis',
                '05': 'May', '06': 'Haz', '07': 'Tem', '08': 'Ağu',
                '09': 'Eyl', '10': 'Eki', '11': 'Kas', '12': 'Ara',
              };
              return Expanded(
                child: Column(
                  children: [
                    Icon(
                      isPos ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      color: isPos ? AppColors.success : AppColors.danger,
                      size: 12,
                    ),
                    Text(
                      names[label] ?? label,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
