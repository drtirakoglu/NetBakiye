import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/data_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import 'widgets/envelope_card.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bütçeler')),
      body: budgetsAsync.when(
        data: (budgets) => categoriesAsync.when(
          data: (categories) => SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildUnassignedBanner(context),
                const SizedBox(height: 24),
                const Text(
                  'Aylık Zarflar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                ...budgets.map((budget) {
                  final category = categories.firstWhere(
                    (c) => c.id == budget.categoryId,
                    orElse: () => categories.first,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: EnvelopeCard(
                      name: category.name,
                      spent: budget.spent,
                      limit: budget.allocated,
                      color: Color(int.parse((category.color ?? '#4ADE80').replaceAll('#', '0xFF'))),
                      icon: Icons.folder_open,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Kategoriler yüklenemedi: $err')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err', style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _buildUnassignedBanner(BuildContext context) {
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
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                Text(
                  'Bütçelenmeyi bekleyen ${Formatters.formatCurrency(1250.00)} var.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Ata', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
