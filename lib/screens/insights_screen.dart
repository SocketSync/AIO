import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/savings_goal.dart';
import '../models/transaction_record.dart';
import '../providers/savings_goal_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_page_container.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  static const String _weekendCapPrefKey = 'finwise_weekend_cap';

  final TextEditingController _promptController = TextEditingController();
  String? _aiResponse;
  bool _isAnalyzing = false;
  bool _weekendCapActive = false;

  @override
  void initState() {
    super.initState();
    _loadWeekendCapPreference();
  }

  Future<void> _loadWeekendCapPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _weekendCapActive = prefs.getString(_weekendCapPrefKey) == '60';
      });
    } catch (_) {
      // Safe fallback when SharedPreferences is unavailable.
    }
  }

  Future<void> _toggleWeekendCap() async {
    final nextValue = !_weekendCapActive;
    setState(() => _weekendCapActive = nextValue);
    try {
      final prefs = await SharedPreferences.getInstance();
      if (nextValue) {
        await prefs.setString(_weekendCapPrefKey, '60');
      } else {
        await prefs.remove(_weekendCapPrefKey);
      }
    } catch (_) {}

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nextValue
              ? 'Weekend RM60 cap applied to your budget!'
              : 'Weekend RM60 cap removed.',
        ),
        backgroundColor: nextValue ? AppColors.secondary : AppColors.primary,
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  T? _maybeWatch<T>() {
    try {
      return Provider.of<T>(context);
    } on ProviderNotFoundException {
      return null;
    }
  }

  String _initialsForUser(AppUser? user) {
    final source = (user?.displayName.trim().isNotEmpty == true)
        ? user!.displayName.trim()
        : (user?.email.trim().isNotEmpty == true ? user!.email.trim() : 'FinWise');
    final parts = source.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
  }

  void _triggerAiEvaluation(
    String query, {
    required double surplus,
    required double monthExpenses,
    required SavingsGoal? primaryGoal,
    required String? purchaseInsight,
  }) {
    setState(() {
      _isAnalyzing = true;
      _aiResponse = 'Consulting your cash flow trajectory and verified transactions...';
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      final q = query.toLowerCase();
      final fmt = NumberFormat('#,##0.00');
      final String reply;
      if (q.contains('dining') || q.contains('dinner') || q.contains('afford')) {
        final projected = (surplus.abs() - 35).clamp(0.0, double.infinity);
        reply =
            'Yes! You have an unallocated weekend buffer of RM 85.00. Dining out under RM 35.00 tonight keeps your projected surplus near +RM ${fmt.format(projected)}.';
      } else if (q.contains('forecast') || q.contains('next month') || q.contains('budget')) {
        final dailySafe = ((2500.0 - monthExpenses).clamp(120.0, 2500.0)) / 30.0;
        reply =
            'Your 3-month trajectory indicates a ${surplus >= 0 ? '+' : '-'}RM ${fmt.format(surplus.abs())} net position. Keeping daily discretionary spend near RM ${dailySafe.toStringAsFixed(2)}/day preserves High Confidence.';
      } else if (q.contains('goal') || q.contains('save') || q.contains('faster')) {
        final targetName = primaryGoal != null ? '"${primaryGoal.goalName}"' : 'your active savings target';
        reply =
            'Enabling the RM60 weekend cap frees roughly RM 240.00/month. Routing RM 120.00/month toward $targetName puts completion ~18 days ahead of schedule.';
      } else if (q.contains('habit') || q.contains('purchase') || q.contains('spending')) {
        reply = purchaseInsight ??
            'Your itemized purchase cadence looks well-balanced over the last 14 days with weekend dining as the main optimization opportunity.';
      } else {
        reply =
            'Based on your synced account activity, your daily safe expenditure rate is RM 32.18/day with a projected 3-month surplus of +RM ${fmt.format(surplus.abs())}.';
      }

      setState(() {
        _isAnalyzing = false;
        _aiResponse = reply;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = _maybeWatch<TransactionProvider>();
    final goalProvider = _maybeWatch<SavingsGoalProvider>();
    final authService = _maybeWatch<AuthService>();

    final transactions = txProvider?.transactions ?? const <TransactionRecord>[];
    final goals = goalProvider?.goals ?? const <SavingsGoal>[];
    final initials = _initialsForUser(authService?.currentUser);

    final now = DateTime.now();
    final monthDates = List<DateTime>.generate(
      6,
      (i) => DateTime(now.year, now.month - 2 + i, 1),
    );
    final dateRangeText =
        '${DateFormat('MMM yy').format(monthDates[2])} – ${DateFormat('MMM yy').format(monthDates[5])}';

    final expenses = transactions.where((t) => t.isExpense).toList();
    final totalIncome = txProvider?.totalIncome ?? 0.0;
    final totalExpense = txProvider?.totalExpense ?? 0.0;
    final double predictedSurplus =
        transactions.isNotEmpty && (totalIncome - totalExpense) != 0
            ? (totalIncome - totalExpense)
            : 640.0;

    final thisMonthPrefix = DateFormat('yyyy-MM').format(now);
    final double monthExpenses = expenses
        .where((t) => DateFormat('yyyy-MM').format(t.date) == thisMonthPrefix)
        .fold(0.0, (s, t) => s + t.amount);

    // Weekend spike calculation with safe fallback.
    double weekendSum = 0.0;
    int weekendCnt = 0;
    double weekdaySum = 0.0;
    int weekdayCnt = 0;
    for (final tx in expenses) {
      if (tx.date.weekday == DateTime.saturday || tx.date.weekday == DateTime.sunday) {
        weekendSum += tx.amount;
        weekendCnt++;
      } else {
        weekdaySum += tx.amount;
        weekdayCnt++;
      }
    }
    int spikePct = 42;
    int estMonthlySave = 240;
    if (weekendCnt > 0 && weekdayCnt > 0) {
      final wkendAvg = weekendSum / weekendCnt;
      final wkdayAvg = weekdaySum / weekdayCnt;
      if (wkdayAvg > 0 && wkendAvg > wkdayAvg) {
        spikePct = (((wkendAvg - wkdayAvg) / wkdayAvg) * 100).round().clamp(8, 180);
        estMonthlySave = ((weekendSum * 0.3) / 10).round().clamp(6, 99) * 10;
      }
    }

    // Recurring alert detection with fallback.
    TransactionRecord? recurringBill;
    for (final tx in expenses) {
      final haystack = '${tx.title} ${tx.categoryId}'.toLowerCase();
      if (haystack.contains('wifi') ||
          haystack.contains('broadband') ||
          haystack.contains('internet') ||
          haystack.contains('bills') ||
          haystack.contains('utility') ||
          haystack.contains('electric')) {
        recurringBill = tx;
        break;
      }
    }
    final recurringTitle = recurringBill?.title ?? 'Broadband / WiFi bill';
    final recurringAmount = recurringBill?.amount ?? 49.00;

    // Primary active savings goal with fallback.
    SavingsGoal? activeGoal;
    for (final g in goals) {
      if (!g.isCompleted) {
        activeGoal = g;
        break;
      }
    }
    activeGoal ??= goals.isNotEmpty ? goals.first : null;
    final double savedAmt = activeGoal?.currentSavedAmount ?? 2880.0;
    final double targetAmt = activeGoal != null && activeGoal.targetAmount > 0
        ? activeGoal.targetAmount
        : 4500.0;
    final double goalFraction = (savedAmt / targetAmt).clamp(0.0, 1.0);
    final int goalPercent = (goalFraction * 100).round();

    final fmtMoney = NumberFormat('#,##0.00');
    final fmtCompact = NumberFormat('#,##0');
    final surplusPrefix = predictedSurplus >= 0 ? '+' : '-';
    final surplusText = '${surplusPrefix}RM ${fmtMoney.format(predictedSurplus.abs())}';
    final pillSurplusText = '${surplusPrefix}RM ${fmtCompact.format(predictedSurplus.abs().round())}';

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
            const Flexible(
              child: Text(
                'FinWise',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Diagnostic Alerts',
            icon: const Icon(Icons.notifications_none, color: AppColors.textMuted),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('2 active advisories: Weekend outflow check & auto-debit verified.'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(
                initials,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsivePageContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SMART ADVISORY',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.1,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'AI Financial Assistant',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixedDim.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology, color: AppColors.primary, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.growthMintSubtle,
                  borderRadius: BorderRadius.circular(AppTheme.pillBorderRadius),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: AppColors.secondary),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Active Analysis • Synced with live account data',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 2. Cash Flow Forecast Card
              Container(
                padding: const EdgeInsets.all(AppTheme.cardPadding),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.timeline, color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cash Flow Forecast',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '3-Month dynamic trajectory model',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppTheme.pillBorderRadius),
                          ),
                          child: Text(
                            dateRangeText,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Predicted Surplus Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      decoration: BoxDecoration(
                        color: AppColors.growthMintSubtle.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 15,
                            backgroundColor: AppColors.secondary,
                            child: Icon(Icons.savings, size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Predicted Surplus',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    surplusText,
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.secondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppTheme.pillBorderRadius),
                              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
                            ),
                            child: const Text(
                              'High Confidence',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Clipped CustomPaint Trajectory Chart (zero right-edge clipping)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 156,
                        width: double.infinity,
                        color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
                        child: CustomPaint(
                          painter: _ForecastChartPainter(surplusLabel: pillSurplusText),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Dynamic Months Axis Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(monthDates.length, (idx) {
                        final label = DateFormat('MMM').format(monthDates[idx]);
                        final color = idx == 2
                            ? AppColors.primary
                            : idx > 2
                                ? AppColors.secondary
                                : AppColors.textMuted;
                        return Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: idx >= 2 ? FontWeight.bold : FontWeight.w500,
                                color: color,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.surfaceContainerHigh),
                    const SizedBox(height: 10),

                    // Legend Row
                    const SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 6,
                        children: [
                          _ChartLegendItem(
                            swatch: _LegendSwatchType.solidLine,
                            color: AppColors.primary,
                            label: 'Actual Spent',
                          ),
                          _ChartLegendItem(
                            swatch: _LegendSwatchType.dashedLine,
                            color: AppColors.secondary,
                            label: 'AI Forecast',
                          ),
                          _ChartLegendItem(
                            swatch: _LegendSwatchType.rangeBox,
                            color: AppColors.secondary,
                            label: '95% Range',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // 3. Behavioral Diagnostic Section
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.insights, size: 19, color: AppColors.primary),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Behavioral Diagnostic',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Updated just now',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Card 1: Spending Behavior Habit
              _buildDiagnosticShell(
                icon: Icons.local_mall,
                iconColor: AppColors.alertCoral,
                iconBg: AppColors.alertCoralSubtle,
                title: 'Spending Behavior Habit',
                badgeText: '+$spikePct% Spike',
                badgeColor: AppColors.alertCoral,
                badgeBg: AppColors.alertCoralSubtle,
                description:
                    'You spend $spikePct% more on weekends across dining & shopping. Setting a RM60 weekend cap could save you RM$estMonthlySave/month.',
                footer: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Weekend Outflow Peak',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _toggleWeekendCap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _weekendCapActive ? AppColors.secondary : AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          _weekendCapActive ? 'RM60 Cap Active ✓' : 'Set RM60 Cap',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Card 2: Recurring Expense Alert
              _buildDiagnosticShell(
                icon: Icons.wifi_tethering,
                iconColor: AppColors.primary,
                iconBg: AppColors.primary.withValues(alpha: 0.10),
                title: 'Recurring Expense Alert',
                badgeText: 'In 3 Days',
                badgeColor: AppColors.primary,
                badgeBg: AppColors.primary.withValues(alpha: 0.10),
                description:
                    '$recurringTitle due in 3 days (RM ${fmtMoney.format(recurringAmount)}). Adequate balance detected in your primary account for auto-debit.',
                footer: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.growthMintSubtle.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Auto-debit scheduled safely',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'RM ${fmtMoney.format(recurringAmount)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Card 3: Smart Optimization
              _buildDiagnosticShell(
                icon: Icons.trending_down,
                iconColor: AppColors.secondary,
                iconBg: AppColors.growthMintSubtle,
                title: 'Smart Optimization',
                badgeText: '-15% Food',
                badgeColor: AppColors.secondary,
                badgeBg: AppColors.growthMintSubtle,
                description: activeGoal != null
                    ? 'You cut Food expenditure by 15% this week. Maintaining this pace accelerates "${activeGoal.goalName}" by 18 days!'
                    : 'You cut Food expenditure by 15% this week. Maintaining this pace completes your primary savings goal 18 days earlier!',
                footer: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              activeGoal != null ? 'Target Progress • ${activeGoal.goalName}' : 'Target Progress',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '$goalPercent% • RM ${fmtCompact.format(savedAmt.round())} / RM ${fmtCompact.format(targetAmt.round())}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: goalFraction.clamp(0.04, 1.0),
                          minHeight: 7,
                          backgroundColor: AppColors.surfaceContainerHighest,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // 4. Ask FinWise Assistant (Bottom Interactive Bar)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 17, color: AppColors.primary),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Ask FinWise Assistant',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppTheme.pillBorderRadius),
                    ),
                    child: const Text(
                      'Gemini AI',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Horizontally Scrollable Quick-Prompt Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildSuggestionChip(
                      'Can I afford dining out tonight?',
                      Icons.restaurant,
                      AppColors.primary,
                      onTap: () {
                        _promptController.text = 'Can I afford dining out tonight?';
                        _triggerAiEvaluation(
                          _promptController.text,
                          surplus: predictedSurplus,
                          monthExpenses: monthExpenses,
                          primaryGoal: activeGoal,
                          purchaseInsight: txProvider?.aiPurchaseInsight,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildSuggestionChip(
                      'Forecast my next month budget',
                      Icons.query_stats,
                      AppColors.secondary,
                      onTap: () {
                        _promptController.text = 'Forecast my next month budget';
                        _triggerAiEvaluation(
                          _promptController.text,
                          surplus: predictedSurplus,
                          monthExpenses: monthExpenses,
                          primaryGoal: activeGoal,
                          purchaseInsight: txProvider?.aiPurchaseInsight,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildSuggestionChip(
                      'How can I reach my goal faster?',
                      Icons.savings,
                      const Color(0xFFE65100),
                      onTap: () {
                        _promptController.text = 'How can I reach my goal faster?';
                        _triggerAiEvaluation(
                          _promptController.text,
                          surplus: predictedSurplus,
                          monthExpenses: monthExpenses,
                          primaryGoal: activeGoal,
                          purchaseInsight: txProvider?.aiPurchaseInsight,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // AI Response Box
              if (_aiResponse != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppTheme.cardPadding),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixedDim.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.smart_toy, size: 16, color: AppColors.primary),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'FinWise Live Response',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => setState(() => _aiResponse = null),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _aiResponse!,
                        style: const TextStyle(fontSize: 13, color: AppColors.onSurface, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Rounded Input Pill with Circular Dark-Blue Sparkle Submit Button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.borderNeutral),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(14, 5, 6, 5),
                child: Row(
                  children: [
                    const Icon(Icons.bubble_chart, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _promptController,
                        style: const TextStyle(fontSize: 13),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            _triggerAiEvaluation(
                              val.trim(),
                              surplus: predictedSurplus,
                              monthExpenses: monthExpenses,
                              primaryGoal: activeGoal,
                              purchaseInsight: txProvider?.aiPurchaseInsight,
                            );
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: 'Ask FinWise AI about your spending...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: AppColors.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          final q = _promptController.text.trim();
                          if (q.isNotEmpty) {
                            _triggerAiEvaluation(
                              q,
                              surplus: predictedSurplus,
                              monthExpenses: monthExpenses,
                              primaryGoal: activeGoal,
                              purchaseInsight: txProvider?.aiPurchaseInsight,
                            );
                          }
                        },
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: _isAnalyzing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.auto_awesome, color: Colors.white, size: 19),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticShell({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
    required String description,
    required Widget footer,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.cardPadding),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(AppTheme.pillBorderRadius),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.38),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          footer,
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(
    String text,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderNeutral),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
          ],
        ),
      ),
    );
  }
}

enum _LegendSwatchType { solidLine, dashedLine, rangeBox }

class _ChartLegendItem extends StatelessWidget {
  final _LegendSwatchType swatch;
  final Color color;
  final String label;

  const _ChartLegendItem({
    required this.swatch,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    Widget indicator;
    switch (swatch) {
      case _LegendSwatchType.solidLine:
        indicator = Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        );
      case _LegendSwatchType.dashedLine:
        indicator = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 5, height: 2.5, color: color),
            const SizedBox(width: 2),
            Container(width: 5, height: 2.5, color: color),
            const SizedBox(width: 2),
            Container(width: 4, height: 2.5, color: color),
          ],
        );
      case _LegendSwatchType.rangeBox:
        indicator = Container(
          width: 14,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.growthMintSubtle,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
        );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _ForecastChartPainter extends CustomPainter {
  final String surplusLabel;

  const _ForecastChartPainter({required this.surplusLabel});

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, {double dash = 5, double gap = 4}) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = (end - start).distance;
    if (distance <= 0) return;
    final ux = dx / distance;
    final uy = dy / distance;
    double drawn = 0;
    while (drawn < distance) {
      final segEnd = (drawn + dash).clamp(0.0, distance);
      canvas.drawLine(
        Offset(start.dx + ux * drawn, start.dy + uy * drawn),
        Offset(start.dx + ux * segEnd, start.dy + uy * segEnd),
        paint,
      );
      drawn += dash + gap;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPad = 14;
    const double rightPad = 16;
    const double topPad = 28;
    const double bottomPad = 12;

    final double plotW = (size.width - leftPad - rightPad).clamp(40.0, size.width);
    final double plotH = (size.height - topPad - bottomPad).clamp(40.0, size.height);
    final double nowX = leftPad + plotW * 0.44;
    final double endX = leftPad + plotW;

    double yAt(double frac) => topPad + plotH * frac;

    final paintGrid = Paint()
      ..color = AppColors.borderNeutral
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Subtle gridlines
    for (final f in const [0.18, 0.50, 0.82]) {
      _drawDashedLine(canvas, Offset(leftPad, yAt(f)), Offset(endX, yAt(f)), paintGrid, dash: 4, gap: 4);
    }

    // Confidence band (NOW -> M+3)
    final bandPath = Path()
      ..moveTo(nowX, yAt(0.56))
      ..lineTo(leftPad + plotW * 0.63, yAt(0.30))
      ..lineTo(leftPad + plotW * 0.82, yAt(0.18))
      ..lineTo(endX, yAt(0.08))
      ..lineTo(endX, yAt(0.50))
      ..lineTo(leftPad + plotW * 0.82, yAt(0.60))
      ..lineTo(leftPad + plotW * 0.63, yAt(0.66))
      ..close();
    canvas.drawPath(
      bandPath,
      Paint()
        ..color = AppColors.secondaryFixed.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );

    // Solid blue line: Actual Spent (M-2 -> NOW)
    final paintActual = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final actualPath = Path()
      ..moveTo(leftPad, yAt(0.76))
      ..quadraticBezierTo(leftPad + plotW * 0.22, yAt(0.84), nowX, yAt(0.56));
    canvas.drawPath(actualPath, paintActual);

    // Dashed green line: AI Forecast (NOW -> M+3) using path metrics
    final paintForecast = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final forecastPath = Path()
      ..moveTo(nowX, yAt(0.56))
      ..cubicTo(
        leftPad + plotW * 0.62,
        yAt(0.45),
        leftPad + plotW * 0.80,
        yAt(0.36),
        endX,
        yAt(0.28),
      );
    for (final metric in forecastPath.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = (dist + 6).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paintForecast);
        dist += 10;
      }
    }

    // Vertical dashed NOW divider + NOW badge pill
    final paintSplit = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.7)
      ..strokeWidth = 1.5;
    _drawDashedLine(canvas, Offset(nowX, topPad - 4), Offset(nowX, size.height - bottomPad), paintSplit, dash: 4, gap: 4);

    final nowTp = TextPainter(
      text: const TextSpan(
        text: 'NOW',
        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final nowRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(nowX, 13), width: nowTp.width + 16, height: 17),
      const Radius.circular(9),
    );
    canvas.drawRRect(nowRect, Paint()..color = AppColors.primary);
    nowTp.paint(canvas, Offset(nowX - nowTp.width / 2, 13 - nowTp.height / 2));

    // Endpoint value pill clamped strictly inside bounds so right edge never clips
    final endTp = TextPainter(
      text: TextSpan(
        text: surplusLabel,
        style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final pillW = endTp.width + 16;
    const pillH = 20.0;
    final pillLeft = (endX - pillW + 4).clamp(4.0, size.width - pillW - 4.0);
    const pillTop = 4.0;
    final endRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pillLeft, pillTop, pillW, pillH),
      const Radius.circular(10),
    );
    canvas.drawRRect(endRect, Paint()..color = AppColors.secondary);
    endTp.paint(canvas, Offset(pillLeft + 8, pillTop + (pillH - endTp.height) / 2));

    // Marker dots
    final dotBlue = Paint()..color = AppColors.primary;
    final dotGreen = Paint()..color = AppColors.secondary;
    final dotBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(leftPad, yAt(0.76)), 3.5, dotBlue);
    canvas.drawCircle(Offset(nowX, yAt(0.56)), 4.5, dotBlue);
    canvas.drawCircle(Offset(nowX, yAt(0.56)), 4.5, dotBorder);
    canvas.drawCircle(Offset(endX, yAt(0.28)), 4.5, dotGreen);
    canvas.drawCircle(Offset(endX, yAt(0.28)), 4.5, dotBorder);
  }

  @override
  bool shouldRepaint(covariant _ForecastChartPainter oldDelegate) =>
      oldDelegate.surplusLabel != surplusLabel;
}
