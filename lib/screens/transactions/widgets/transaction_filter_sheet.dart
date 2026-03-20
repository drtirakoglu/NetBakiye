import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/data_providers.dart';
import '../../../theme/app_colors.dart';

class TransactionFilterSheet extends ConsumerStatefulWidget {
  const TransactionFilterSheet({super.key});

  @override
  ConsumerState<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends ConsumerState<TransactionFilterSheet> {
  late TransactionFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = ref.read(transactionFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsStreamProvider).value ?? [];
    final categories = ref.watch(categoriesStreamProvider).value ?? [];

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('Filtrele', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() => _filter = const TransactionFilter());
                },
                child: const Text('Sıfırla', style: TextStyle(color: AppColors.accentStart)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Dönem', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: TransactionPeriod.values.map((p) {
              final labels = {
                TransactionPeriod.all: 'Tümü',
                TransactionPeriod.today: 'Bugün',
                TransactionPeriod.thisWeek: 'Bu Hafta',
                TransactionPeriod.thisMonth: 'Bu Ay',
                TransactionPeriod.custom: 'Özel',
              };
              final isSelected = _filter.period == p;
              return ChoiceChip(
                label: Text(labels[p]!),
                selected: isSelected,
                onSelected: (_) => setState(() => _filter = _filter.copyWith(period: p)),
                backgroundColor: AppColors.card,
                selectedColor: AppColors.accentStart,
                labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('İşlem Türü', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Tümü'),
                selected: _filter.isExpense == null,
                onSelected: (_) => setState(() => _filter = TransactionFilter(
                  accountId: _filter.accountId,
                  categoryId: _filter.categoryId,
                  isExpense: null,
                  searchQuery: _filter.searchQuery,
                  period: _filter.period,
                )),
                backgroundColor: AppColors.card,
                selectedColor: AppColors.accentStart,
                labelStyle: TextStyle(color: _filter.isExpense == null ? Colors.white : AppColors.textSecondary),
              ),
              ChoiceChip(
                label: const Text('Gider'),
                selected: _filter.isExpense == true,
                onSelected: (_) => setState(() => _filter = _filter.copyWith(isExpense: true)),
                backgroundColor: AppColors.card,
                selectedColor: AppColors.danger,
                labelStyle: TextStyle(color: _filter.isExpense == true ? Colors.white : AppColors.textSecondary),
              ),
              ChoiceChip(
                label: const Text('Gelir'),
                selected: _filter.isExpense == false,
                onSelected: (_) => setState(() => _filter = _filter.copyWith(isExpense: false)),
                backgroundColor: AppColors.card,
                selectedColor: AppColors.success,
                labelStyle: TextStyle(color: _filter.isExpense == false ? Colors.white : AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Hesap', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            value: _filter.accountId,
            dropdownColor: AppColors.card,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(color: Colors.white),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tüm Hesaplar')),
              ...accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))),
            ],
            onChanged: (v) => setState(() => _filter = TransactionFilter(
                  accountId: v,
                  categoryId: _filter.categoryId,
                  isExpense: _filter.isExpense,
                  searchQuery: _filter.searchQuery,
                  period: _filter.period,
                )),
          ),
          const SizedBox(height: 16),
          const Text('Kategori', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            value: _filter.categoryId,
            dropdownColor: AppColors.card,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(color: Colors.white),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tüm Kategoriler')),
              ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
            ],
            onChanged: (v) => setState(() => _filter = TransactionFilter(
                  accountId: _filter.accountId,
                  categoryId: v,
                  isExpense: _filter.isExpense,
                  searchQuery: _filter.searchQuery,
                  period: _filter.period,
                )),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(transactionFilterProvider.notifier).state = _filter;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentStart,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Filtrele', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
