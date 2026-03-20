import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/data_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import 'widgets/calendar_day_detail.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedCalendarMonthProvider);
    final events = ref.watch(calendarEventsProvider);
    final now = DateTime.now();

    final daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(selectedMonth.year, selectedMonth.month, 1).weekday; // 1=Mon

    final monthLabel = Formatters.month.format(selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Takvim'),
      ),
      body: Column(
        children: [
          // Month navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () {
                    ref.read(selectedCalendarMonthProvider.notifier).state =
                        DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
                  },
                ),
                Expanded(
                  child: Text(
                    monthLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () {
                    ref.read(selectedCalendarMonthProvider.notifier).state =
                        DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
                  },
                ),
              ],
            ),
          ),
          // Day headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'].map((d) {
                return Expanded(
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: daysInMonth + firstWeekday - 1,
                    itemBuilder: (context, index) {
                      if (index < firstWeekday - 1) return const SizedBox();
                      final day = index - firstWeekday + 2;
                      final dayEvents = events[day] ?? [];
                      final isToday = now.year == selectedMonth.year &&
                          now.month == selectedMonth.month &&
                          now.day == day;

                      return GestureDetector(
                        onTap: dayEvents.isEmpty ? null : () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => CalendarDayDetail(
                              day: day,
                              month: selectedMonth,
                              events: dayEvents,
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppColors.accentStart.withOpacity(0.2)
                                : dayEvents.isNotEmpty
                                    ? AppColors.card
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: isToday
                                ? Border.all(color: AppColors.accentStart, width: 1.5)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$day',
                                style: TextStyle(
                                  color: isToday ? AppColors.accentStart : Colors.white,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                              if (dayEvents.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ...dayEvents.take(3).map((e) {
                                      final isFixed = e['type'] == 'fixedPayment';
                                      final isTx = e['type'] == 'transaction';
                                      Color dotColor = AppColors.textSecondary;
                                      if (isFixed) dotColor = AppColors.warning;
                                      else if (isTx) {
                                        final tx = e['data'];
                                        dotColor = (tx.amount as double) > 0
                                            ? AppColors.success
                                            : AppColors.danger;
                                      }
                                      return Container(
                                        width: 5,
                                        height: 5,
                                        margin: const EdgeInsets.symmetric(horizontal: 1),
                                        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                                      );
                                    }),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Legend
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Dot(color: AppColors.success, label: 'Gelir'),
                        const SizedBox(width: 16),
                        _Dot(color: AppColors.danger, label: 'Gider'),
                        const SizedBox(width: 16),
                        _Dot(color: AppColors.warning, label: 'Planlı ödeme'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
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
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
    ]);
  }
}
