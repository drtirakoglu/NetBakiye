import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/data_providers.dart';

import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import 'widgets/envelope_card.dart';
import 'package:uuid/uuid.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final accountsAsync = ref.watch(accountsStreamProvider);


    // Calculate unassigned money dynamically
    final accounts = accountsAsync.value ?? [];
    final budgets = budgetsAsync.value ?? [];
    double totalBalance = 0;
    for (final acc in accounts) {
      if (acc.balance > 0) totalBalance += acc.balance;
    }
    double totalAllocated = 0;
    for (final b in budgets) {
      totalAllocated += b.allocated;
    }
    final unassigned = (totalBalance - totalAllocated).clamp(0.0, double.infinity);

    return Scaffold(
      appBar: AppBar(title: const Text('Bütçeler')),
      body: budgetsAsync.when(
        data: (budgets) => categoriesAsync.when(
          data: (categories) => SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildUnassignedBanner(context, unassigned),
                const SizedBox(height: 24),
                const Text(
                  'Aylık Zarflar',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 12),
                if (budgets.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text('Henüz bütçe zarfı yok', style: TextStyle(color: AppColors.textSecondary)),
                        SizedBox(height: 4),
                        Text('Sağ alttaki butona tıklayarak yeni bütçe ekleyin.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...budgets.map((budget) {
                    final category = categories.cast<AppCategory?>().firstWhere(
                      (c) => c?.id == budget.categoryId,
                      orElse: () => null,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: EnvelopeCard(
                        name: category?.name ?? 'Bilinmeyen',
                        spent: budget.spent,
                        limit: budget.allocated,
                        color: category?.color != null
                            ? Color(int.parse(category!.color!.replaceAll('#', '0xFF')))
                            : null,
                        icon: Icons.folder_open,
                      ),
                    );
                  }),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Kategoriler yüklenemedi: $err')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
            child: Text('Hata: $err',
                style: const TextStyle(color: Colors.white))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUnassignedBanner(BuildContext context, double unassigned) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Atanmamış Para',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                Text(
                  'Bütçelenmeyi bekleyen ${Formatters.formatCurrency(unassigned)} var.',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    String? selectedCategoryId;
    final categories = ref.read(categoriesStreamProvider).value ?? [];
    final expenseCategories = categories.where((c) => !c.isIncome).toList();

    if (expenseCategories.isNotEmpty) {
      selectedCategoryId = expenseCategories.first.id;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Yeni Bütçe Zarfı', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (expenseCategories.isEmpty)
                const Text('Önce bir gider kategorisi ekleyin.', style: TextStyle(color: AppColors.textSecondary))
              else
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  dropdownColor: AppColors.card,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: expenseCategories.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name, style: const TextStyle(color: Colors.white)),
                  )).toList(),
                  onChanged: (val) => setDialogState(() => selectedCategoryId = val),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                style: const TextStyle(color: Colors.white),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Aylık Limit (₺)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentStart),
              onPressed: () async {
                if (selectedCategoryId == null) return;
                final amount = double.tryParse(amountController.text.replaceAll(',', '.'));
                if (amount == null || amount <= 0) return;

                final demo = ref.read(demoServiceProvider);
                final userId = demo.currentUserId;

                final now = DateTime.now();
                final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';

                final budget = AppBudget(
                  id: const Uuid().v4(),
                  userId: userId,
                  categoryId: selectedCategoryId!,
                  month: month,
                  allocated: amount,
                  spent: 0.0,
                );
                await demo.createBudget(budget);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Oluştur', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
