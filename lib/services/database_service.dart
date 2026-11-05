import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_record.dart';
import '../models/user_profile.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final _uuid = const Uuid();

  // In-memory & local cache storage for high-speed responsiveness
  final Map<String, List<TransactionRecord>> _userTransactions = {};
  final Map<String, UserProfile> _userProfiles = {};

  String? get supabaseUrl => dotenv.env['SUPABASE_URL'];
  String? get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'];
  String? get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'];

  bool get isBackendConfigured =>
      supabaseUrl != null &&
      !supabaseUrl!.contains('your-project') &&
      supabaseAnonKey != null &&
      !supabaseAnonKey!.contains('your-supabase');

  /// Seed initial realistic transactions for new user
  void _seedDefaultTransactionsIfEmpty(String userId) {
    if (_userTransactions.containsKey(userId) &&
        _userTransactions[userId]!.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final defaultList = [
      TransactionRecord(
        id: _uuid.v4(),
        userId: userId,
        title: 'Monthly Tech Salary',
        amount: 4800.00,
        type: TransactionType.income,
        categoryId: 'salary',
        date: DateTime(now.year, now.month, 1),
        notes: 'Monthly direct deposit paycheck',
      ),
      TransactionRecord(
        id: _uuid.v4(),
        userId: userId,
        title: 'Village Grocer Weekly',
        amount: 142.50,
        type: TransactionType.expense,
        categoryId: 'groceries',
        date: now.subtract(const Duration(days: 1)),
        notes: 'Fresh vegetables, milk, eggs, pantry staples',
      ),
      TransactionRecord(
        id: _uuid.v4(),
        userId: userId,
        title: 'Coffee & Breakfast Bistro',
        amount: 28.00,
        type: TransactionType.expense,
        categoryId: 'food_dining',
        date: now.subtract(const Duration(hours: 4)),
        notes: 'Americano & sourdough toast',
      ),
      TransactionRecord(
        id: _uuid.v4(),
        userId: userId,
        title: 'Electricity & Water Bill',
        amount: 115.80,
        type: TransactionType.expense,
        categoryId: 'bills_utilities',
        date: now.subtract(const Duration(days: 3)),
        notes: 'Monthly utility auto-debit',
      ),
      TransactionRecord(
        id: _uuid.v4(),
        userId: userId,
        title: 'Freelance Mobile UI Design',
        amount: 750.00,
        type: TransactionType.income,
        categoryId: 'freelance',
        date: now.subtract(const Duration(days: 4)),
        notes: 'Completed wireframe milestones',
      ),
      TransactionRecord(
        id: _uuid.v4(),
        userId: userId,
        title: 'Touch N Go / Transit Reload',
        amount: 50.00,
        type: TransactionType.expense,
        categoryId: 'transportation',
        date: now.subtract(const Duration(days: 6)),
        notes: 'MRT transit weekly commute reload',
      ),
    ];

    _userTransactions[userId] = defaultList;
  }

  /// Get user profile
  Future<UserProfile> getUserProfile({
    required String userId,
    required String email,
    required String displayName,
    String? photoUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!_userProfiles.containsKey(userId)) {
      _userProfiles[userId] = UserProfile(
        id: userId,
        email: email,
        displayName: displayName,
        avatarUrl: photoUrl,
        currency: 'RM',
        monthlyBudget: 2500.00,
      );
    }
    return _userProfiles[userId]!;
  }

  /// Update user monthly budget
  Future<UserProfile> updateMonthlyBudget(String userId, double newBudget) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (_userProfiles.containsKey(userId)) {
      _userProfiles[userId] = _userProfiles[userId]!.copyWith(
        monthlyBudget: newBudget,
      );
      return _userProfiles[userId]!;
    }
    throw Exception('User profile not found');
  }

  /// READ: Fetch transactions
  Future<List<TransactionRecord>> getTransactions(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _seedDefaultTransactionsIfEmpty(userId);

    final list = _userTransactions[userId] ?? [];
    // Sort descending by date
    list.sort((a, b) => b.date.compareTo(a.date));
    return List.from(list);
  }

  /// CREATE: Insert transaction
  Future<TransactionRecord> createTransaction(TransactionRecord transaction) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final userId = transaction.userId;
    if (!_userTransactions.containsKey(userId)) {
      _userTransactions[userId] = [];
    }

    final newRecord = transaction.id.isEmpty
        ? transaction.copyWith(id: _uuid.v4())
        : transaction;

    _userTransactions[userId]!.insert(0, newRecord);
    debugPrint('[DatabaseService] Created transaction: ${newRecord.title} - RM ${newRecord.amount}');
    return newRecord;
  }

  /// UPDATE: Modify existing transaction
  Future<TransactionRecord> updateTransaction(TransactionRecord updatedRecord) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final userId = updatedRecord.userId;
    final list = _userTransactions[userId];

    if (list != null) {
      final index = list.indexWhere((t) => t.id == updatedRecord.id);
      if (index != -1) {
        list[index] = updatedRecord.copyWith(updatedAt: DateTime.now());
        debugPrint('[DatabaseService] Updated transaction: ${updatedRecord.title}');
        return list[index];
      }
    }
    throw Exception('Transaction record not found: ${updatedRecord.id}');
  }

  /// DELETE: Remove transaction
  Future<bool> deleteTransaction(String transactionId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final list = _userTransactions[userId];

    if (list != null) {
      final initialCount = list.length;
      list.removeWhere((t) => t.id == transactionId);
      final removed = list.length < initialCount;
      debugPrint('[DatabaseService] Deleted transaction ($transactionId): $removed');
      return removed;
    }
    return false;
  }
}

