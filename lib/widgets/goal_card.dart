// ============================================================
// FinWise: GoalCard Widget
// Modular, stateless card for a single SavingsGoal.
// Handles: In Progress, Completed (green), Overdue (red),
//          Zero Progress (0 %), and Overfunded (saved > target).
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/savings_goal.dart';
import '../theme/app_theme.dart';

class GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback? onDeposit;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    this.onDeposit,
    this.onEdit,
    this.onDelete,
  });

  // ---- Color & Label helpers -----------------------------------------------

  Color get _accentColor {
    switch (goal.status) {
      case GoalStatus.completed:
        return AppColors.secondary; // green
      case GoalStatus.overdue:
        return AppColors.alertCoral; // red
      case GoalStatus.inProgress:
        return AppColors.primary; // navy
    }
  }

  Color get _borderColor {
    switch (goal.status) {
      case GoalStatus.completed:
        return AppColors.secondary.withValues(alpha: 0.4);
      case GoalStatus.overdue:
        return AppColors.alertCoral.withValues(alpha: 0.5);
      case GoalStatus.inProgress:
        return AppColors.borderNeutral;
    }
  }

  Color get _bgColor {
    switch (goal.status) {
      case GoalStatus.completed:
        return AppColors.growthMintSubtle;
      case GoalStatus.overdue:
        return AppColors.alertCoralSubtle;
      case GoalStatus.inProgress:
        return AppColors.surfaceContainerLowest;
    }
  }

  Widget _buildStatusBadge() {
    switch (goal.status) {
      case GoalStatus.completed:
        return _Badge(
          label: '✓ Completed',
          textColor: AppColors.secondary,
          bgColor: AppColors.growthMintSubtle,
        );
      case GoalStatus.overdue:
        return _Badge(
          label: '⚠ Overdue',
          textColor: AppColors.alertCoral,
          bgColor: AppColors.alertCoralSubtle,
        );
      case GoalStatus.inProgress:
        return _Badge(
          label: '${goal.completionPercentage.toStringAsFixed(0)}%',
          textColor: AppColors.primary,
          bgColor: AppColors.primary.withValues(alpha: 0.08),
        );
    }
  }

  // ---- Build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);
    final dateFmt = DateFormat('d MMM yyyy');

    final isOverfunded = goal.currentSavedAmount > goal.targetAmount;

    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Row 1: Icon + Name + Status badge + Menu ------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Goal icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    goal.isCompleted
                        ? Icons.check_circle_rounded
                        : goal.isOverdue
                            ? Icons.warning_rounded
                            : Icons.savings_rounded,
                    color: _accentColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),

                // Name + Target date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.goalName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Target: ${dateFmt.format(goal.targetDate)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: goal.isOverdue
                              ? AppColors.alertCoral
                              : AppColors.textMuted,
                          fontWeight: goal.isOverdue
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                _buildStatusBadge(),

                // Context menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      size: 20, color: AppColors.textMuted),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onSelected: (val) {
                    if (val == 'deposit') onDeposit?.call();
                    if (val == 'edit') onEdit?.call();
                    if (val == 'delete') onDelete?.call();
                  },
                  itemBuilder: (_) => [
                    if (!goal.isCompleted)
                      const PopupMenuItem(
                        value: 'deposit',
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline,
                                size: 18, color: AppColors.secondary),
                            SizedBox(width: 8),
                            Text('Add Deposit',
                                style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 18, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 18, color: AppColors.alertCoral),
                          SizedBox(width: 8),
                          Text('Delete',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.alertCoral)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ---- Progress Bar -----------------------------------------------
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                // clamp to 1.0 to avoid assertion errors for overfunded goals
                value: goal.progressFraction.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor:
                    _accentColor.withValues(alpha: 0.12),
                valueColor:
                    AlwaysStoppedAnimation<Color>(_accentColor),
              ),
            ),
            const SizedBox(height: 10),

            // ---- Row 2: Amounts ---------------------------------------------
            Row(
              children: [
                // Saved
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SAVED',
                        style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 0.6,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currencyFmt.format(goal.currentSavedAmount),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _accentColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Target
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'TARGET',
                        style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 0.6,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currencyFmt.format(goal.targetAmount),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                // Remaining / Overfunded
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isOverfunded ? 'OVERFUNDED' : 'REMAINING',
                        style: const TextStyle(
                            fontSize: 9,
                            letterSpacing: 0.6,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isOverfunded
                            ? '+${currencyFmt.format(goal.currentSavedAmount - goal.targetAmount)}'
                            : currencyFmt.format(goal.remainingAmount),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isOverfunded
                              ? AppColors.secondary
                              : goal.isOverdue
                                  ? AppColors.alertCoral
                                  : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ---- Completed checkmark / Overdue banner ----------------------
            if (goal.isCompleted) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle,
                        size: 14, color: AppColors.secondary),
                    SizedBox(width: 6),
                    Text(
                      'Goal achieved! 🎉',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (goal.isOverdue) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.alertCoralSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 14, color: AppColors.alertCoral),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Past target date – consider updating your goal.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.alertCoral,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---- Private badge helper --------------------------------------------------
class _Badge extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color bgColor;

  const _Badge({
    required this.label,
    required this.textColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
