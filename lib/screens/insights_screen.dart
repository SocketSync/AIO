import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final TextEditingController _promptController = TextEditingController();
  String? _aiResponse;
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _triggerAiEvaluation(String query) {
    setState(() {
      _isAnalyzing = true;
      _aiResponse = 'Consulting cash flow trajectory and verified transactions...';
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        if (query.toLowerCase().contains('dining') || query.toLowerCase().contains('dinner') || query.toLowerCase().contains('afford')) {
          _aiResponse = 'Yes! You have an unallocated weekend buffer of RM 85. Dining out under RM 35 tonight leaves your end-of-month surplus safely at +RM 605.';
        } else if (query.toLowerCase().contains('tuition') || query.toLowerCase().contains('fee')) {
          _aiResponse = 'Based on recurring inflows, your upcoming RM 1,200 tuition payment in Jan will maintain a safety margin of RM 440 without dipping into your laptop fund.';
        } else if (query.toLowerCase().contains('save') || query.toLowerCase().contains('100')) {
          _aiResponse = 'FinWise calculated that trimming weekend specialty coffee and dining out frees up approximately RM 32/week (saving ~RM 128/month).';
        } else {
          _aiResponse = 'Based on your latest 30-day spending patterns, your daily safe expenditure rate is RM 32.18/day. You are on track to achieve a net surplus of +RM 640 this term.';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  // 1. Top Context Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SMART ADVISORY', style: TextStyle(fontSize: 10, letterSpacing: 1, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                          Text('AI Financial Assistant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixedDim.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.psychology, color: AppColors.primary, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.growthMintSubtle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: AppColors.secondary),
                        SizedBox(width: 6),
                        Text(
                          'Active Analysis • Synced with Dynamic Budget',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Cash Flow Forecasting Engine Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderNeutral),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
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
                                Icon(Icons.timeline, color: AppColors.primary, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Cash Flow Forecast',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('Dec 24 – Feb 25', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '3-Month dynamic trajectory model based on recurring expenses',
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 14),

                        // Predicted Surplus Banner
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.growthMintSubtle.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppColors.secondary,
                                    child: Icon(Icons.savings, size: 15, color: Colors.white),
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Predicted End-of-Term Surplus', style: TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w500)),
                                      Text('+RM 640.00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                                    ],
                                  ),
                                ],
                              ),
                              Text('High Confidence', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Chart Visualization Graphic
                        Container(
                          height: 120,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: CustomPaint(
                            painter: _ForecastChartPainter(),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Months Legend
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sep', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            Text('Oct', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            Text('Nov (Today)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            Text('Dec', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                            Text('Jan \'25', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                            Text('Feb', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 3. Behavioral Diagnostic Reports
                  const Row(
                    children: [
                      Icon(Icons.insights, size: 18, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text(
                        'Behavioral Diagnostic',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Report 1: Spending Behavior Habit (+42% spike on weekends)
                  _buildDiagnosticCard(
                    title: 'Spending Behavior Habit',
                    badgeText: '+42% Spike',
                    badgeColor: AppColors.alertCoral,
                    badgeBg: AppColors.alertCoralSubtle,
                    icon: Icons.local_mall,
                    iconColor: AppColors.alertCoral,
                    description: 'You spend 42% more on weekends around shopping & dining. Setting a RM60 weekend cap could save you RM240/month.',
                    actionLabel: 'Set RM60 Cap',
                    onAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Weekend RM60 cap applied to your budget!'), backgroundColor: AppColors.secondary),
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  // Report 2: Recurring Expense Alert
                  _buildDiagnosticCard(
                    title: 'Recurring Expense Alert',
                    badgeText: 'In 3 Days',
                    badgeColor: AppColors.textMuted,
                    badgeBg: AppColors.surfaceContainerHigh,
                    icon: Icons.wifi_tethering,
                    iconColor: AppColors.primary,
                    description: 'Broadband / WiFi bill due in 3 days (RM 49). Adequate balance detected in your primary account for auto-debit.',
                    actionLabel: 'Auto-Debit Ready',
                    onAction: () {},
                  ),
                  const SizedBox(height: 10),

                  // Report 3: Smart Optimization (-15% Food)
                  _buildDiagnosticCard(
                    title: 'Smart Optimization',
                    badgeText: '-15% Food',
                    badgeColor: AppColors.secondary,
                    badgeBg: AppColors.growthMintSubtle,
                    icon: Icons.laptop_mac,
                    iconColor: AppColors.secondary,
                    description: 'You cut food expenditure by 15% this week. If maintained, your MacBook Pro savings goal completes 18 days earlier!',
                    actionLabel: 'View Goal Progress',
                    onAction: () {},
                  ),
                  const SizedBox(height: 22),

                  // 4. Interactive AI Chat Prompt Dock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text('Ask FinWise Assistant', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Gemini Core', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Suggestion Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSuggestionChip('Can I afford dining out tonight?', Icons.restaurant, AppColors.primary),
                        const SizedBox(width: 8),
                        _buildSuggestionChip('Forecast my tuition payment', Icons.school, AppColors.secondary),
                        const SizedBox(width: 8),
                        _buildSuggestionChip('How to save RM100?', Icons.savings, const Color(0xFFE65100)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Input Pill
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderNeutral),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
                                _triggerAiEvaluation(val.trim());
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: 'Ask FinWise AI about your spending...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: _isAnalyzing
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                              : const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                          onPressed: () {
                            if (_promptController.text.trim().isNotEmpty) {
                              _triggerAiEvaluation(_promptController.text.trim());
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // AI Response Box
                  if (_aiResponse != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixedDim.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.smart_toy, size: 16, color: AppColors.primary),
                                  SizedBox(width: 6),
                                  Text('FinWise Live Response', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ],
                              ),
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
                  ],

                  const SizedBox(height: 80), // Padding for bottom nav
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticCard({
    required String title,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
    required IconData icon,
    required Color iconColor,
    required String description,
    required String actionLabel,
    required VoidCallback onAction,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
                          child: Text(badgeText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(actionLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        _promptController.text = text;
        _triggerAiEvaluation(text);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderNeutral),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
          ],
        ),
      ),
    );
  }
}

class _ForecastChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = AppColors.surfaceContainerHigh
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final paintActual = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintForecast = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintBand = Paint()
      ..color = AppColors.secondaryFixed.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    // Grid lines
    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.25), paintGrid);
    canvas.drawLine(Offset(0, size.height * 0.55), Offset(size.width, size.height * 0.55), paintGrid);
    canvas.drawLine(Offset(0, size.height * 0.85), Offset(size.width, size.height * 0.85), paintGrid);

    // Confidence Band
    final bandPath = Path();
    bandPath.moveTo(size.width * 0.45, size.height * 0.55);
    bandPath.lineTo(size.width * 0.65, size.height * 0.35);
    bandPath.lineTo(size.width * 0.85, size.height * 0.28);
    bandPath.lineTo(size.width, size.height * 0.22);
    bandPath.lineTo(size.width, size.height * 0.50);
    bandPath.lineTo(size.width * 0.85, size.height * 0.60);
    bandPath.lineTo(size.width * 0.65, size.height * 0.68);
    bandPath.close();
    canvas.drawPath(bandPath, paintBand);

    // Actual line (Sep - Nov)
    final actualPath = Path();
    actualPath.moveTo(size.width * 0.05, size.height * 0.75);
    actualPath.quadraticBezierTo(size.width * 0.25, size.height * 0.80, size.width * 0.45, size.height * 0.55);
    canvas.drawPath(actualPath, paintActual);

    // Forecast line (Nov - Feb)
    final forecastPath = Path();
    forecastPath.moveTo(size.width * 0.45, size.height * 0.55);
    forecastPath.cubicTo(size.width * 0.65, size.height * 0.45, size.width * 0.85, size.height * 0.38, size.width, size.height * 0.32);
    canvas.drawPath(forecastPath, paintForecast);

    // Today split indicator
    final paintSplit = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(size.width * 0.45, 0), Offset(size.width * 0.45, size.height), paintSplit);

    // Marker dots
    final paintDot = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(size.width * 0.05, size.height * 0.75), 3.5, paintDot);
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.55), 4.5, paintDot);

    final paintGreenDot = Paint()..color = AppColors.secondary;
    canvas.drawCircle(Offset(size.width, size.height * 0.32), 4.5, paintGreenDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

