import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/data_providers.dart';
import '../../models/fixed_payment.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';

class FixedPaymentsScreen extends ConsumerWidget {
  const FixedPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixedPayments = ref.watch(fixedPaymentsStreamProvider).value ?? [];
    final categories = ref.watch(categoriesStreamProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sabit Ödemeler'),
      ),
      body: fixedPayments.isEmpty
          ? const Center(child: Text('Henüz sabit ödeme eklenmemiş.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: fixedPayments.length,
              itemBuilder: (context, index) {
                final fp = fixedPayments[index];
                final category = categories.firstWhere(
                  (c) => c.id == fp.categoryId,
                  orElse: () => categories.first,
                );

                final colorStr = category.color ?? '#94a3b8';
                final color = Color(int.parse(colorStr.replaceFirst('#', '0xFF')));

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.1),
                      child: Icon(
                        _getIconData(category.icon ?? ''),
                        color: color,
                      ),
                    ),
                    title: Text(fp.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Her ayın ${fp.dayOfMonth}. günü'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.formatCurrency(fp.amount),
                          style: TextStyle(
                            color: fp.isVariable ? AppColors.info : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (fp.isVariable)
                          const Text('Tahmini', style: TextStyle(fontSize: 10, color: AppColors.info)),
                      ],
                    ),
                    onLongPress: () => _deleteFixedPayment(context, ref, fp.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFixedPayment(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteFixedPayment(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sil?'),
        content: const Text('Bu sabit ödemeyi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () {
              ref.read(demoServiceProvider).deleteFixedPayment(id);
              Navigator.pop(context);
            },
            child: const Text('Sil', style: TextStyle(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }

  void _showAddFixedPayment(BuildContext context, WidgetRef ref) {
    // Basic form for adding fixed payment
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    bool isVariable = false;
    int dayOfMonth = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 32, left: 24, right: 24,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Yeni Sabit Ödeme', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Ödeme Adı (Kira, Netflix vb.)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Miktar',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Değişken Miktar (Tahmini):'),
                  const Spacer(),
                  Switch(
                    value: isVariable,
                    onChanged: (val) => setState(() => isVariable = val),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Ödeme Günü:'),
              Slider(
                value: dayOfMonth.toDouble(),
                min: 1,
                max: 31,
                divisions: 30,
                label: dayOfMonth.toString(),
                onChanged: (val) => setState(() => dayOfMonth = val.toInt()),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final fp = FixedPayment(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    userId: 'demo-user-001',
                    name: nameController.text,
                    amount: double.tryParse(amountController.text) ?? 0,
                    categoryId: 'cat-3', // Default to Faturalar for demo
                    isVariable: isVariable,
                    dayOfMonth: dayOfMonth,
                  );
                  ref.read(demoServiceProvider).createFixedPayment(fp);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Kaydet'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'receipt': return Icons.receipt;
      case 'celebration': return Icons.celebration;
      case 'health': return Icons.medical_services;
      case 'payments': return Icons.payments;
      case 'work': return Icons.work;
      case 'card_giftcard': return Icons.card_giftcard;
      default: return Icons.category;
    }
  }
}
