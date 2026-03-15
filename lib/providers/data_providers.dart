import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../models/transaction_model.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/goal.dart';

import '../services/asset_price_service.dart';
import '../services/demo_service.dart';

/// Global demo service instance
final demoServiceProvider = Provider((ref) => DemoService());

final accountsStreamProvider = StreamProvider<List<AppAccount>>((ref) {
  final demo = ref.watch(demoServiceProvider);
  return demo.subscribeToTable('accounts').map((list) {
    return list.map((json) => AppAccount.fromJson(json)).toList();
  });
});

final categoriesStreamProvider = StreamProvider<List<AppCategory>>((ref) {
  final demo = ref.watch(demoServiceProvider);
  return demo.subscribeToTable('categories').map((list) {
    return list.map((json) => AppCategory.fromJson(json)).toList();
  });
});

final transactionsStreamProvider = StreamProvider<List<AppTransaction>>((ref) {
  final demo = ref.watch(demoServiceProvider);
  return demo.subscribeToTable('transactions').map((list) {
    return list.map((json) => AppTransaction.fromJson(json)).toList();
  });
});

final budgetsStreamProvider = StreamProvider<List<AppBudget>>((ref) {
  final demo = ref.watch(demoServiceProvider);
  return demo.subscribeToTable('budgets').map((list) {
    return list.map((json) => AppBudget.fromJson(json)).toList();
  });
});

final goalsStreamProvider = StreamProvider<List<AppGoal>>((ref) {
  final demo = ref.watch(demoServiceProvider);
  return demo.subscribeToTable('goals').map((list) {
    return list.map((json) => AppGoal.fromJson(json)).toList();
  });
});

/// Theme color provider
final themeColorProvider = StateProvider<String>((ref) => 'teal');

/// Maps theme color name to actual color values
Map<String, Color> get themeColorMap => {
  'teal': const Color(0xFF0DBCB5),
  'purple': const Color(0xFF8B5CF6),
  'blue': const Color(0xFF3B82F6),
  'orange': const Color(0xFFF97316),
  'rose': const Color(0xFFF43F5E),
};

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
      projectedInterest += (acc.balance.abs() * (acc.interestRate / 100));
    }
  }

  final netBalance = totalAssets - totalDebts;

  return {
    'netBalance': netBalance,
    'totalAssets': totalAssets,
    'totalDebts': totalDebts,
    'projectedInterest': projectedInterest,
    'safeToSpend': netBalance * 0.1,
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

  await Future.delayed(const Duration(seconds: 1));

  if (projectedInterest > 500) {
    return "Dikkat! Aylık borç maliyetin ${projectedInterest.toStringAsFixed(2)}₺. KMH ve Kredi Kartı asgari ödemelerini önceliklendirmelisin.";
  } else if (netBalance > 50000) {
    return "Harikasın! Birikimin artıyor. Altın veya mevduat faizi gibi düşük riskli yatırım araçlarını değerlendirebilirsin.";
  } else {
    return "Finansal sağlığın stabil görünüyor. 'Güvenli Harcama' limitini aşmadığın sürece bütçen koruma altında.";
  }
});
