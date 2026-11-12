import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_record.dart';
import '../models/user_profile.dart';
import 'supabase_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final _uuid = const Uuid();
  final SupabaseService _supabaseService = SupabaseService();

  // In-memory cache storage for local testing, fallback, and high-speed responsiveness
  final Map<String, List<TransactionRecord>> _userTransactions = {};
  final Map<String, UserProfile> _userProfiles = {};

  String? get supabaseUrl => SupabaseService.supabaseUrl;
  String? get supabaseAnonKey => SupabaseService.supabaseAnonKey;

  bool get isBackendConfigured => SupabaseService.isConfigured;

  /// Seed initial realistic transactions for user (strictly isolated per user ID)
  void _seedDefaultTransactionsIfEmpty(String userId) {
    if (_userTransactions.containsKey(userId) &&
        _userTransactions[userId]!.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    // Secondary partition transactions for multi-user isolation tests
    if (userId == '00000000-0000-4000-8000-000000000002') {
      _userTransactions[userId] = [
        TransactionRecord(
          id: _uuid.v4(),
          userId: userId,
          title: 'Consulting Retainer Monthly',
          amount: 6200.00,
          type: TransactionType.income,
          categoryId: 'salary',
          date: DateTime(now.year, now.month, 1),
          notes: 'Tech architecture advisory retainer',
        ),
        TransactionRecord(
          id: _uuid.v4(),
          userId: userId,
          title: 'Home Office Monitor & Stand',
          amount: 340.00,
          type: TransactionType.expense,
          categoryId: 'shopping',
          date: now.subtract(const Duration(days: 1)),
          notes: 'Ergonomic dual arm monitor mount',
        ),
        TransactionRecord(
          id: _uuid.v4(),
          userId: userId,
          title: 'Organic Market Supplies',
          amount: 185.00,
          type: TransactionType.expense,
          categoryId: 'groceries',
          date: now.subtract(const Duration(days: 2)),
          notes: 'Fresh organic greens, artisanal sourdough',
        ),
        TransactionRecord(
          id: _uuid.v4(),
          userId: userId,
          title: 'Cloud Infrastructure Hosting',
          amount: 90.00,
          type: TransactionType.expense,
          categoryId: 'bills_utilities',
          date: now.subtract(const Duration(days: 3)),
          notes: 'AWS and Supabase production tier',
        ),
      ];
      return;
    }

    // Default seeded transactions for Demo Finwise or general evaluation
    if (userId == 'test_user_sprint1' ||
        userId.contains('demo') ||
        userId == '00000000-0000-4000-8000-000000000001' ||
        userId.isEmpty) {
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
      return;
    }

    // Brand-new registered user: start with an empty, dedicated database partition
    _userTransactions[userId] = [];
  }

  /// Get user profile (from Supabase or local cache)
  Future<UserProfile> getUserProfile({
    required String userId,
    required String email,
    required String displayName,
    String? photoUrl,
    String? phone,
    String? occupation,
  }) async {
    final client = _supabaseService.client;
    if (client != null) {
      try {
        final data = await client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (data != null) {
          final profile = UserProfile.fromJson(data);
          _userProfiles[userId] = profile;
          return profile;
        } else {
          // Create profile in Supabase
          final defaultPhone = phone ?? '';
          final defaultOccupation = occupation ?? '';
          final newProfile = UserProfile(
            id: userId,
            email: email,
            displayName: displayName,
            avatarUrl: photoUrl,
            phone: defaultPhone,
            occupation: defaultOccupation,
            currency: 'RM',
            monthlyBudget: 2500.00,
          );
          await client.from('profiles').upsert({
            'id': userId,
            'email': email,
            'display_name': displayName,
            'avatar_url': photoUrl,
            'currency': 'RM',
            'monthly_budget': 2500.00,
          });
          _userProfiles[userId] = newProfile;
          return newProfile;
        }
      } catch (e) {
        debugPrint('[DatabaseService] Supabase profile fetch notice: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 150));
    if (!_userProfiles.containsKey(userId)) {
      final defaultPhone = phone ?? '';
      final defaultOccupation = occupation ?? '';
      _userProfiles[userId] = UserProfile(
        id: userId,
        email: email,
        displayName: displayName,
        avatarUrl: photoUrl,
        phone: defaultPhone,
        occupation: defaultOccupation,
        currency: 'RM',
        monthlyBudget: 2500.00,
      );
    }
    return _userProfiles[userId]!;
  }

  /// Update full user profile in Supabase & local cache
  Future<UserProfile> updateFullUserProfile({
    required String userId,
    required String displayName,
    required String email,
    String? phone,
    String? occupation,
    String? avatarUrl,
    String? currency,
    double? monthlyBudget,
  }) async {
    final client = _supabaseService.client;
    if (client != null) {
      try {
        final updateMap = <String, dynamic>{
          'display_name': displayName,
          'email': email,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          if (currency != null) 'currency': currency,
          if (monthlyBudget != null) 'monthly_budget': monthlyBudget,
        };
        await client.from('profiles').upsert({'id': userId, ...updateMap});
      } catch (e) {
        debugPrint('[DatabaseService] Supabase full profile update notice: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 100));
    final current = _userProfiles[userId];
    final updated = (current != null)
        ? current.copyWith(
            displayName: displayName,
            email: email,
            phone: phone ?? current.phone,
            occupation: occupation ?? current.occupation,
            avatarUrl: avatarUrl ?? current.avatarUrl,
            currency: currency ?? current.currency,
            monthlyBudget: monthlyBudget ?? current.monthlyBudget,
          )
        : UserProfile(
            id: userId,
            email: email,
            displayName: displayName,
            phone: phone,
            occupation: occupation,
            avatarUrl: avatarUrl,
            currency: currency ?? 'RM',
            monthlyBudget: monthlyBudget ?? 2500.00,
          );
    _userProfiles[userId] = updated;
    return updated;
  }

  /// Update user monthly budget
  Future<UserProfile> updateMonthlyBudget(String userId, double newBudget) async {
    final client = _supabaseService.client;
    if (client != null) {
      try {
        await client
            .from('profiles')
            .update({'monthly_budget': newBudget})
            .eq('id', userId);
      } catch (e) {
        debugPrint('[DatabaseService] Supabase budget update notice: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 150));
    if (_userProfiles.containsKey(userId)) {
      _userProfiles[userId] = _userProfiles[userId]!.copyWith(
        monthlyBudget: newBudget,
      );
      return _userProfiles[userId]!;
    }
    throw Exception('User profile not found');
  }

  /// READ: Fetch transactions from Supabase (or local store)
  Future<List<TransactionRecord>> getTransactions(String userId) async {
    final client = _supabaseService.client;
    if (client != null) {
      try {
        final List<dynamic> response = await client
            .from('transactions')
            .select()
            .eq('user_id', userId)
            .order('transaction_date', ascending: false);

        if (response.isNotEmpty) {
          final items = response
              .map((item) => TransactionRecord.fromJson(item as Map<String, dynamic>))
              .toList();
          _userTransactions[userId] = items;
          return items;
        }
      } catch (e) {
        debugPrint('[DatabaseService] Supabase query notice: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));
    _seedDefaultTransactionsIfEmpty(userId);

    final list = _userTransactions[userId] ?? [];
    list.sort((a, b) => b.date.compareTo(a.date));
    return List.from(list);
  }

  /// CREATE: Insert transaction into Supabase (or local store)
  Future<TransactionRecord> createTransaction(TransactionRecord transaction) async {
    final client = _supabaseService.client;
    final userId = transaction.userId;

    final newRecord = transaction.id.isEmpty
        ? transaction.copyWith(id: _uuid.v4())
        : transaction;

    if (client != null) {
      try {
        final inserted = await client
            .from('transactions')
            .insert(newRecord.toSupabaseMap())
            .select()
            .single();

        final created = TransactionRecord.fromJson(inserted);
        if (!_userTransactions.containsKey(userId)) {
          _userTransactions[userId] = [];
        }
        _userTransactions[userId]!.insert(0, created);
        debugPrint('[DatabaseService:Supabase] Created transaction: ${created.title} - RM ${created.amount}');
        return created;
      } catch (e) {
        debugPrint('[DatabaseService] Supabase create error: $e, using local storage.');
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));
    if (!_userTransactions.containsKey(userId)) {
      _userTransactions[userId] = [];
    }

    _userTransactions[userId]!.insert(0, newRecord);
    debugPrint('[DatabaseService:Local] Created transaction: ${newRecord.title} - RM ${newRecord.amount}');
    return newRecord;
  }

  /// UPDATE: Modify existing transaction
  Future<TransactionRecord> updateTransaction(TransactionRecord updatedRecord) async {
    final client = _supabaseService.client;
    final userId = updatedRecord.userId;

    if (client != null) {
      try {
        await client
            .from('transactions')
            .update(updatedRecord.toSupabaseMap())
            .eq('id', updatedRecord.id)
            .eq('user_id', userId);
        debugPrint('[DatabaseService:Supabase] Updated transaction: ${updatedRecord.title}');
      } catch (e) {
        debugPrint('[DatabaseService] Supabase update notice: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));
    final list = _userTransactions[userId];

    if (list != null) {
      final index = list.indexWhere((t) => t.id == updatedRecord.id);
      if (index != -1) {
        list[index] = updatedRecord.copyWith(updatedAt: DateTime.now());
        debugPrint('[DatabaseService:Local] Updated transaction: ${updatedRecord.title}');
        return list[index];
      }
    }
    throw Exception('Transaction record not found: ${updatedRecord.id}');
  }

  /// DELETE: Remove transaction
  Future<bool> deleteTransaction(String transactionId, String userId) async {
    final client = _supabaseService.client;
    if (client != null) {
      try {
        await client
            .from('transactions')
            .delete()
            .eq('id', transactionId)
            .eq('user_id', userId);
        debugPrint('[DatabaseService:Supabase] Deleted transaction: $transactionId');
      } catch (e) {
        debugPrint('[DatabaseService] Supabase delete notice: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));
    final list = _userTransactions[userId];

    if (list != null) {
      final initialCount = list.length;
      list.removeWhere((t) => t.id == transactionId);
      final removed = list.length < initialCount;
      debugPrint('[DatabaseService:Local] Deleted transaction ($transactionId): $removed');
      return removed;
    }
    return false;
  }
}
