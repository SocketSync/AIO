import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'budgets_screen.dart';
import 'insights_screen.dart';
import 'simulator_screen.dart';
import 'profile_screen.dart';

/// Persistent bottom-navigation shell hosting the dashboard and core FinWise
/// tabs (Home, Goals, Add Action, Insights, Simulator, Profile) (AIO-85).
/// Keeps tab state in an [IndexedStack] while the navigation remains visible.
class MainNavigationShell extends StatefulWidget {
  final int initialTab;
  const MainNavigationShell({super.key, this.initialTab = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    DashboardScreen(),
    BudgetsScreen(initialTab: 1),
    InsightsScreen(),
    SimulatorScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  void didUpdateWidget(covariant MainNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      _currentIndex = widget.initialTab;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.95),
          border: const Border(top: BorderSide(color: AppColors.borderNeutral, width: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
                child: Row(
                  children: [
                    // 1. Home Tab
                    Expanded(
                      child: _buildNavItem(
                        key: const Key('nav_home'),
                        index: 0,
                        icon: Icons.home,
                        label: 'Home',
                      ),
                    ),

                    // 2. Goals Tab
                    Expanded(
                      child: _buildNavItem(
                        key: const Key('nav_goals'),
                        index: 1,
                        icon: Icons.savings_rounded,
                        label: 'Goals',
                      ),
                    ),

                    // 3. Center Add Floating Button
                    Expanded(
                      child: Center(
                        child: Semantics(
                          button: true,
                          label: 'Add Transaction',
                          child: GestureDetector(
                            key: const Key('nav_add'),
                            onTap: () {
                              Navigator.of(context).pushNamed('/add-transaction');
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryContainer.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 26),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 4. Insights Tab
                    Expanded(
                      child: _buildNavItem(
                        key: const Key('nav_insights'),
                        index: 2,
                        icon: Icons.auto_awesome,
                        label: 'Insights',
                      ),
                    ),

                    // 5. Profile Tab
                    Expanded(
                      child: _buildNavItem(
                        key: const Key('nav_profile'),
                        index: 4,
                        icon: Icons.person,
                        label: 'Profile',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required Key key,
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        key: key,
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
