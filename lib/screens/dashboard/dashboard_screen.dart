import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/data_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import 'widgets/quick_add_sheet.dart';
import 'widgets/balance_hero_card.dart';
import 'widgets/mini_trend_chart.dart';
import 'widgets/safe_to_spend_card.dart';
import 'widgets/alert_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    
    final netBalance = summary['netBalance'] ?? 0.0;
    final totalAssets = summary['totalAssets'] ?? 0.0;
    final totalDebts = summary['totalDebts'] ?? 0.0;
    final projectedInterest = summary['projectedInterest'] ?? 0.0;
    final safeToSpend = summary['safeToSpend'] ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NetBakiye'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BalanceHeroCard(
              netBalance: netBalance,
              assets: totalAssets,
              debts: totalDebts,
            ),
            const SizedBox(height: 16),
            const MiniTrendChart(),
            const SizedBox(height: 24),
            SafeToSpendCard(
              safeAmount: safeToSpend,
              netInterest: projectedInterest,
            ),
            const SizedBox(height: 24),
            const Text(
              'Yönetici Uyarıları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            if (projectedInterest > 0) ...[
              const SizedBox(height: 12),
              AlertCard(
                title: 'Faiz Maliyeti Uyarısı',
                desc: 'Eksi bakiyeli hesaplarınız nedeniyle bu ay yaklaşık ${Formatters.formatCurrency(projectedInterest)} faiz maliyeti ödeyeceksiniz.',
                icon: Icons.warning_amber_rounded,
                color: AppColors.warning,
              ),
            ],
            const SizedBox(height: 12),
            const AlertCard(
              title: 'Taksit Hatırlatıcı',
              desc: 'Gelecek 30 gün içinde toplam 4 adet taksit ödemeniz bulunuyor.',
              icon: Icons.timer_outlined,
              color: AppColors.info,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const QuickAddSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
