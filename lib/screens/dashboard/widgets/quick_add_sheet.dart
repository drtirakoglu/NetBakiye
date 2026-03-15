import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../providers/data_providers.dart';
import '../../../models/account.dart';
import '../../../models/category.dart';
import '../../../services/installment_engine.dart';
import 'package:uuid/uuid.dart';

class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key});

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _amountController = TextEditingController();
  String? _selectedCategoryId;
  int _installmentCount = 1;
  bool _isLoading = false;
  bool _isExpense = true;

  Future<void> _saveTransaction() async {
    final amountStr = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountStr);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geçerli bir tutar girin')));
      return;
    }

    final demo = ref.read(demoServiceProvider);
    final userId = demo.currentUserId;

    setState(() => _isLoading = true);

    try {
      final accountsResult = ref.read(accountsStreamProvider).value ?? [];
      if (accountsResult.isEmpty) {
        throw Exception('İşlem yapabilmek için en az bir hesabınız olmalı.');
      }
      
      final AppAccount account = accountsResult.first;
      final finalAmount = _isExpense ? -amount : amount;

      final txs = InstallmentEngine.generateInstallments(
        userId: userId,
        accountId: account.id,
        categoryId: _selectedCategoryId,
        totalAmount: finalAmount,
        installmentCount: _isExpense ? _installmentCount : 1,
        startDate: DateTime.now(),
        note: _isExpense ? 'Hızlı Harcama' : 'Gelir Girişi',
      );

      for (final tx in txs) {
        await demo.createTransaction(tx);
      }

      final updatedAccount = AppAccount(
        id: account.id,
        userId: account.userId,
        name: account.name,
        type: account.type,
        balance: account.balance + finalAmount, 
        creditLimit: account.creditLimit,
        interestRate: account.interestRate,
      );
      await demo.updateAccount(updatedAccount);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isExpense ? 'Harcama kaydedildi' : 'Gelir kaydedildi')),
        );
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

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    bool isIncome = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Yeni Kategori', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Kategori Adı',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text(isIncome ? 'Gelir' : 'Gider',
                    style: const TextStyle(color: Colors.white)),
                value: isIncome,
                onChanged: (v) => setDialogState(() => isIncome = v),
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
                if (nameController.text.trim().isEmpty) return;
                final demo = ref.read(demoServiceProvider);
                
                final cat = AppCategory(
                  id: const Uuid().v4(),
                  userId: demo.currentUserId,
                  name: nameController.text.trim(),
                  isIncome: isIncome,
                );
                await demo.createCategory(cat);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Ekle', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categories = categoriesAsync.value ?? [];
    final filteredCategories = categories.where((c) => _isExpense ? !c.isIncome : c.isIncome).toList();

    if (_selectedCategoryId == null && filteredCategories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedCategoryId = filteredCategories.first.id);
      });
    }

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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gelir/Gider Toggle
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _isExpense = true;
                        _selectedCategoryId = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isExpense ? AppColors.danger.withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: _isExpense ? Border.all(color: AppColors.danger.withOpacity(0.5)) : null,
                        ),
                        child: Text(
                          '💸 Gider',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isExpense ? AppColors.danger : AppColors.textSecondary,
                            fontWeight: _isExpense ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _isExpense = false;
                        _selectedCategoryId = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isExpense ? AppColors.success.withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: !_isExpense ? Border.all(color: AppColors.success.withOpacity(0.5)) : null,
                        ),
                        child: Text(
                          '💰 Gelir',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_isExpense ? AppColors.success : AppColors.textSecondary,
                            fontWeight: !_isExpense ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isExpense ? 'Hızlı Harcama Gir' : 'Hızlı Gelir Gir',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
            Row(
              children: [
                const Text('Kategori Seçin', style: TextStyle(color: AppColors.textSecondary)),
                const Spacer(),
                GestureDetector(
                  onTap: _showAddCategoryDialog,
                  child: const Row(
                    children: [
                      Icon(Icons.add_circle_outline, size: 16, color: AppColors.accentStart),
                      SizedBox(width: 4),
                      Text('Yeni', style: TextStyle(color: AppColors.accentStart, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: filteredCategories.isEmpty
                  ? const Center(child: Text('Henüz kategori yok, "Yeni" ile ekleyin.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = filteredCategories[index];
                        final isSelected = _selectedCategoryId == cat.id;
                        return ChoiceChip(
                          label: Text(cat.name),
                          selected: isSelected,
                          onSelected: (val) => setState(() => _selectedCategoryId = cat.id),
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
            if (_isExpense) ...[
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
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isExpense ? AppColors.danger : AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    _isExpense ? 'Harcamayı Kaydet' : 'Geliri Kaydet',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
