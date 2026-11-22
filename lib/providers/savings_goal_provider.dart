// ============================================================
// FinWise: SavingsGoalProvider
// ChangeNotifier state manager for savings goals.
// Mirrors the pattern used by TransactionProvider.
// ============================================================

import 'package:flutter/foundation.dart';
import '../models/savings_goal.dart';
import '../services/savings_goal_service.dart';

class SavingsGoalProvider extends ChangeNotifier {
  final SavingsGoalService _service = SavingsGoalService();

  List<SavingsGoal> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentUserId = '';
  int _sessionEpoch = 0;
  bool _disposed = false;

  // ---- Getters -------------------------------------------------------------

  List<SavingsGoal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentUserId => _currentUserId;

  List<SavingsGoal> get completedGoals =>
      _goals.where((g) => g.isCompleted).toList();

  List<SavingsGoal> get overdueGoals =>
      _goals.where((g) => g.isOverdue).toList();

  List<SavingsGoal> get activeGoals =>
      _goals.where((g) => !g.isCompleted).toList();

  int get totalGoals => _goals.length;

  // ---- FETCH ---------------------------------------------------------------

  Future<void> fetchGoals(String userId) async {
    final int epoch = ++_sessionEpoch;
    _currentUserId = userId;
    _isLoading = true;
    _errorMessage = null;
    if (!_disposed) {
      notifyListeners();
    }

    try {
      final fetched = await _service.getSavingsGoals(userId);
      if (epoch != _sessionEpoch || _disposed) return;
      _goals = fetched;
    } catch (e) {
      if (epoch != _sessionEpoch || _disposed) return;
      _errorMessage = 'Failed to load savings goals. Please try again.';
      debugPrint('[SavingsGoalProvider] fetchGoals error: $e');
    } finally {
      if (epoch == _sessionEpoch && !_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // ---- CREATE --------------------------------------------------------------

  /// Returns `null` on success; returns an error message string on failure.
  Future<String?> addGoal({
    required String goalName,
    required double targetAmount,
    required DateTime targetDate,
    double currentSavedAmount = 0.0,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _service.createSavingsGoal(
        userId: _currentUserId,
        goalName: goalName,
        targetAmount: targetAmount,
        targetDate: targetDate,
        currentSavedAmount: currentSavedAmount,
      );
      _goals.add(created);
      _goals.sort((a, b) => a.targetDate.compareTo(b.targetDate));
      return null; // success
    } on ArgumentError catch (e) {
      return e.message.toString();
    } on StateError {
      return 'Savings goals require a configured Supabase backend.';
    } catch (e) {
      debugPrint('[SavingsGoalProvider] addGoal error: $e');
      return 'Failed to create goal. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- UPDATE --------------------------------------------------------------

  Future<String?> updateGoal({
    required String goalId,
    required String goalName,
    required double targetAmount,
    required DateTime targetDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _service.updateSavingsGoal(
        goalId: goalId,
        userId: _currentUserId,
        goalName: goalName,
        targetAmount: targetAmount,
        targetDate: targetDate,
      );
      final idx = _goals.indexWhere((g) => g.id == goalId);
      if (idx != -1) _goals[idx] = updated;
      _goals.sort((a, b) => a.targetDate.compareTo(b.targetDate));
      return null;
    } on ArgumentError catch (e) {
      return e.message.toString();
    } on StateError {
      return 'Savings goals require a configured Supabase backend.';
    } catch (e) {
      debugPrint('[SavingsGoalProvider] updateGoal error: $e');
      return 'Failed to update goal. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- DEPOSIT -------------------------------------------------------------

  Future<String?> depositToGoal({
    required String goalId,
    required double depositAmount,
  }) async {
    final goal = _goals.firstWhere(
      (g) => g.id == goalId,
      orElse: () => throw StateError('Goal not found: $goalId'),
    );

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _service.depositToGoal(
        goalId: goalId,
        userId: _currentUserId,
        currentSavedAmount: goal.currentSavedAmount,
        depositAmount: depositAmount,
      );
      final idx = _goals.indexWhere((g) => g.id == goalId);
      if (idx != -1) _goals[idx] = updated;
      return null;
    } on ArgumentError catch (e) {
      return e.message.toString();
    } on StateError {
      return 'Savings goals require a configured Supabase backend.';
    } catch (e) {
      debugPrint('[SavingsGoalProvider] depositToGoal error: $e');
      return 'Failed to record deposit. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- DELETE --------------------------------------------------------------

  Future<String?> deleteGoal(String goalId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteSavingsGoal(
        goalId: goalId,
        userId: _currentUserId,
      );
      _goals.removeWhere((g) => g.id == goalId);
      return null;
    } on StateError {
      return 'Savings goals require a configured Supabase backend.';
    } catch (e) {
      debugPrint('[SavingsGoalProvider] deleteGoal error: $e');
      return 'Failed to delete goal. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear cached savings goals and active user scope on sign-out.
  void clear() {
    _sessionEpoch++;
    _goals = [];
    _isLoading = false;
    _errorMessage = null;
    _currentUserId = '';
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

// AIO-111: Savings goal status filters.
