import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/transaction_model.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/profile.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // AUTH
  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // PROFILE
  Future<AppProfile?> getProfile(String id) async {
    final res = await _client.from('profiles').select().eq('id', id).maybeSingle();
    return res != null ? AppProfile.fromJson(res) : null;
  }

  Future<void> updateProfile(AppProfile profile) async {
    await _client.from('profiles').update(profile.toJson()).eq('id', profile.id);
  }

  // ACCOUNTS
  Future<List<AppAccount>> getAccounts() async {
    final res = await _client.from('accounts').select().order('created_at');
    return (res as List).map((x) => AppAccount.fromJson(x)).toList();
  }

  Future<void> createAccount(AppAccount account) async {
    await _client.from('accounts').insert(account.toJson());
  }

  Future<void> updateAccount(AppAccount account) async {
    await _client.from('accounts').update(account.toJson()).eq('id', account.id);
  }

  Future<void> deleteAccount(String id) async {
    await _client.from('accounts').delete().eq('id', id);
  }

  // CATEGORIES
  Future<List<AppCategory>> getCategories() async {
    final res = await _client.from('categories').select().order('name');
    return (res as List).map((x) => AppCategory.fromJson(x)).toList();
  }

  Future<void> createCategory(AppCategory category) async {
    await _client.from('categories').insert(category.toJson());
  }

  Future<void> deleteCategory(String id) async {
    await _client.from('categories').delete().eq('id', id);
  }

  // TRANSACTIONS
  Future<List<AppTransaction>> getTransactions() async {
    final res = await _client.from('transactions').select().order('date', ascending: false);
    return (res as List).map((x) => AppTransaction.fromJson(x)).toList();
  }

  Future<void> createTransaction(AppTransaction tx) async {
    await _client.from('transactions').insert(tx.toJson());
  }

  // BUDGETS
  Future<void> createBudget(AppBudget budget) async {
    await _client.from('budgets').insert(budget.toJson());
  }

  Future<void> updateBudget(AppBudget budget) async {
    await _client.from('budgets').update(budget.toJson()).eq('id', budget.id);
  }

  Future<void> deleteBudget(String id) async {
    await _client.from('budgets').delete().eq('id', id);
  }

  // GOALS
  Future<void> createGoal(AppGoal goal) async {
    await _client.from('goals').insert(goal.toJson());
  }

  Future<void> updateGoal(AppGoal goal) async {
    await _client.from('goals').update(goal.toJson()).eq('id', goal.id);
  }

  Future<void> deleteGoal(String id) async {
    await _client.from('goals').delete().eq('id', id);
  }

  // SHARED USERS
  Future<List<Map<String, dynamic>>> getSharedUsers() async {
    final userId = currentUser?.id;
    if (userId == null) return [];
    final res = await _client
        .from('shared_users')
        .select('*, profiles!shared_users_shared_with_id_fkey(display_name)')
        .eq('owner_id', userId);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> addSharedUser(String sharedWithEmail) async {
    final userId = currentUser?.id;
    if (userId == null) return;
    // Look up the user by email from profiles
    final profile = await _client
        .from('profiles')
        .select()
        .eq('email', sharedWithEmail)
        .maybeSingle();
    if (profile != null) {
      await _client.from('shared_users').insert({
        'owner_id': userId,
        'shared_with_id': profile['id'],
      });
    }
  }

  Future<void> removeSharedUser(String sharedUserId) async {
    await _client.from('shared_users').delete().eq('id', sharedUserId);
  }

  // REAL-TIME
  Stream<List<Map<String, dynamic>>> subscribeToTable(String table) {
    return _client.from(table).stream(primaryKey: ['id']);
  }
}
