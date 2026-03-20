import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';

class UpcomingPaymentsCard extends StatelessWidget {
  final List<Map<String, dynamic>> expectedPayments;

  const UpcomingPaymentsCard({super.key, required this.expectedPayments});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = expectedPayments.where((p) {
      final date = p['date'] as DateTime;
      return date.isAfter(now.subtract(const Duration(days: 1)));
    }).take(5).toList();

    if (upcoming.isEmpty) return const SizedBox();

    final totalUpcoming = upcoming.fold(0.0, (s, p) => s + (p['amount'] as double));

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
                  color: AppColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.event_note_rounded, color: AppColors.info, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Yaklaşan Ödemeler', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Planlı sabit giderler', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency(totalUpcoming),
                    style: const TextStyle(color: AppColors.info, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Text('toplam', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...upcoming.asMap().entries.map((entry) {
            final p = entry.value;
            final date = p['date'] as DateTime;
            final daysLeft = date.difference(now).inDays;
            final isFixed = p['isFixed'] as bool;
            final isOverdue = daysLeft < 0;
            final isSoon = daysLeft <= 3 && !isOverdue;

            Color statusColor;
            if (isOverdue) statusColor = AppColors.danger;
            else if (isSoon) statusColor = AppColors.warning;
            else statusColor = AppColors.info;

            String daysLabel;
            if (isOverdue) daysLabel = '${daysLeft.abs()} gün geçti!';
            else if (daysLeft == 0) daysLabel = 'Bugün!';
            else if (daysLeft == 1) daysLabel = 'Yarın';
            else daysLabel = '$daysLeft gün kaldı';

            final isLast = entry.key == upcoming.length - 1;

            return Column(
              children: [
                Row(
                  children: [
                    // Day badge
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: TextStyle(color: statusColor, fontSize: 16, fontWeight: FontWeight.bold, height: 1),
                          ),
                          Text(
                            _shortMonth(date.month),
                            style: TextStyle(color: statusColor.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['name'] as String,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                isFixed ? Icons.lock_rounded : Icons.sync_rounded,
                                size: 11,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isFixed ? 'Sabit' : 'Değişken',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  daysLabel,
                                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(p['amount'] as double),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                if (!isLast)
                  Divider(
                    height: 16,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _shortMonth(int m) {
    const months = ['', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    return months[m];
  }
}
