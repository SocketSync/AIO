import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/savings_goal.dart';
import '../providers/savings_goal_provider.dart';
import '../services/auth_service.dart';
import '../widgets/goal_card.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  int _selectedTab = 0; // 0: Monthly Budget, 1: Savings Goals
  bool _goalsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_goalsLoaded) {
      _goalsLoaded = true;
      final authService = context.read<AuthService>();
      final userId = authService.currentUser?.id ?? '';
      if (userId.isNotEmpty) {
        context.read<SavingsGoalProvider>().fetchGoals(userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'FinWise',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.textMuted),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: const Text('AY', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Month Selector & Status Alert
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderNeutral),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.calendar_month, color: AppColors.primary, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'November 2024',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.alertCoralSubtle,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning, color: AppColors.alertCoral, size: 13),
                            SizedBox(width: 4),
                            Text(
                              '1 Category Tight',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.alertCoral),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 2. Segment Switcher (Budgets vs Goals)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedTab == 0 ? AppColors.surfaceContainerLowest : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: _selectedTab == 0
                                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                    : null,
                              ),
                              child: Text(
                                'Monthly Budget',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedTab == 0 ? AppColors.primary : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1 ? AppColors.surfaceContainerLowest : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: _selectedTab == 1
                                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                    : null,
                              ),
                              child: Text(
                                'Savings Goals (3)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedTab == 1 ? AppColors.primary : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Monthly Budget Hero Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('OVERVIEW', style: TextStyle(fontSize: 10, letterSpacing: 1, color: AppColors.primaryFixedDim, fontWeight: FontWeight.bold)),
                                Text('Monthly Spending', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('74% Used', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Gauge & Figures Row
                        Row(
                          children: [
                            // Circular Indicator
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 84,
                                  height: 84,
                                  child: CircularProgressIndicator(
                                    value: 0.74,
                                    strokeWidth: 8,
                                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondaryContainer),
                                  ),
                                ),
                                const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('74%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                    Text('spent', style: TextStyle(fontSize: 9, color: AppColors.primaryFixedDim)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),

                            // Numbers
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Spent / Target', style: TextStyle(fontSize: 11, color: AppColors.primaryFixedDim)),
                                  const SizedBox(height: 2),
                                  const Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        'RM 1,485',
                                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Text(
                                        ' / RM 2,000',
                                        style: TextStyle(fontSize: 13, color: AppColors.primaryFixedDim),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.growthMintSubtle.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.savings, size: 12, color: AppColors.secondaryFixed),
                                        SizedBox(width: 4),
                                        Text(
                                          'RM 515 remaining',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryFixed),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Daily Safe Limit Sub-Banner
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.verified_user, size: 16, color: AppColors.secondaryFixed),
                                  SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('DAILY SAFE LIMIT', style: TextStyle(fontSize: 9, color: AppColors.primaryFixedDim, letterSpacing: 0.5)),
                                      Text('RM 32.18 / day', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ],
                                  ),
                                ],
                              ),
                              Text('16 days left', style: TextStyle(fontSize: 11, color: Colors.white70)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 4. Content Switcher (Budgets list vs Goals list)
                  if (_selectedTab == 0) ...[
                    // Category Budgets Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Category Budgets',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.tune, size: 14, color: AppColors.primary),
                          label: const Text('Adjust', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    _buildCategoryBudgetCard(
                      title: 'Food & Dining',
                      subtitle: 'RM 20 safe buffer left',
                      icon: Icons.restaurant,
                      spent: 'RM 480',
                      limit: 'RM 500 limit',
                      percent: 0.96,
                      color: AppColors.alertCoral,
                      isAlert: true,
                    ),
                    const SizedBox(height: 10),

                    _buildCategoryBudgetCard(
                      title: 'Transport & Commute',
                      subtitle: 'Transit & ride hailing',
                      icon: Icons.directions_bus,
                      spent: 'RM 110',
                      limit: 'RM 200 limit',
                      percent: 0.55,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: 10),

                    _buildCategoryBudgetCard(
                      title: 'Campus & Education',
                      subtitle: 'Books, tools & course fees',
                      icon: Icons.school,
                      spent: 'RM 180',
                      limit: 'RM 300 limit',
                      percent: 0.60,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 10),

                    _buildCategoryBudgetCard(
                      title: 'Entertainment & Leisure',
                      subtitle: 'Cinema, gaming & outings',
                      icon: Icons.sports_esports,
                      spent: 'RM 210',
                      limit: 'RM 250 limit',
                      percent: 0.84,
                      color: const Color(0xFFE65100),
                    ),
                  ] else ...[
                    // ---- Live Savings Goals Tab ----------------------------
                    Consumer<SavingsGoalProvider>(
                      builder: (context, provider, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Savings Goals',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.growthMintSubtle,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${provider.activeGoals.length} Active',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Loading state
                            if (provider.isLoading) ...[
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                ),
                              ),
                            ]

                            // Error state
                            else if (provider.errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.alertCoralSubtle,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: AppColors.alertCoral, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        provider.errorMessage!,
                                        style: const TextStyle(fontSize: 12, color: AppColors.alertCoral),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]

                            // Empty state
                            else if (provider.goals.isEmpty) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.borderNeutral),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.savings_rounded, size: 48, color: AppColors.primary.withValues(alpha: 0.3)),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'No savings goals yet',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Tap "+ Add New Goal" to get started.',
                                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ]

                            // Goal list
                            else ...[
                              ...provider.goals.map((goal) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GoalCard(
                                  goal: goal,
                                  onDeposit: () => _showDepositDialog(context, goal, provider),
                                  onEdit: () => _showEditGoalDialog(context, goal, provider),
                                  onDelete: () => _showDeleteConfirmDialog(context, goal, provider),
                                ),
                              )),
                            ],

                            const SizedBox(height: 14),
                            // Add goal button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: () => _showAddGoalDialog(context, provider),
                                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 18),
                                label: const Text('+ Add New Goal', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.borderNeutral),
                                  backgroundColor: AppColors.surfaceContainerLowest,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 5. Contextual Proactive Recommendation
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.growthMintSubtle,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.auto_awesome, size: 16, color: AppColors.secondary),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('FinWise Smart Tip', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                              SizedBox(height: 2),
                              Text(
                                'Redirecting RM 15/week from Entertainment keeps your Food budget safe for the next 16 days.',
                                style: TextStyle(fontSize: 12, color: AppColors.onSurface, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80), // Padding for bottom nav
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBudgetCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String spent,
    required String limit,
    required double percent,
    required Color color,
    bool isAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isAlert ? AppColors.alertCoral : AppColors.borderNeutral),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                      Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAlert ? AppColors.alertCoralSubtle : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${(percent * 100).toInt()}% Used',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isAlert ? AppColors.alertCoral : color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(spent, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isAlert ? AppColors.alertCoral : AppColors.onSurface)),
              Text(limit, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsGoalCard({
    required String title,
    required String targetDate,
    required String saved,
    required String goal,
    required double percent,
    required IconData icon,
    required Color color,
  }) {
    // Kept for potential reuse; not called after live data migration.
    return const SizedBox.shrink();
  }

  // =========================================================================
  // CRUD Dialog Helpers
  // =========================================================================

  void _showAddGoalDialog(BuildContext context, SavingsGoalProvider provider) {
    _showGoalFormDialog(
      context: context,
      title: 'New Savings Goal',
      onSubmit: (name, targetAmount, targetDate, initialSaved) async {
        final error = await provider.addGoal(
          goalName: name,
          targetAmount: targetAmount,
          targetDate: targetDate,
          currentSavedAmount: initialSaved,
        );
        return error;
      },
    );
  }

  void _showEditGoalDialog(BuildContext context, SavingsGoal goal, SavingsGoalProvider provider) {
    _showGoalFormDialog(
      context: context,
      title: 'Edit Goal',
      initialName: goal.goalName,
      initialTarget: goal.targetAmount,
      initialDate: goal.targetDate,
      showInitialSaved: false,
      onSubmit: (name, targetAmount, targetDate, _) async {
        final error = await provider.updateGoal(
          goalId: goal.id,
          goalName: name,
          targetAmount: targetAmount,
          targetDate: targetDate,
        );
        return error;
      },
    );
  }

  /// Generic reusable form dialog for Add / Edit.
  void _showGoalFormDialog({
    required BuildContext context,
    required String title,
    required Future<String?> Function(String, double, DateTime, double) onSubmit,
    String? initialName,
    double? initialTarget,
    DateTime? initialDate,
    bool showInitialSaved = true,
  }) {
    final nameCtrl = TextEditingController(text: initialName ?? '');
    final targetCtrl = TextEditingController(text: initialTarget != null ? initialTarget.toStringAsFixed(2) : '');
    final savedCtrl = TextEditingController(text: '0.00');
    DateTime selectedDate = initialDate ?? DateTime.now().add(const Duration(days: 30));
    String? errorMsg;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (errorMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: AppColors.alertCoralSubtle, borderRadius: BorderRadius.circular(8)),
                      child: Text(errorMsg!, style: const TextStyle(fontSize: 12, color: AppColors.alertCoral)),
                    ),
                  ],
                  _DialogField(controller: nameCtrl, label: 'Goal Name', hint: 'e.g. Emergency Fund'),
                  const SizedBox(height: 12),
                  _DialogField(controller: targetCtrl, label: 'Target Amount (RM)', hint: '5000.00', keyboardType: TextInputType.numberWithOptions(decimal: true)),
                  const SizedBox(height: 12),
                  if (showInitialSaved) ...[
                    _DialogField(controller: savedCtrl, label: 'Already Saved (RM)', hint: '0.00', keyboardType: TextInputType.numberWithOptions(decimal: true)),
                    const SizedBox(height: 12),
                  ],
                  const Text('Target Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                      );
                      if (picked != null) setDialogState(() => selectedDate = picked);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderNeutral),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('d MMM yyyy').format(selectedDate),
                            style: const TextStyle(fontSize: 13, color: AppColors.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final targetAmount = double.tryParse(targetCtrl.text.replaceAll(',', '')) ?? -1;
                  final savedAmount = double.tryParse(savedCtrl.text.replaceAll(',', '')) ?? 0.0;

                  final err = await onSubmit(name, targetAmount, selectedDate, savedAmount);
                  if (err == null) {
                    if (ctx.mounted) Navigator.pop(ctx);
                  } else {
                    setDialogState(() => errorMsg = err);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDepositDialog(BuildContext context, SavingsGoal goal, SavingsGoalProvider provider) {
    final amountCtrl = TextEditingController();
    String? errorMsg;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text('Add Deposit', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Goal: ${goal.goalName}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 12),
                if (errorMsg != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(color: AppColors.alertCoralSubtle, borderRadius: BorderRadius.circular(8)),
                    child: Text(errorMsg!, style: const TextStyle(fontSize: 12, color: AppColors.alertCoral)),
                  ),
                ],
                _DialogField(
                  controller: amountCtrl,
                  label: 'Deposit Amount (RM)',
                  hint: '100.00',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
                onPressed: () async {
                  final amount = double.tryParse(amountCtrl.text.replaceAll(',', '')) ?? -1;
                  final err = await provider.depositToGoal(goalId: goal.id, depositAmount: amount);
                  if (err == null) {
                    if (ctx.mounted) Navigator.pop(ctx);
                  } else {
                    setDialogState(() => errorMsg = err);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, SavingsGoal goal, SavingsGoalProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.alertCoral)),
        content: Text('Are you sure you want to delete "${goal.goalName}"? This cannot be undone.', style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertCoral, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteGoal(goal.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Private dialog text field helper
// ============================================================
class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;

  const _DialogField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderNeutral)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderNeutral)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }
}
