import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/transaction_model.dart';
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

  // CATEGORIES
  Future<List<AppCategory>> getCategories() async {
    final res = await _client.from('categories').select().order('name');
    return (res as List).map((x) => AppCategory.fromJson(x)).toList();
  }

  // TRANSACTIONS
  Future<List<AppTransaction>> getTransactions() async {
    final res = await _client.from('transactions').select().order('date', ascending: false);
    return (res as List).map((x) => AppTransaction.fromJson(x)).toList();
  }

  Future<void> createTransaction(AppTransaction tx) async {
    await _client.from('transactions').insert(tx.toJson());
  }

  // REAL-TIME
  Stream<List<Map<String, dynamic>>> subscribeToTable(String table) {
    return _client.from(table).stream(primaryKey: ['id']);
  }
}
