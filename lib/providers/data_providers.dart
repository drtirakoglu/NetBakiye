import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../models/transaction_model.dart';
import '../models/budget.dart';
import '../models/category.dart';
import 'auth_provider.dart';
import '../services/asset_price_service.dart';

final accountsStreamProvider = StreamProvider<List<AppAccount>>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return supabase.subscribeToTable('accounts').map((list) {
    return list.map((json) => AppAccount.fromJson(json)).toList();
  });
});

final categoriesStreamProvider = StreamProvider<List<AppCategory>>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return supabase.subscribeToTable('categories').map((list) {
    return list.map((json) => AppCategory.fromJson(json)).toList();
  });
});

final transactionsStreamProvider = StreamProvider<List<AppTransaction>>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return supabase.subscribeToTable('transactions').map((list) {
    return list.map((json) => AppTransaction.fromJson(json)).toList();
  });
});

final budgetsStreamProvider = StreamProvider<List<AppBudget>>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return supabase.subscribeToTable('budgets').map((list) {
    return list.map((json) => AppBudget.fromJson(json)).toList();
  });
});

/// A combined provider to calculate the summary values for the Dashboard
final dashboardSummaryProvider = Provider((ref) {
  final accounts = ref.watch(accountsStreamProvider).value ?? [];

  double totalAssets = 0.0;
  double totalDebts = 0.0;
  double projectedInterest = 0.0;

  for (final acc in accounts) {
    if (acc.balance > 0) {
      totalAssets += acc.balance;
    } else {
      totalDebts += acc.balance.abs();
      // KMH or CC interest projection simplified
      projectedInterest += (acc.balance.abs() * (acc.interestRate / 100));
    }
  }

  final netBalance = totalAssets - totalDebts;

  return {
    'netBalance': netBalance,
    'totalAssets': totalAssets,
    'totalDebts': totalDebts,
    'projectedInterest': projectedInterest,
    'safeToSpend': netBalance * 0.1, // Simplify for demo: 10% of net balance is safe
  };
});

final assetPriceServiceProvider = Provider((ref) {
  final service = AssetPriceService();
  service.startSimulating();
  ref.onDispose(() => service.dispose());
  return service;
});

final assetPriceProvider = StreamProvider<List<AssetPrice>>((ref) {
  return ref.watch(assetPriceServiceProvider).priceStream;
});

final aiAnalysisProvider = FutureProvider<String>((ref) async {
  final summary = ref.watch(dashboardSummaryProvider);
  final netBalance = summary['netBalance'] as double;
  final projectedInterest = summary['projectedInterest'] as double;

  await Future.delayed(const Duration(seconds: 1)); // Simulate AI thinking

  if (projectedInterest > 500) {
    return "Dikkat! Aylık borç maliyetin ${projectedInterest.toStringAsFixed(2)}₺. KMH ve Kredi Kartı asgari ödemelerini önceliklendirmelisin.";
  } else if (netBalance > 50000) {
    return "Harikasın! Birikimin artıyor. Altın veya mevduat faizi gibi düşük riskli yatırım araçlarını değerlendirebilirsin.";
  } else {
    return "Finansal sağlığın stabil görünüyor. 'Güvenli Harcama' limitini aşmadığın sürece bütçen koruma altında.";
  }
});
