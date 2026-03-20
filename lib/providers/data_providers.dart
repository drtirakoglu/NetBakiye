import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../models/transaction_model.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/goal.dart';
import '../models/fixed_payment.dart';

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

final fixedPaymentsStreamProvider = StreamProvider<List<FixedPayment>>((ref) {
  final demo = ref.watch(demoServiceProvider);
  return demo.subscribeToTable('fixed_payments').map((list) {
    return list.map((json) => FixedPayment.fromJson(json)).toList();
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
  final transactions = ref.watch(transactionsStreamProvider).value ?? [];
  final fixedPayments = ref.watch(fixedPaymentsStreamProvider).value ?? [];

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

  // Calculate Monthly History (Last 6 Months)
  final now = DateTime.now();
  final List<Map<String, dynamic>> monthlyHistory = [];
  for (int i = 5; i >= 0; i--) {
    final monthStart = DateTime(now.year, now.month - i, 1);
    final monthEnd = DateTime(now.year, now.month - i + 1, 0);
    
    double income = 0;
    double expense = 0;
    
    for (final tx in transactions) {
      if (tx.date.isAfter(monthStart.subtract(const Duration(seconds: 1))) && 
          tx.date.isBefore(monthEnd.add(const Duration(seconds: 1)))) {
        if (tx.amount > 0) income += tx.amount;
        else expense += tx.amount.abs();
      }
    }
    
    monthlyHistory.add({
      'month': "${monthStart.year}-${monthStart.month.toString().padLeft(2, '0')}",
      'income': income,
      'expense': expense,
      'net': income - expense,
    });
  }

  // Calculate Expected Payments
  final List<Map<String, dynamic>> expectedPayments = [];
  for (final fp in fixedPayments) {
    double amount = fp.amount;
    if (fp.isVariable) {
      // Calculate average of last 6 months for this category
      final categoryTxs = transactions.where((t) => t.categoryId == fp.categoryId && t.amount < 0);
      if (categoryTxs.isNotEmpty) {
        amount = categoryTxs.fold(0.0, (sum, t) => sum + t.amount.abs()) / 6;
      }
    }
    expectedPayments.add({
      'name': fp.name,
      'amount': amount,
      'date': DateTime(now.year, now.month, fp.dayOfMonth),
      'isFixed': !fp.isVariable,
    });
  }
  // Sort by date
  expectedPayments.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

  return {
    'netBalance': netBalance,
    'totalAssets': totalAssets,
    'totalDebts': totalDebts,
    'projectedInterest': projectedInterest,
    'safeToSpend': netBalance * 0.1,
    'monthlyHistory': monthlyHistory,
    'expectedPayments': expectedPayments,
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

// ─── Transaction Filter State ───────────────────────────────────────────────

enum TransactionPeriod { all, today, thisWeek, thisMonth, custom }

class TransactionFilter {
  final String? accountId;
  final String? categoryId;
  final bool? isExpense; // null = all
  final String searchQuery;
  final TransactionPeriod period;
  final DateTime? customFrom;
  final DateTime? customTo;

  const TransactionFilter({
    this.accountId,
    this.categoryId,
    this.isExpense,
    this.searchQuery = '',
    this.period = TransactionPeriod.all,
    this.customFrom,
    this.customTo,
  });

  TransactionFilter copyWith({
    Object? accountId = _sentinel,
    Object? categoryId = _sentinel,
    Object? isExpense = _sentinel,
    String? searchQuery,
    TransactionPeriod? period,
    Object? customFrom = _sentinel,
    Object? customTo = _sentinel,
  }) {
    return TransactionFilter(
      accountId: accountId == _sentinel ? this.accountId : accountId as String?,
      categoryId: categoryId == _sentinel ? this.categoryId : categoryId as String?,
      isExpense: isExpense == _sentinel ? this.isExpense : isExpense as bool?,
      searchQuery: searchQuery ?? this.searchQuery,
      period: period ?? this.period,
      customFrom: customFrom == _sentinel ? this.customFrom : customFrom as DateTime?,
      customTo: customTo == _sentinel ? this.customTo : customTo as DateTime?,
    );
  }
}

const _sentinel = Object();

final transactionFilterProvider = StateProvider<TransactionFilter>((ref) => const TransactionFilter());

final filteredTransactionsProvider = Provider<List<AppTransaction>>((ref) {
  final transactions = ref.watch(transactionsStreamProvider).value ?? [];
  final filter = ref.watch(transactionFilterProvider);
  final now = DateTime.now();

  return transactions.where((tx) {
    // Period filter
    final txDate = tx.date;
    switch (filter.period) {
      case TransactionPeriod.today:
        if (txDate.year != now.year || txDate.month != now.month || txDate.day != now.day) return false;
      case TransactionPeriod.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final wStart = DateTime(weekStart.year, weekStart.month, weekStart.day);
        if (txDate.isBefore(wStart)) return false;
      case TransactionPeriod.thisMonth:
        if (txDate.year != now.year || txDate.month != now.month) return false;
      case TransactionPeriod.custom:
        if (filter.customFrom != null && txDate.isBefore(filter.customFrom!)) return false;
        if (filter.customTo != null && txDate.isAfter(filter.customTo!.add(const Duration(days: 1)))) return false;
      case TransactionPeriod.all:
        break;
    }
    // Account filter
    if (filter.accountId != null && tx.accountId != filter.accountId) return false;
    // Category filter
    if (filter.categoryId != null && tx.categoryId != filter.categoryId) return false;
    // Income/Expense filter
    if (filter.isExpense == true && tx.amount >= 0) return false;
    if (filter.isExpense == false && tx.amount < 0) return false;
    // Search
    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      if (!(tx.note?.toLowerCase().contains(q) ?? false)) return false;
    }
    return true;
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});

// ─── Reports Period State ────────────────────────────────────────────────────

enum ReportPeriod { thisWeek, thisMonth, thisYear, custom }

final reportPeriodProvider = StateProvider<ReportPeriod>((ref) => ReportPeriod.thisMonth);

final reportsDataProvider = Provider<Map<String, dynamic>>((ref) {
  final transactions = ref.watch(transactionsStreamProvider).value ?? [];
  final categories = ref.watch(categoriesStreamProvider).value ?? [];
  final period = ref.watch(reportPeriodProvider);
  final now = DateTime.now();

  DateTime from;
  DateTime to = now;
  switch (period) {
    case ReportPeriod.thisWeek:
      from = now.subtract(Duration(days: now.weekday - 1));
      from = DateTime(from.year, from.month, from.day);
    case ReportPeriod.thisMonth:
      from = DateTime(now.year, now.month, 1);
    case ReportPeriod.thisYear:
      from = DateTime(now.year, 1, 1);
    case ReportPeriod.custom:
      from = DateTime(now.year, now.month, 1);
  }

  final periodTxs = transactions.where((tx) =>
    tx.date.isAfter(from.subtract(const Duration(seconds: 1))) &&
    tx.date.isBefore(to.add(const Duration(days: 1)))).toList();

  double totalIncome = 0;
  double totalExpense = 0;
  final Map<String, double> categoryExpense = {};

  for (final tx in periodTxs) {
    if (tx.amount > 0) {
      totalIncome += tx.amount;
    } else {
      totalExpense += tx.amount.abs();
      if (tx.categoryId != null) {
        categoryExpense[tx.categoryId!] = (categoryExpense[tx.categoryId!] ?? 0) + tx.amount.abs();
      }
    }
  }

  final categoryBreakdown = categoryExpense.entries.map((e) {
    final cat = categories.firstWhere((c) => c.id == e.key,
        orElse: () => AppCategory(id: e.key, userId: '', name: 'Diğer'));
    return {
      'categoryId': e.key,
      'name': cat.name,
      'color': cat.color ?? '#8B949E',
      'amount': e.value,
      'percent': totalExpense > 0 ? (e.value / totalExpense * 100) : 0.0,
    };
  }).toList()
    ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

  // Monthly bar data (last 6 months)
  final List<Map<String, dynamic>> monthlyBars = [];
  for (int i = 5; i >= 0; i--) {
    final mStart = DateTime(now.year, now.month - i, 1);
    final mEnd = DateTime(now.year, now.month - i + 1, 0);
    double inc = 0, exp = 0;
    for (final tx in transactions) {
      if (tx.date.isAfter(mStart.subtract(const Duration(seconds: 1))) &&
          tx.date.isBefore(mEnd.add(const Duration(seconds: 1)))) {
        if (tx.amount > 0) inc += tx.amount;
        else exp += tx.amount.abs();
      }
    }
    monthlyBars.add({
      'label': '${mStart.month}/${mStart.year.toString().substring(2)}',
      'income': inc,
      'expense': exp,
    });
  }

  return {
    'totalIncome': totalIncome,
    'totalExpense': totalExpense,
    'netSavings': totalIncome - totalExpense,
    'categoryBreakdown': categoryBreakdown,
    'monthlyBars': monthlyBars,
  };
});

// ─── Calendar Provider ───────────────────────────────────────────────────────

final selectedCalendarMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

final calendarEventsProvider = Provider<Map<int, List<Map<String, dynamic>>>>((ref) {
  final transactions = ref.watch(transactionsStreamProvider).value ?? [];
  final fixedPayments = ref.watch(fixedPaymentsStreamProvider).value ?? [];
  final selectedMonth = ref.watch(selectedCalendarMonthProvider);

  final Map<int, List<Map<String, dynamic>>> events = {};

  // Add transactions for selected month
  for (final tx in transactions) {
    if (tx.date.year == selectedMonth.year && tx.date.month == selectedMonth.month) {
      final day = tx.date.day;
      events[day] ??= [];
      events[day]!.add({'type': 'transaction', 'data': tx});
    }
  }

  // Add fixed payments for selected month
  for (final fp in fixedPayments) {
    final day = fp.dayOfMonth;
    events[day] ??= [];
    events[day]!.add({'type': 'fixedPayment', 'data': fp});
  }

  return events;
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
