import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/data_providers.dart';

import '../../models/account.dart';
import '../../services/asset_price_service.dart';
import '../../theme/app_colors.dart';
import 'widgets/account_card.dart';
import 'widgets/asset_tile.dart';
import 'package:uuid/uuid.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final pricesAsync = ref.watch(assetPriceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hesaplar')),
      body: accountsAsync.when(
        data: (accounts) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Bakiye ve Kartlar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              if (accounts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.account_balance_outlined, size: 48, color: AppColors.textMuted),
                      SizedBox(height: 12),
                      Text('Henüz hesap eklenmemiş', style: TextStyle(color: AppColors.textSecondary)),
                      SizedBox(height: 4),
                      Text('Sağ alttaki butona tıklayarak yeni hesap ekleyin.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...accounts.map((acc) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AccountCard(
                    name: acc.name,
                    type: acc.type.toString().split('.').last,
                    balance: acc.balance,
                    icon: acc.balance < 0 ? Icons.credit_card : Icons.account_balance_outlined,
                    color: acc.balance < 0 ? AppColors.danger : AppColors.primary,
                    limit: acc.type == AccountType.krediKarti ? acc.creditLimit : null,
                    interestRate: acc.interestRate > 0 ? acc.interestRate : null,
                  ),
                )),
              const SizedBox(height: 32),
            const Text(
              'Birikimler & Varlıklar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            pricesAsync.when(
              data: (prices) {
                final goldPrice = prices.firstWhere((p) => p.symbol == 'XAU', orElse: () => AssetPrice(symbol: 'XAU', price: 2450.0, change: 0)).price;
                final usdPrice = prices.firstWhere((p) => p.symbol == 'USD', orElse: () => AssetPrice(symbol: 'USD', price: 32.20, change: 0)).price;
                final bistPrice = prices.firstWhere((p) => p.symbol == 'BIST', orElse: () => AssetPrice(symbol: 'BIST', price: 9150.0, change: 0)).price;

                return Column(
                  children: [
                    AssetTile(
                        name: 'Çeyrek Altın', qty: '4 Adet', val: 4 * goldPrice * 1.6, icon: Icons.auto_awesome, 
                        change: prices.firstWhere((p) => p.symbol == 'XAU', orElse: () => AssetPrice(symbol: 'XAU', price: 2450.0, change: 0)).change),
                    const SizedBox(height: 12),
                    AssetTile(
                        name: 'ABD Doları', qty: '1.200 \$', val: 1200 * usdPrice, icon: Icons.attach_money,
                        change: prices.firstWhere((p) => p.symbol == 'USD', orElse: () => AssetPrice(symbol: 'USD', price: 32.20, change: 0)).change),
                    const SizedBox(height: 12),
                    AssetTile(
                        name: 'BIST 100', qty: 'Hisse Senedi', val: 24500.0 * (bistPrice / 9150.0), icon: Icons.show_chart,
                        change: prices.firstWhere((p) => p.symbol == 'BIST', orElse: () => AssetPrice(symbol: 'BIST', price: 9150.0, change: 0)).change),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Fiyatlar alınamadı: $err'),
            ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err', style: const TextStyle(color: Colors.white))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    final limitController = TextEditingController();
    final interestController = TextEditingController();
    AccountType selectedType = AccountType.vadesiz;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Yeni Hesap', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Hesap Adı',
                    hintText: 'ör. Akbank Vadesiz',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AccountType>(
                  value: selectedType,
                  dropdownColor: AppColors.card,
                  decoration: const InputDecoration(
                    labelText: 'Hesap Türü',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: AccountType.vadesiz, child: Text('Vadesiz', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: AccountType.krediKarti, child: Text('Kredi Kartı', style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: AccountType.kmh, child: Text('KMH', style: TextStyle(color: Colors.white))),
                  ],
                  onChanged: (val) => setDialogState(() => selectedType = val!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: balanceController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: InputDecoration(
                    labelText: selectedType == AccountType.krediKarti ? 'Borç Tutarı (₺)' : 'Bakiye (₺)',
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (selectedType == AccountType.krediKarti) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: limitController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Kart Limiti (₺)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                if (selectedType != AccountType.vadesiz) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: interestController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Aylık Faiz Oranı (%)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentStart),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                double balance = double.tryParse(balanceController.text.replaceAll(',', '.')) ?? 0;
                if (selectedType == AccountType.krediKarti && balance > 0) {
                  balance = -balance; // Credit card debt is negative
                }

                final limit = double.tryParse(limitController.text.replaceAll(',', '.')) ?? 0;
                final interest = double.tryParse(interestController.text.replaceAll(',', '.')) ?? 0;

                final demo = ref.read(demoServiceProvider);
                final userId = demo.currentUserId;

                final account = AppAccount(
                  id: const Uuid().v4(),
                  userId: userId,
                  name: name,
                  type: selectedType,
                  balance: balance,
                  creditLimit: limit,
                  interestRate: interest,
                );
                await demo.createAccount(account);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Ekle', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
