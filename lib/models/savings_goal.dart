// ============================================================
// FinWise: SavingsGoal Model
// Derived fields (remaining_amount, completion_percentage,
// status) are computed on the client — never stored in DB.
// ============================================================

enum GoalStatus { inProgress, completed, overdue }

class SavingsGoal {
  final String id;
  final String userId;
  final String goalName;
  final double targetAmount;
  final double currentSavedAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingsGoal({
    required this.id,
    required this.userId,
    required this.goalName,
    required this.targetAmount,
    required this.currentSavedAmount,
    required this.targetDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // ---- Derived / Computed Fields ------------------------------------------------

  /// Amount still needed to reach the target. Floored at 0 for overfunded goals.
  double get remainingAmount => (targetAmount - currentSavedAmount).clamp(0, double.infinity);

  /// Completion percentage, capped at 100 for overfunded goals.
  double get completionPercentage {
    if (targetAmount <= 0) return 0;
    return ((currentSavedAmount / targetAmount) * 100).clamp(0, 100);
  }

  /// Fractional progress (0.0 – 1.0) for use in LinearProgressIndicator.
  double get progressFraction => completionPercentage / 100;

  /// Derived status – never persisted.
  GoalStatus get status {
    if (currentSavedAmount >= targetAmount) return GoalStatus.completed;
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    if (todayDateOnly.isAfter(targetDate)) return GoalStatus.overdue;
    return GoalStatus.inProgress;
  }

  bool get isCompleted => status == GoalStatus.completed;
  bool get isOverdue => status == GoalStatus.overdue;

  // ---- Serialization -------------------------------------------------------

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      goalName: (json['goal_name'] ?? '').toString(),
      targetAmount: (json['target_amount'] as num?)?.toDouble() ?? 0.0,
      currentSavedAmount: (json['current_saved_amount'] as num?)?.toDouble() ?? 0.0,
      targetDate: json['target_date'] != null
          ? DateTime.parse(json['target_date'] as String)
          : DateTime.now().add(const Duration(days: 30)),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'goal_name': goalName,
      'target_amount': targetAmount,
      'current_saved_amount': currentSavedAmount,
      'target_date': targetDate.toIso8601String().split('T').first, // date only
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// For Supabase INSERT/UPDATE – omits id/timestamps so the DB handles them.
  Map<String, dynamic> toSupabaseMap({bool includeId = false}) {
    final map = <String, dynamic>{
      'user_id': userId,
      'goal_name': goalName,
      'target_amount': targetAmount,
      'current_saved_amount': currentSavedAmount,
      'target_date': targetDate.toIso8601String().split('T').first,
    };
    if (includeId && id.isNotEmpty) map['id'] = id;
    return map;
  }

  SavingsGoal copyWith({
    String? id,
    String? userId,
    String? goalName,
    double? targetAmount,
    double? currentSavedAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalName: goalName ?? this.goalName,
      targetAmount: targetAmount ?? this.targetAmount,
      currentSavedAmount: currentSavedAmount ?? this.currentSavedAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() =>
      'SavingsGoal(id: $id, goal: $goalName, saved: $currentSavedAmount/$targetAmount, status: $status)';
}
