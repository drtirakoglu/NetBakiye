import 'dart:async';
import '../models/account.dart';
import '../models/category.dart';
import '../models/transaction_model.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/profile.dart';
import '../models/fixed_payment.dart';

/// A fully local, in-memory service for demo mode.
/// No Supabase connection required.
class DemoService {
  static const String demoUserId = 'demo-user-001';

  // In-memory data stores
  final List<AppAccount> _accounts = [];
  final List<AppCategory> _categories = [];
  final List<AppTransaction> _transactions = [];
  final List<AppBudget> _budgets = [];
  final List<AppGoal> _goals = [];
  final List<FixedPayment> _fixedPayments = [];
  final List<Map<String, dynamic>> _sharedUsers = [];
  AppProfile _profile = AppProfile(
    id: demoUserId,
    displayName: 'Demo Kullanıcı',
    email: 'demo@netbakiye.app',
    currency: 'TRY',
    themeColor: 'teal',
    createdAt: DateTime.now(),
  );

  // Stream controllers for real-time updates
  final _accountsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _categoriesController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _transactionsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _budgetsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _goalsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _fixedPaymentsController = StreamController<List<Map<String, dynamic>>>.broadcast();

  DemoService() {
    _initDemoData();
  }

  void _initDemoData() {
    // Demo accounts
    _accounts.addAll([
      AppAccount(id: 'acc-1', userId: demoUserId, name: 'Akbank Vadesiz', type: AccountType.vadesiz, balance: 45200.0),
      AppAccount(id: 'acc-2', userId: demoUserId, name: 'Garanti Kredi Kartı', type: AccountType.krediKarti, balance: -12800.0, creditLimit: 50000.0, interestRate: 4.25),
      AppAccount(id: 'acc-3', userId: demoUserId, name: 'İş Bankası KMH', type: AccountType.kmh, balance: -3500.0, interestRate: 3.79),
    ]);

    // Demo categories
    _categories.addAll([
      AppCategory(id: 'cat-1', userId: demoUserId, name: 'Gıda', icon: 'restaurant', color: '#4ADE80', isIncome: false),
      AppCategory(id: 'cat-2', userId: demoUserId, name: 'Ulaşım', icon: 'directions_car', color: '#60A5FA', isIncome: false),
      AppCategory(id: 'cat-3', userId: demoUserId, name: 'Faturalar', icon: 'receipt', color: '#FBBF24', isIncome: false),
      AppCategory(id: 'cat-4', userId: demoUserId, name: 'Eğlence', icon: 'celebration', color: '#F472B6', isIncome: false),
      AppCategory(id: 'cat-5', userId: demoUserId, name: 'Sağlık', icon: 'health', color: '#F87171', isIncome: false),
      AppCategory(id: 'cat-6', userId: demoUserId, name: 'Maaş', icon: 'payments', color: '#34D399', isIncome: true),
      AppCategory(id: 'cat-7', userId: demoUserId, name: 'Freelance', icon: 'work', color: '#A78BFA', isIncome: true),
      AppCategory(id: 'cat-8', userId: demoUserId, name: 'Sürpriz Gelir', icon: 'card_giftcard', color: '#FB923C', isIncome: true),
    ]);

    // Demo budgets
    _budgets.addAll([
      AppBudget(id: 'bud-1', userId: demoUserId, categoryId: 'cat-1', month: '2026-03', allocated: 5000.0, spent: 3200.0),
      AppBudget(id: 'bud-2', userId: demoUserId, categoryId: 'cat-2', month: '2026-03', allocated: 2000.0, spent: 1800.0),
      AppBudget(id: 'bud-3', userId: demoUserId, categoryId: 'cat-3', month: '2026-03', allocated: 3500.0, spent: 3500.0),
      AppBudget(id: 'bud-4', userId: demoUserId, categoryId: 'cat-4', month: '2026-03', allocated: 1500.0, spent: 750.0),
    ]);

    // Demo goals
    _goals.addAll([
      AppGoal(id: 'goal-1', userId: demoUserId, name: 'Yeni Araba Peşinatı', category: 'Araba', targetAmount: 450000, savedAmount: 125000, icon: 'car', deadline: DateTime(2027, 6, 1)),
      AppGoal(id: 'goal-2', userId: demoUserId, name: 'Yaz Tatili 2026', category: 'Tatil', targetAmount: 60000, savedAmount: 60000, icon: 'beach'),
      AppGoal(id: 'goal-3', userId: demoUserId, name: 'Acil Durum Fonu', category: 'Birikim', targetAmount: 100000, savedAmount: 32000, icon: 'savings'),
    ]);

    // Demo fixed payments
    _fixedPayments.addAll([
      FixedPayment(id: 'fp-1', userId: demoUserId, name: 'Kira', amount: 15000.0, categoryId: 'cat-3', isVariable: false, dayOfMonth: 1),
      FixedPayment(id: 'fp-2', userId: demoUserId, name: 'Netflix', amount: 180.0, categoryId: 'cat-4', isVariable: false, dayOfMonth: 15),
      FixedPayment(id: 'fp-3', userId: demoUserId, name: 'Elektrik (Tahmini)', amount: 850.0, categoryId: 'cat-3', isVariable: true, dayOfMonth: 20),
      FixedPayment(id: 'fp-4', userId: demoUserId, name: 'Su (Tahmini)', amount: 320.0, categoryId: 'cat-3', isVariable: true, dayOfMonth: 22),
    ]);

    // Demo transactions - rich dataset for last 6 months
    final now = DateTime.now();

    // Helper to create a date in current month
    DateTime d(int daysAgo) => now.subtract(Duration(days: daysAgo));

    // Current month transactions
    _transactions.addAll([
      AppTransaction(id: 'tx-001', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-6', amount: 35000.0, note: 'Mart ayı maaşı', date: d(18)),
      AppTransaction(id: 'tx-002', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-3', amount: -15000.0, note: 'Kira - Mart', date: d(17)),
      AppTransaction(id: 'tx-003', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-1', amount: -420.0, note: 'Migros alışveriş', date: d(16)),
      AppTransaction(id: 'tx-004', userId: demoUserId, accountId: 'acc-2', categoryId: 'cat-1', amount: -285.0, note: 'Getir market', date: d(15)),
      AppTransaction(id: 'tx-005', userId: demoUserId, accountId: 'acc-2', categoryId: 'cat-4', amount: -180.0, note: 'Netflix abonelik', date: d(15)),
      AppTransaction(id: 'tx-006', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-2', amount: -350.0, note: 'Akaryakıt', date: d(14)),
      AppTransaction(id: 'tx-007', userId: demoUserId, accountId: 'acc-2', categoryId: 'cat-1', amount: -195.0, note: 'Kahve & kafeterya', date: d(13)),
      AppTransaction(id: 'tx-008', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-7', amount: 8500.0, note: 'Freelance proje ödemesi', date: d(12)),
      AppTransaction(id: 'tx-009', userId: demoUserId, accountId: 'acc-2', categoryId: 'cat-5', amount: -650.0, note: 'Eczane', date: d(11)),
      AppTransaction(id: 'tx-010', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-2', amount: -180.0, note: 'Metrobüs - aylık kart', date: d(10)),
      AppTransaction(id: 'tx-011', userId: demoUserId, accountId: 'acc-2', categoryId: 'cat-1', amount: -540.0, note: 'A101 market', date: d(9)),
      AppTransaction(id: 'tx-012', userId: demoUserId, accountId: 'acc-2', categoryId: 'cat-4', amount: -320.0, note: 'Sinema & yemek', date: d(8)),
      AppTransaction(id: 'tx-013', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-3', amount: -820.0, note: 'Elektrik faturası', date: d(7)),
      AppTransaction(id: 'tx-014', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-3', amount: -340.0, note: 'Su faturası', date: d(6)),
      AppTransaction(id: 'tx-015', userId: demoUserId, accountId: 'acc-2', categoryId: 'cat-1', amount: -780.0, note: 'Haftalık market', date: d(5)),
      AppTransaction(id: 'tx-016', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-2', amount: -220.0, note: 'Park ücreti', date: d(4)),
      AppTransaction(id: 'tx-017', userId: demoUserId, accountId: 'acc-2', categoryId: 'cat-5', amount: -280.0, note: 'Diş hekimi', date: d(3)),
      AppTransaction(id: 'tx-018', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-8', amount: 2000.0, note: 'Doğum günü hediyesi', date: d(2)),
      AppTransaction(id: 'tx-019', userId: demoUserId, accountId: 'acc-2', categoryId: 'cat-1', amount: -155.0, note: 'Fırın & pastane', date: d(1)),
      AppTransaction(id: 'tx-020', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-4', amount: -450.0, note: 'Spor salonu üyeliği', date: d(0)),
    ]);

    // Last month transactions
    _transactions.addAll([
      AppTransaction(id: 'tx-101', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-6', amount: 35000.0, note: 'Şubat ayı maaşı', date: DateTime(now.year, now.month - 1, 1)),
      AppTransaction(id: 'tx-102', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-3', amount: -15000.0, note: 'Kira - Şubat', date: DateTime(now.year, now.month - 1, 2)),
      AppTransaction(id: 'tx-103', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-1', amount: -3800.0, note: 'Aylık market harcaması', date: DateTime(now.year, now.month - 1, 10)),
      AppTransaction(id: 'tx-104', userId: demoUserId, accountId: 'acc-2', categoryId: 'cat-2', amount: -1650.0, note: 'Ulaşım harcamaları', date: DateTime(now.year, now.month - 1, 15)),
      AppTransaction(id: 'tx-105', userId: demoUserId, accountId: 'acc-2', categoryId: 'cat-4', amount: -900.0, note: 'Eğlence', date: DateTime(now.year, now.month - 1, 20)),
      AppTransaction(id: 'tx-106', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-3', amount: -800.0, note: 'Elektrik faturası', date: DateTime(now.year, now.month - 1, 20)),
      AppTransaction(id: 'tx-107', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-7', amount: 5000.0, note: 'Freelance ek gelir', date: DateTime(now.year, now.month - 1, 25)),
    ]);

    // 2 months ago
    _transactions.addAll([
      AppTransaction(id: 'tx-201', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-6', amount: 35000.0, note: 'Ocak ayı maaşı', date: DateTime(now.year, now.month - 2, 1)),
      AppTransaction(id: 'tx-202', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-3', amount: -15000.0, note: 'Kira - Ocak', date: DateTime(now.year, now.month - 2, 2)),
      AppTransaction(id: 'tx-203', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-1', amount: -4200.0, note: 'Market harcaması', date: DateTime(now.year, now.month - 2, 12)),
      AppTransaction(id: 'tx-204', userId: demoUserId, accountId: 'acc-2', categoryId: 'cat-2', amount: -1800.0, note: 'Ulaşım', date: DateTime(now.year, now.month - 2, 18)),
      AppTransaction(id: 'tx-205', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-3', amount: -860.0, note: 'Elektrik faturası', date: DateTime(now.year, now.month - 2, 20)),
    ]);

    // 3 months ago
    _transactions.addAll([
      AppTransaction(id: 'tx-301', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-6', amount: 33000.0, note: 'Aralık ayı maaşı', date: DateTime(now.year, now.month - 3, 1)),
      AppTransaction(id: 'tx-302', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-3', amount: -15000.0, note: 'Kira', date: DateTime(now.year, now.month - 3, 2)),
      AppTransaction(id: 'tx-303', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-1', amount: -5500.0, note: 'Yılbaşı market', date: DateTime(now.year, now.month - 3, 20)),
      AppTransaction(id: 'tx-304', userId: demoUserId, accountId: 'acc-2', categoryId: 'cat-4', amount: -2800.0, note: 'Yılbaşı kutlaması', date: DateTime(now.year, now.month - 3, 31)),
      AppTransaction(id: 'tx-305', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-3', amount: -780.0, note: 'Elektrik faturası', date: DateTime(now.year, now.month - 3, 20)),
    ]);

    // 4 months ago
    _transactions.addAll([
      AppTransaction(id: 'tx-401', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-6', amount: 33000.0, note: 'Kasım ayı maaşı', date: DateTime(now.year, now.month - 4, 1)),
      AppTransaction(id: 'tx-402', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-3', amount: -15000.0, note: 'Kira', date: DateTime(now.year, now.month - 4, 2)),
      AppTransaction(id: 'tx-403', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-1', amount: -3600.0, note: 'Market', date: DateTime(now.year, now.month - 4, 15)),
      AppTransaction(id: 'tx-404', userId: demoUserId, accountId: 'acc-2', categoryId: 'cat-2', amount: -1500.0, note: 'Ulaşım', date: DateTime(now.year, now.month - 4, 18)),
      AppTransaction(id: 'tx-405', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-3', amount: -840.0, note: 'Elektrik faturası', date: DateTime(now.year, now.month - 4, 20)),
    ]);

    // 5 months ago
    _transactions.addAll([
      AppTransaction(id: 'tx-501', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-6', amount: 33000.0, note: 'Ekim ayı maaşı', date: DateTime(now.year, now.month - 5, 1)),
      AppTransaction(id: 'tx-502', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-3', amount: -15000.0, note: 'Kira', date: DateTime(now.year, now.month - 5, 2)),
      AppTransaction(id: 'tx-503', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-1', amount: -3400.0, note: 'Market', date: DateTime(now.year, now.month - 5, 15)),
      AppTransaction(id: 'tx-504', userId: demoUserId, accountId: 'acc-2', categoryId: 'cat-2', amount: -1400.0, note: 'Ulaşım', date: DateTime(now.year, now.month - 5, 18)),
      AppTransaction(id: 'tx-505', userId: demoUserId, accountId: 'acc-1', categoryId: 'cat-3', amount: -800.0, note: 'Elektrik faturası', date: DateTime(now.year, now.month - 5, 20)),
    ]);

    // Emit initial data
    _emitAll();
  }

  void _emitAll() {
    _accountsController.add(_accounts.map((a) => a.toJson()).toList());
    _categoriesController.add(_categories.map((c) => c.toJson()).toList());
    _transactionsController.add(_transactions.map((t) => t.toJson()).toList());
    _budgetsController.add(_budgets.map((b) => b.toJson()).toList());
    _goalsController.add(_goals.map((g) => g.toJson()).toList());
    _fixedPaymentsController.add(_fixedPayments.map((fp) => fp.toJson()).toList());
  }

  // AUTH (simulated)
  String get currentUserId => demoUserId;

  // PROFILE
  Future<AppProfile?> getProfile(String id) async => _profile;
  Future<void> updateProfile(AppProfile profile) async {
    _profile = profile;
  }

  // ACCOUNTS
  Future<void> createAccount(AppAccount account) async {
    _accounts.add(account);
    _accountsController.add(_accounts.map((a) => a.toJson()).toList());
  }

  Future<void> updateAccount(AppAccount account) async {
    _accounts.removeWhere((a) => a.id == account.id);
    _accounts.add(account);
    _accountsController.add(_accounts.map((a) => a.toJson()).toList());
  }

  Future<void> deleteAccount(String id) async {
    _accounts.removeWhere((a) => a.id == id);
    _accountsController.add(_accounts.map((a) => a.toJson()).toList());
  }

  // CATEGORIES
  Future<void> createCategory(AppCategory category) async {
    _categories.add(category);
    _categoriesController.add(_categories.map((c) => c.toJson()).toList());
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    _categoriesController.add(_categories.map((c) => c.toJson()).toList());
  }

  // TRANSACTIONS
  Future<void> createTransaction(AppTransaction tx) async {
    _transactions.add(tx);
    _transactionsController.add(_transactions.map((t) => t.toJson()).toList());
  }

  // BUDGETS
  Future<void> createBudget(AppBudget budget) async {
    _budgets.add(budget);
    _budgetsController.add(_budgets.map((b) => b.toJson()).toList());
  }

  Future<void> updateBudget(AppBudget budget) async {
    _budgets.removeWhere((b) => b.id == budget.id);
    _budgets.add(budget);
    _budgetsController.add(_budgets.map((b) => b.toJson()).toList());
  }

  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    _budgetsController.add(_budgets.map((b) => b.toJson()).toList());
  }

  // GOALS
  Future<void> createGoal(AppGoal goal) async {
    _goals.add(goal);
    _goalsController.add(_goals.map((g) => g.toJson()).toList());
  }

  Future<void> updateGoal(AppGoal goal) async {
    _goals.removeWhere((g) => g.id == goal.id);
    _goals.add(goal);
    _goalsController.add(_goals.map((g) => g.toJson()).toList());
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    _goalsController.add(_goals.map((g) => g.toJson()).toList());
  }

  // FIXED PAYMENTS
  Future<void> createFixedPayment(FixedPayment fp) async {
    _fixedPayments.add(fp);
    _fixedPaymentsController.add(_fixedPayments.map((f) => f.toJson()).toList());
  }

  Future<void> updateFixedPayment(FixedPayment fp) async {
    _fixedPayments.removeWhere((f) => f.id == fp.id);
    _fixedPayments.add(fp);
    _fixedPaymentsController.add(_fixedPayments.map((f) => f.toJson()).toList());
  }

  Future<void> deleteFixedPayment(String id) async {
    _fixedPayments.removeWhere((f) => f.id == id);
    _fixedPaymentsController.add(_fixedPayments.map((f) => f.toJson()).toList());
  }

  // SHARED USERS
  Future<List<Map<String, dynamic>>> getSharedUsers() async => _sharedUsers;
  Future<void> addSharedUser(String email) async {
    _sharedUsers.add({
      'id': 'su-${_sharedUsers.length + 1}',
      'owner_id': demoUserId,
      'shared_with_id': 'user-${_sharedUsers.length + 1}',
      'profiles': {'display_name': email},
    });
  }
  Future<void> removeSharedUser(String id) async {
    _sharedUsers.removeWhere((u) => u['id'] == id);
  }

  // STREAMS
  Stream<List<Map<String, dynamic>>> subscribeToTable(String table) async* {
    // First yield the current data immediately
    switch (table) {
      case 'accounts':
        yield _accounts.map((a) => a.toJson()).toList();
        yield* _accountsController.stream;
      case 'categories':
        yield _categories.map((c) => c.toJson()).toList();
        yield* _categoriesController.stream;
      case 'transactions':
        yield _transactions.map((t) => t.toJson()).toList();
        yield* _transactionsController.stream;
      case 'budgets':
        yield _budgets.map((b) => b.toJson()).toList();
        yield* _budgetsController.stream;
      case 'goals':
        yield _goals.map((g) => g.toJson()).toList();
        yield* _goalsController.stream;
      case 'fixed_payments':
        yield _fixedPayments.map((fp) => fp.toJson()).toList();
        yield* _fixedPaymentsController.stream;
    }
  }

  void dispose() {
    _accountsController.close();
    _categoriesController.close();
    _transactionsController.close();
    _budgetsController.close();
    _goalsController.close();
    _fixedPaymentsController.close();
  }
}
