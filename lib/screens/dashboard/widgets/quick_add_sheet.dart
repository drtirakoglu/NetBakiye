import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../providers/data_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/account.dart';
import '../../../models/category.dart';
import '../../../services/installment_engine.dart';

class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key});

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _amountController = TextEditingController();
  String _selectedCategory = 'Gıda';
  int _installmentCount = 1;
  bool _isLoading = false;

  final List<String> _categories = ['Gıda', 'Ulaşım', 'Faturalar', 'Eğlence', 'Sağlık', 'Diğer'];

  Future<void> _saveTransaction() async {
    final amountStr = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountStr);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geçerli bir tutar girin')));
      return;
    }

    final supabase = ref.read(supabaseServiceProvider);
    final user = supabase.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Oturum bulunamadı')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final categoriesResult = ref.read(categoriesStreamProvider).value ?? [];
      final selectedCat = categoriesResult.cast<AppCategory?>().firstWhere(
        (c) => c?.name == _selectedCategory, 
        orElse: () => null
      );
      final categoryId = selectedCat?.id;

      final accountsResult = ref.read(accountsStreamProvider).value ?? [];
      if (accountsResult.isEmpty) {
        throw Exception('İşlem yapabilmek için en az bir hesabınız olmalı.');
      }
      
      final AppAccount account = accountsResult.first;

      final txs = InstallmentEngine.generateInstallments(
        userId: user.id,
        accountId: account.id,
        categoryId: categoryId,
        totalAmount: -amount,
        installmentCount: _installmentCount,
        startDate: DateTime.now(),
        note: 'Hızlı Ekleme',
      );

      for (final tx in txs) {
        await supabase.createTransaction(tx);
      }

      final updatedAccount = AppAccount(
        id: account.id,
        userId: account.userId,
        name: account.name,
        type: account.type,
        balance: account.balance - amount, 
        creditLimit: account.creditLimit,
        interestRate: account.interestRate,
      );
      await supabase.updateAccount(updatedAccount);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harcama kaydedildi')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Hızlı Harcama Gir',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            autofocus: true,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            decoration: const InputDecoration(
              hintText: '0,00 ₺',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.calculate_outlined, size: 32),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text('Kategori Seçin', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedCategory = cat),
                  backgroundColor: AppColors.card,
                  selectedColor: AppColors.accentStart,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text('Taksit Sayısı', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [1, 2, 3, 6, 9, 12].map((n) {
                final isSelected = _installmentCount == n;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(n == 1 ? 'Peşin' : '$n Taksit'),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _installmentCount = n),
                    backgroundColor: AppColors.card,
                    selectedColor: AppColors.accentEnd,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentStart,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isLoading 
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Kaydet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
