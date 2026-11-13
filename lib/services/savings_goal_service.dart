// ============================================================
// FinWise: SavingsGoalService
// Supabase CRUD for the savings_goals table.
// All derived fields (remaining_amount, completion_percentage,
// status) are computed in the model — not stored here.
// ============================================================

import 'package:flutter/foundation.dart';
import '../models/savings_goal.dart';
import 'supabase_service.dart';

class SavingsGoalService {
  static final SavingsGoalService _instance = SavingsGoalService._internal();
  factory SavingsGoalService() => _instance;
  SavingsGoalService._internal();

  final SupabaseService _supabaseService = SupabaseService();

  static const String _table = 'savings_goals';

  // ---- Validation ----------------------------------------------------------

  /// Throws [ArgumentError] on invalid inputs before any DB call.
  void _validate({
    required String goalName,
    required double targetAmount,
    required DateTime targetDate,
    double? currentSavedAmount,
    bool isCreate = true,
  }) {
    if (goalName.trim().isEmpty) {
      throw ArgumentError('Goal name cannot be empty.');
    }
    if (goalName.trim().length > 150) {
      throw ArgumentError('Goal name must be 150 characters or fewer.');
    }
    if (targetAmount <= 0 || targetAmount.isNaN || targetAmount.isInfinite) {
      throw ArgumentError('Target amount must be a positive number.');
    }
    if (currentSavedAmount != null &&
        (currentSavedAmount < 0 ||
            currentSavedAmount.isNaN ||
            currentSavedAmount.isInfinite)) {
      throw ArgumentError('Saved amount cannot be negative.');
    }
    if (isCreate) {
      // New goals must have a future target date
      final today = DateTime.now();
      final todayDateOnly = DateTime(today.year, today.month, today.day);
      if (!targetDate.isAfter(todayDateOnly)) {
        throw ArgumentError('Target date must be a future date.');
      }
    }
  }

  // ---- READ ----------------------------------------------------------------

  /// Fetch all savings goals for [userId], ordered by target_date ascending.
  Future<List<SavingsGoal>> getSavingsGoals(String userId) async {
    final client = _supabaseService.client;
    if (client == null) {
      debugPrint('[SavingsGoalService] Supabase not initialised – returning empty list.');
      return [];
    }

    try {
      final List<dynamic> response = await client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('target_date', ascending: true)
          .timeout(const Duration(seconds: 10));

      return response
          .map((row) => SavingsGoal.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[SavingsGoalService] getSavingsGoals error: $e');
      rethrow;
    }
  }

  // ---- CREATE --------------------------------------------------------------

  /// Create a new savings goal. Validates inputs; rejects past target dates.
  Future<SavingsGoal> createSavingsGoal({
    required String userId,
    required String goalName,
    required double targetAmount,
    required DateTime targetDate,
    double currentSavedAmount = 0.0,
  }) async {
    _validate(
      goalName: goalName,
      targetAmount: targetAmount,
      targetDate: targetDate,
      currentSavedAmount: currentSavedAmount,
      isCreate: true,
    );

    final client = _supabaseService.client;
    if (client == null) throw StateError('Supabase client not initialised.');

    try {
      final payload = <String, dynamic>{
        'user_id': userId,
        'goal_name': goalName.trim(),
        'target_amount': targetAmount,
        'current_saved_amount': currentSavedAmount,
        'target_date': targetDate.toIso8601String().split('T').first,
      };

      final Map<String, dynamic> inserted = await client
          .from(_table)
          .insert(payload)
          .select()
          .single()
          .timeout(const Duration(seconds: 10));

      debugPrint('[SavingsGoalService] Created goal: ${inserted['goal_name']}');
      return SavingsGoal.fromJson(inserted);
    } catch (e) {
      debugPrint('[SavingsGoalService] createSavingsGoal error: $e');
      rethrow;
    }
  }

  // ---- UPDATE (full) -------------------------------------------------------

  /// Update goal metadata (name, target amount, target date).
  Future<SavingsGoal> updateSavingsGoal({
    required String goalId,
    required String userId,
    required String goalName,
    required double targetAmount,
    required DateTime targetDate,
  }) async {
    _validate(
      goalName: goalName,
      targetAmount: targetAmount,
      targetDate: targetDate,
      isCreate: false, // Allow past dates when editing an existing goal
    );

    final client = _supabaseService.client;
    if (client == null) throw StateError('Supabase client not initialised.');

    try {
      final Map<String, dynamic> updated = await client
          .from(_table)
          .update({
            'goal_name': goalName.trim(),
            'target_amount': targetAmount,
            'target_date': targetDate.toIso8601String().split('T').first,
          })
          .eq('id', goalId)
          .eq('user_id', userId) // RLS double-check
          .select()
          .single()
          .timeout(const Duration(seconds: 10));

      debugPrint('[SavingsGoalService] Updated goal: $goalId');
      return SavingsGoal.fromJson(updated);
    } catch (e) {
      debugPrint('[SavingsGoalService] updateSavingsGoal error: $e');
      rethrow;
    }
  }

  // ---- DEPOSIT (partial update) --------------------------------------------

  /// Add [depositAmount] to the goal's current_saved_amount.
  /// currentSavedAmount is kept isolated; it is NOT auto-bound to bank balance.
  Future<SavingsGoal> depositToGoal({
    required String goalId,
    required String userId,
    required double currentSavedAmount,
    required double depositAmount,
  }) async {
    if (depositAmount <= 0 || depositAmount.isNaN || depositAmount.isInfinite) {
      throw ArgumentError('Deposit amount must be a positive number.');
    }

    final newSavedAmount = currentSavedAmount + depositAmount;

    final client = _supabaseService.client;
    if (client == null) throw StateError('Supabase client not initialised.');

    try {
      final Map<String, dynamic> updated = await client
          .from(_table)
          .update({'current_saved_amount': newSavedAmount})
          .eq('id', goalId)
          .eq('user_id', userId)
          .select()
          .single()
          .timeout(const Duration(seconds: 10));

      debugPrint('[SavingsGoalService] Deposited RM $depositAmount → goal $goalId');
      return SavingsGoal.fromJson(updated);
    } catch (e) {
      debugPrint('[SavingsGoalService] depositToGoal error: $e');
      rethrow;
    }
  }

  // ---- DELETE --------------------------------------------------------------

  /// Permanently delete a savings goal by [goalId].
  Future<void> deleteSavingsGoal({
    required String goalId,
    required String userId,
  }) async {
    final client = _supabaseService.client;
    if (client == null) throw StateError('Supabase client not initialised.');

    try {
      await client
          .from(_table)
          .delete()
          .eq('id', goalId)
          .eq('user_id', userId)
          .timeout(const Duration(seconds: 10));

      debugPrint('[SavingsGoalService] Deleted goal: $goalId');
    } catch (e) {
      debugPrint('[SavingsGoalService] deleteSavingsGoal error: $e');
      rethrow;
    }
  }
}
