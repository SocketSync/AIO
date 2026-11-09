import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  int _selectedTab = 0; // 0: Monthly Budget, 1: Savings Goals

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
                    // Savings Goals
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
                          child: const Text('3 Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    _buildSavingsGoalCard(
                      title: 'New MacBook Pro (M3)',
                      targetDate: 'Target: Dec 2024',
                      saved: 'RM 2,850',
                      goal: 'RM 4,500',
                      percent: 0.63,
                      icon: Icons.laptop_mac,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 10),

                    _buildSavingsGoalCard(
                      title: 'Semester Break Trip',
                      targetDate: 'Target: Jan 2025',
                      saved: 'RM 600',
                      goal: 'RM 800',
                      percent: 0.75,
                      icon: Icons.flight_takeoff,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: 10),

                    _buildSavingsGoalCard(
                      title: 'Emergency Buffer',
                      targetDate: 'Safety Reserve',
                      saved: 'RM 1,200',
                      goal: 'RM 1,500',
                      percent: 0.80,
                      icon: Icons.shield,
                      color: const Color(0xFF673AB7),
                    ),
                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {},
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderNeutral),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                      Text(targetDate, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
              Text(
                '${(percent * 100).toInt()}%',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Saved: $saved', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
              Text('Goal: $goal', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
