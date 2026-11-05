import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  // Simulator State
  static const double baseline6MoTotal = 3900.0;
  static const double monthlyIncome = 1500.0;
  static const int baselineSavingsPct = 15;
  static const double diningBudget = 480.0;

  double _savingsPct = 25.0;
  double _diningCutPct = 20.0;
  bool _gymActive = true;
  bool _netflixActive = false;
  double _customExpense = 0.0;
  final TextEditingController _customNameCtrl = TextEditingController();
  final TextEditingController _customValCtrl = TextEditingController();

  bool _isSavingPlan = false;

  @override
  void dispose() {
    _customNameCtrl.dispose();
    _customValCtrl.dispose();
    super.dispose();
  }

  void _resetAll() {
    setState(() {
      _savingsPct = 25.0;
      _diningCutPct = 20.0;
      _gymActive = true;
      _netflixActive = false;
      _customExpense = 0.0;
      _customNameCtrl.clear();
      _customValCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Computations
    final savingsDiffPct = _savingsPct - baselineSavingsPct;
    final savingsMonthlyGain = (savingsDiffPct / 100.0) * monthlyIncome;
    final diningMonthlySaved = (_diningCutPct / 100.0) * diningBudget;

    double recurringDeduction = 0.0;
    if (_gymActive) recurringDeduction += 89.0;
    if (_netflixActive) recurringDeduction += 29.0;
    recurringDeduction += _customExpense;

    final netMonthlyDelta = savingsMonthlyGain + diningMonthlySaved - recurringDeduction;
    final total6MoDelta = netMonthlyDelta * 6.0;
    final simulated6MoTotal = (baseline6MoTotal + total6MoDelta).clamp(1000.0, 99999.0);

    final isPositive = total6MoDelta >= 0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
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
                  // 1. Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixedDim.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.science_outlined, size: 14, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'PREDICTIVE SANDBOX',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'What-If? Scenario Simulator',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Adjust variables to visualize how daily habits impact your future cash flow and student savings.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                  ),
                  const SizedBox(height: 16),

                  // 2. Live Simulation Impact Card
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
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.auto_graph, color: AppColors.secondaryFixed, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  '6-Month Savings Outlook',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryFixedDim),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isPositive ? AppColors.growthMintSubtle : AppColors.alertCoralSubtle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                                    size: 12,
                                    color: isPositive ? AppColors.secondary : AppColors.alertCoral,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${isPositive ? '+' : '-'}RM ${total6MoDelta.abs().toInt()}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isPositive ? AppColors.secondary : AppColors.alertCoral,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        const Text('Projected Savings by Term End', style: TextStyle(fontSize: 11, color: AppColors.primaryFixedDim)),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'RM ${simulated6MoTotal.toInt()}',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'RM 3,900',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryFixedDim,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Comparative Visual Bars
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Current Path', style: TextStyle(fontSize: 11, color: AppColors.primaryFixedDim)),
                                Text('RM 3,900', style: TextStyle(fontSize: 11, color: AppColors.primaryFixedDim)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: 0.72,
                                minHeight: 6,
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryFixedDim),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Simulated Plan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text(
                                  'RM ${simulated6MoTotal.toInt()}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryFixed),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: (simulated6MoTotal / 5400.0).clamp(0.2, 1.0),
                                minHeight: 8,
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondaryFixed),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Goal Milestone Acceleration
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.laptop_mac, size: 20, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Text('Goal Acceleration', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryFixed)),
                                        SizedBox(width: 4),
                                        Icon(Icons.bolt, size: 13, color: AppColors.secondaryFixed),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isPositive
                                          ? 'MacBook Pro goal reached 1.3 mos sooner (Oct vs Dec)!'
                                          : 'MacBook Pro goal delayed slightly due to added expenses.',
                                      style: const TextStyle(fontSize: 11, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 3. Variable Adjustments Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Variable Adjustments',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                      ),
                      TextButton.icon(
                        onPressed: _resetAll,
                        icon: const Icon(Icons.restart_alt, size: 16, color: AppColors.primary),
                        label: const Text('Reset', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Control 1: Monthly Savings Slider
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderNeutral),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.savings, color: AppColors.primary, size: 18),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Monthly Savings Share', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                                    Text('Current default: 15%', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${_savingsPct.toInt()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                Text(
                                  '${savingsMonthlyGain >= 0 ? '+' : ''}RM ${savingsMonthlyGain.toInt()}/mo',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Slider(
                          value: _savingsPct,
                          min: 10,
                          max: 40,
                          divisions: 30,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _savingsPct = val),
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('10% (Min)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            Text('Smart Allocation', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            Text('40% (Aggressive)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Control 2: Cut Dining Out Spend Slider
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderNeutral),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.restaurant, color: AppColors.secondary, size: 18),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Cut Dining Out Spend', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                                    Text('Base: RM 480/month', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('-${_diningCutPct.toInt()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                                Text(
                                  '+RM ${diningMonthlySaved.toInt()} saved',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Slider(
                          value: _diningCutPct,
                          min: 0,
                          max: 50,
                          divisions: 10,
                          activeColor: AppColors.secondary,
                          onChanged: (val) => setState(() => _diningCutPct = val),
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0% (Status Quo)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            Text('Smart Trim', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                            Text('-50% (Max Frugal)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Control 3: Recurring Commitments
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderNeutral),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.event_repeat, color: AppColors.onSurface, size: 18),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Recurring Commitments', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                                    Text('Simulate ongoing monthly subscriptions', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: recurringDeduction > 0 ? AppColors.alertCoralSubtle : AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '-RM ${recurringDeduction.toInt()}/mo',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: recurringDeduction > 0 ? AppColors.alertCoral : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildSubscriptionToggle(
                                title: 'Gym Sub',
                                cost: 'RM 89/mo',
                                icon: Icons.fitness_center,
                                isActive: _gymActive,
                                onToggle: () => setState(() => _gymActive = !_gymActive),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildSubscriptionToggle(
                                title: 'Netflix Plan',
                                cost: 'RM 29/mo',
                                icon: Icons.tv,
                                isActive: _netflixActive,
                                onToggle: () => setState(() => _netflixActive = !_netflixActive),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() => _isSavingPlan = true);
                        await Future.delayed(const Duration(milliseconds: 700));
                        if (!mounted) return;
                        setState(() => _isSavingPlan = false);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Simulated plan successfully applied to your active budget!'),
                            backgroundColor: AppColors.secondary,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSavingPlan
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, size: 18),
                                SizedBox(width: 8),
                                Text('Apply Changes to My Budget', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
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

  Widget _buildSubscriptionToggle({
    required String title,
    required String cost,
    required IconData icon,
    required bool isActive,
    required VoidCallback onToggle,
  }) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.growthMintSubtle : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? AppColors.secondary : AppColors.borderNeutral),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: isActive ? AppColors.secondary : AppColors.textMuted),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    Text(cost, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
            Icon(
              isActive ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: isActive ? AppColors.secondary : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
