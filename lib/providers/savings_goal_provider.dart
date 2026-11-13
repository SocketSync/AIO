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

  // ---- Getters -------------------------------------------------------------

  List<SavingsGoal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<SavingsGoal> get completedGoals =>
      _goals.where((g) => g.isCompleted).toList();

  List<SavingsGoal> get overdueGoals =>
      _goals.where((g) => g.isOverdue).toList();

  List<SavingsGoal> get activeGoals =>
      _goals.where((g) => !g.isCompleted).toList();

  int get totalGoals => _goals.length;

  // ---- FETCH ---------------------------------------------------------------

  Future<void> fetchGoals(String userId) async {
    _currentUserId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _goals = await _service.getSavingsGoals(userId);
    } catch (e) {
      _errorMessage = 'Failed to load savings goals. Please try again.';
      debugPrint('[SavingsGoalProvider] fetchGoals error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
}
