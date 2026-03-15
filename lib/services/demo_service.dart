import 'dart:async';
import '../models/account.dart';
import '../models/category.dart';
import '../models/transaction_model.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/profile.dart';

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

    // Emit initial data
    _emitAll();
  }

  void _emitAll() {
    _accountsController.add(_accounts.map((a) => a.toJson()).toList());
    _categoriesController.add(_categories.map((c) => c.toJson()).toList());
    _transactionsController.add(_transactions.map((t) => t.toJson()).toList());
    _budgetsController.add(_budgets.map((b) => b.toJson()).toList());
    _goalsController.add(_goals.map((g) => g.toJson()).toList());
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
    }
  }

  void dispose() {
    _accountsController.close();
    _categoriesController.close();
    _transactionsController.close();
    _budgetsController.close();
    _goalsController.close();
  }
}
