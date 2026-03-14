import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/data_providers.dart';
import '../../models/account.dart';
import '../../services/asset_price_service.dart';
import '../../theme/app_colors.dart';
import 'widgets/account_card.dart';
import 'widgets/asset_tile.dart';

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
                        change: prices.firstWhere((p) => p.symbol == 'XAU').change),
                    const SizedBox(height: 12),
                    AssetTile(
                        name: 'ABD Doları', qty: '1.200 \$', val: 1200 * usdPrice, icon: Icons.attach_money,
                        change: prices.firstWhere((p) => p.symbol == 'USD').change),
                    const SizedBox(height: 12),
                    AssetTile(
                        name: 'BIST 100', qty: 'Hisse Senedi', val: 24500.0 * (bistPrice / 9150.0), icon: Icons.show_chart,
                        change: prices.firstWhere((p) => p.symbol == 'BIST').change),
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
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
