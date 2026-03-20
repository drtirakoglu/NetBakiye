import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../theme/app_colors.dart';

class ExpensePieChart extends StatefulWidget {
  final List<Map<String, dynamic>> categoryBreakdown;
  const ExpensePieChart({super.key, required this.categoryBreakdown});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int _touchedIndex = -1;

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.categoryBreakdown;
    if (data.isEmpty) return const SizedBox();

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        pieTouchData: PieTouchData(
          touchCallback: (event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        sections: data.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isTouched = i == _touchedIndex;
          final color = _parseColor(item['color'] as String);
          final pct = item['percent'] as double;

          return PieChartSectionData(
            color: color,
            value: pct,
            title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
            radius: isTouched ? 70 : 58,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }
}
