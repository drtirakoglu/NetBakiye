import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/data_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';
import '../../../models/transaction_model.dart';
import '../../../models/fixed_payment.dart';

class CalendarDayDetail extends ConsumerWidget {
  final int day;
  final DateTime month;
  final List<Map<String, dynamic>> events;

  const CalendarDayDetail({
    super.key,
    required this.day,
    required this.month,
    required this.events,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesStreamProvider).value ?? [];
    final date = DateTime(month.year, month.month, day);
    final dateLabel = Formatters.formatDate(date);

    final transactions = events.where((e) => e['type'] == 'transaction').map((e) => e['data'] as AppTransaction).toList();
    final fixedPayments = events.where((e) => e['type'] == 'fixedPayment').map((e) => e['data'] as FixedPayment).toList();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24, left: 24, right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateLabel, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${events.length} etkinlik', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),
          if (transactions.isNotEmpty) ...[
            const Text('İŞLEMLER', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
            const SizedBox(height: 8),
            ...transactions.map((tx) {
              final cat = categories.where((c) => c.id == tx.categoryId).firstOrNull;
              final isIncome = tx.amount > 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.note ?? cat?.name ?? 'İşlem',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                          if (cat != null)
                            Text(cat.name, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(
                      '${isIncome ? '+' : ''}${Formatters.formatCurrency(tx.amount)}',
                      style: TextStyle(
                        color: isIncome ? AppColors.success : AppColors.danger,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (fixedPayments.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('PLANLI ÖDEMELER', style: TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
            const SizedBox(height: 8),
            ...fixedPayments.map((fp) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded, color: AppColors.warning, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(fp.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(Formatters.formatCurrency(fp.amount), style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(fp.isVariable ? 'Tahmini' : 'Sabit', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            )),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
