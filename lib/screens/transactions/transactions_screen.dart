import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/data_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import 'widgets/transaction_list_item.dart';
import 'widgets/transaction_filter_sheet.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final categories = ref.watch(categoriesStreamProvider).value ?? [];
    final accounts = ref.watch(accountsStreamProvider).value ?? [];
    final filter = ref.watch(transactionFilterProvider);
    final demo = ref.read(demoServiceProvider);

    // Group by date label
    final Map<String, List<int>> groups = {};
    final now = DateTime.now();
    for (int i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      final d = tx.date;
      String label;
      if (d.year == now.year && d.month == now.month && d.day == now.day) {
        label = 'Bugün';
      } else if (d.year == now.year && d.month == now.month && d.day == now.day - 1) {
        label = 'Dün';
      } else if (now.difference(d).inDays < 7) {
        label = 'Bu Hafta';
      } else if (d.year == now.year && d.month == now.month) {
        label = 'Bu Ay';
      } else {
        label = Formatters.month.format(d);
      }
      groups[label] ??= [];
      groups[label]!.add(i);
    }

    final bool hasFilter = filter.accountId != null ||
        filter.categoryId != null ||
        filter.isExpense != null ||
        filter.period != TransactionPeriod.all ||
        filter.searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('İşlemler', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        actions: [
          if (hasFilter)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_rounded, color: AppColors.warning),
              tooltip: 'Filtreyi Temizle',
              onPressed: () => ref.read(transactionFilterProvider.notifier).state = const TransactionFilter(),
            ),
          IconButton(
            icon: Icon(
              Icons.filter_alt_rounded,
              color: hasFilter ? AppColors.accentStart : null,
            ),
            tooltip: 'Filtrele',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const TransactionFilterSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'İşlem ara...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (q) => ref.read(transactionFilterProvider.notifier).update(
                (s) => s.copyWith(searchQuery: q),
              ),
            ),
          ),
          // Summary row
          if (transactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${transactions.length} işlem',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const Spacer(),
                  Builder(builder: (_) {
                    double inc = 0, exp = 0;
                    for (final tx in transactions) {
                      if (tx.amount > 0) inc += tx.amount;
                      else exp += tx.amount.abs();
                    }
                    return Row(children: [
                      Text('+${Formatters.formatCurrency(inc)}', style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Text('-${Formatters.formatCurrency(exp)}', style: const TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w600)),
                    ]);
                  }),
                ],
              ),
            ),
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.textMuted),
                        SizedBox(height: 16),
                        Text('İşlem Bulunamadı', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        SizedBox(height: 8),
                        Text('Filtre kriterlerinizi değiştirmeyi deneyin', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      for (final entry in groups.entries) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        ...entry.value.map((idx) {
                          final tx = transactions[idx];
                          final cat = categories.where((c) => c.id == tx.categoryId).firstOrNull;
                          final acc = accounts.where((a) => a.id == tx.accountId).firstOrNull;
                          return TransactionListItem(
                            transaction: tx,
                            category: cat,
                            account: acc,
                            onDelete: () async {
                              // Remove from demo - find and delete by rebuilding list
                            },
                          );
                        }),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
