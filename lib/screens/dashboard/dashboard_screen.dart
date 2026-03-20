import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/data_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import 'widgets/quick_add_sheet.dart';
import 'widgets/balance_hero_card.dart';
import 'widgets/monthly_status_chart.dart';
import 'widgets/safe_to_spend_card.dart';
import 'widgets/alert_card.dart';
import 'widgets/cashflow_trend_card.dart';
import 'widgets/top_categories_card.dart';
import 'widgets/upcoming_payments_card.dart';
import 'widgets/budget_summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final transactions = ref.watch(transactionsStreamProvider).value ?? [];
    final categories = ref.watch(categoriesStreamProvider).value ?? [];
    final budgets = ref.watch(budgetsStreamProvider).value ?? [];

    final netBalance = summary['netBalance'] as double;
    final totalAssets = summary['totalAssets'] as double;
    final totalDebts = summary['totalDebts'] as double;
    final projectedInterest = summary['projectedInterest'] as double;
    final safeToSpend = summary['safeToSpend'] as double;
    final history = summary['monthlyHistory'] as List<Map<String, dynamic>>;
    final expectedPayments = summary['expectedPayments'] as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentStart, AppColors.accentEnd],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Text('NetBakiye'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Bildirimler',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ayarlar',
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
            CashflowTrendCard(monthlyHistory: history),
            const SizedBox(height: 16),
            MonthlyStatusChart(history: history),
            const SizedBox(height: 16),
            SafeToSpendCard(
              safeAmount: safeToSpend,
              netInterest: projectedInterest,
            ),
            const SizedBox(height: 16),
            TopCategoriesCard(transactions: transactions, categories: categories),
            const SizedBox(height: 16),
            UpcomingPaymentsCard(expectedPayments: expectedPayments),
            const SizedBox(height: 16),
            BudgetSummaryCard(budgets: budgets, categories: categories),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Yönetici Uyarıları',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
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
            if (expectedPayments.isNotEmpty) ...[
              const SizedBox(height: 12),
              AlertCard(
                title: 'Taksit Hatırlatıcı',
                desc: 'Gelecek ödemelerin: ${expectedPayments.map((p) => "${p['name']} (${Formatters.formatCurrency(p['amount'])})").join(", ")}',
                icon: Icons.timer_outlined,
                color: AppColors.info,
              ),
            ],
            const SizedBox(height: 80),
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
