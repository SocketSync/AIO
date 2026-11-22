import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:finwise_app/main.dart';
import 'package:finwise_app/models/transaction_record.dart';
import 'package:finwise_app/providers/savings_goal_provider.dart';
import 'package:finwise_app/providers/transaction_provider.dart';
import 'package:finwise_app/screens/add_transaction_screen.dart';
import 'package:finwise_app/screens/budgets_screen.dart';
import 'package:finwise_app/screens/dashboard_screen.dart';
import 'package:finwise_app/screens/insights_screen.dart';
import 'package:finwise_app/screens/login_screen.dart';
import 'package:finwise_app/screens/main_navigation_shell.dart';
import 'package:finwise_app/screens/profile_screen.dart';
import 'package:finwise_app/screens/receipt_scanner_screen.dart';
import 'package:finwise_app/screens/simulator_screen.dart';
import 'package:finwise_app/services/auth_service.dart';
import 'package:finwise_app/services/database_service.dart';

void main() {
  setUp(() async {
    await AuthService().signOut();
  });

  tearDown(() async {
    await AuthService().signOut();
  });
  testWidgets(
      '1. Login screen smoke test - strictly renders FinWise branding & Google Sign-In only',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const FinWiseApp());
    await tester.pumpAndSettle();

    expect(find.text('FinWise'), findsWidgets);
    expect(find.text('AI-Powered Personal Financial Intelligence'),
        findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);

    // Verify zero school or UTM ID options exist
    expect(find.textContaining('UTM'), findsNothing);
    expect(find.textContaining('Matric'), findsNothing);
  });

  testWidgets('Google account picker renders without a ListTile paint error',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const FinWiseApp());
    await tester.pumpAndSettle();
    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/register');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Up with Google (Gmail)'));
    await tester.pumpAndSettle();

    expect(find.text('Google Accounts'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Goals route loads without notifying providers during build',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const FinWiseApp());
    await tester.pumpAndSettle();
    await AuthService().signInWithPassword(
      email: 'demo@finwise-app.xyz',
      password: 'FinWise2026!',
    );
    await tester.pumpAndSettle();

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/goals');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  test('Goal creation explains when Supabase is not configured', () async {
    final provider = SavingsGoalProvider();

    final error = await provider.addGoal(
      goalName: 'Emergency fund',
      targetAmount: 1000,
      targetDate: DateTime.now().add(const Duration(days: 30)),
    );

    expect(error, 'Savings goals require a configured Supabase backend.');
  });

  testWidgets(
      '2. Dashboard screen smoke test - renders balance, quick services, recent transactions & FAB',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await AuthService().signInWithPassword(
      email: 'demo@finwise-app.xyz',
      password: 'FinWise2026!',
    );

    await tester.pumpWidget(const FinWiseApp());
    await tester.pumpAndSettle();

    // Navigate to dashboard
    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/dashboard');
    await tester.pumpAndSettle();

    // Verify Dashboard Core Components
    expect(find.text('Total Net Balance'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);

    // Verify Quick Action Modules Grid
    expect(find.text('Budgeting'), findsWidgets);
    expect(find.text('Savings Goals'), findsWidgets);
    expect(find.text('AI Insights'), findsWidgets);
    expect(find.text('Forecast'), findsWidgets);
    expect(find.text('Simulator'), findsWidgets);

    // Verify Floating Action Button
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Add Transaction'), findsWidgets);
  });

  testWidgets('Savings Goals route opens the goals screen and create dialog',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await AuthService().signInWithPassword(
      email: 'demo@finwise-app.xyz',
      password: 'FinWise2026!',
    );

    await tester.pumpWidget(const FinWiseApp());
    await tester.pumpAndSettle();

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/goals');
    await tester.pumpAndSettle();

    expect(find.text('No savings goals yet'), findsOneWidget);
    expect(find.text('+ Add New Goal'), findsOneWidget);

    await tester.tap(find.text('+ Add New Goal'));
    await tester.pumpAndSettle();

    expect(find.text('New Savings Goal'), findsOneWidget);
    expect(find.text('Goal Name'), findsOneWidget);
    expect(find.text('Target Amount (RM)'), findsOneWidget);
  });

  testWidgets(
      '3. Add Transaction screen smoke test - renders inputs and form controls',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await AuthService().signInWithPassword(
      email: 'demo@finwise-app.xyz',
      password: 'FinWise2026!',
    );

    await tester.pumpWidget(const FinWiseApp());
    await tester.pumpAndSettle();

    // Navigate to add transaction
    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/add-transaction');
    await tester.pumpAndSettle();

    expect(find.text('Add Transaction'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('RM'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Save Transaction'), findsOneWidget);
  });

  test('4. Database Service CRUD test - Create, Read, Update, Delete',
      () async {
    final db = DatabaseService();
    const testUserId = 'test_user_sprint1';

    // 1. Initial Read
    final initialList = await db.getTransactions(testUserId);
    expect(initialList.isNotEmpty, true);
    final initialCount = initialList.length;

    // 2. Create (Write to database)
    final newTx = TransactionRecord(
      id: 'mock_tx_001',
      userId: testUserId,
      title: 'Mock Test Expense',
      amount: 45.00,
      type: TransactionType.expense,
      categoryId: 'food_dining',
      date: DateTime.now(),
      notes: 'Test transaction entry for Sprint 1 verification',
    );
    final created = await db.createTransaction(newTx);
    expect(created.id, 'mock_tx_001');

    // 3. Read Verification
    final updatedList = await db.getTransactions(testUserId);
    expect(updatedList.length, initialCount + 1);
    expect(updatedList.any((t) => t.title == 'Mock Test Expense'), true);

    // 4. Update
    final modifiedTx = created.copyWith(
      title: 'Updated Mock Test Expense',
      amount: 55.00,
    );
    final updated = await db.updateTransaction(modifiedTx);
    expect(updated.title, 'Updated Mock Test Expense');
    expect(updated.amount, 55.00);

    // 5. Delete
    final deleteResult = await db.deleteTransaction('mock_tx_001', testUserId);
    expect(deleteResult, true);
    final finalList = await db.getTransactions(testUserId);
    expect(finalList.length, initialCount);
    expect(finalList.any((t) => t.id == 'mock_tx_001'), false);
  });

  testWidgets(
      '5. Register screen smoke test - Google Sign-Up and zero school/matric references',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const FinWiseApp());
    await tester.pumpAndSettle();

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/register');
    await tester.pumpAndSettle();

    expect(find.text('Register'), findsWidgets);
    expect(find.text('Sign Up with Google (Gmail)'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Google / Gmail Address'), findsOneWidget);
    expect(find.text('Create Password'), findsOneWidget);

    // Verify zero school or UTM ID options exist
    expect(find.textContaining('UTM'), findsNothing);
    expect(find.textContaining('Matric'), findsNothing);
  });

  testWidgets(
      '6. Forgot Password screen test - renders email input, send button, and zero school references',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const FinWiseApp());
    await tester.pumpAndSettle();

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/forgot-password');
    await tester.pumpAndSettle();

    expect(find.text('Reset Password'), findsWidgets);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);
    expect(find.text('Back to Sign In'), findsOneWidget);

    // Verify zero school or UTM ID options exist
    expect(find.textContaining('UTM'), findsNothing);
    expect(find.textContaining('Matric'), findsNothing);
  });

  testWidgets(
      '6b. Forgot Password resend cooldown timer counts down 60s, resends without Form crash, and disposes cleanly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const FinWiseApp());
    await tester.pumpAndSettle();

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/forgot-password');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'test.user@gmail.com');
    await tester.tap(find.text('Send Reset Link'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(find.text('Check your email'), findsOneWidget);
    expect(find.text('Resend in 60s'), findsOneWidget);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Resend in 59s'), findsOneWidget);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );

    await tester.pump(const Duration(seconds: 59));
    expect(find.text('Resend Email'), findsOneWidget);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Resend Email'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Resend in 60s'), findsOneWidget);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );

    navigator.pop();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });

  test(
      '7. Password Verification with Database - Rejects incorrect password and accepts matching password',
      () async {
    final auth = AuthService();

    // Test 1: Incorrect password fails with exception
    expect(
      () => auth.signInWithPassword(
          email: 'demo@finwise-app.xyz', password: 'WrongPassword123!'),
      throwsA(isA<Exception>()),
    );

    // Test 2: Unregistered email fails with exception
    expect(
      () => auth.signInWithPassword(
          email: 'unregistered.user@gmail.com', password: 'AnyPassword!'),
      throwsA(isA<Exception>()),
    );

    // Test 3: Matching password succeeds
    final user = await auth.signInWithPassword(
      email: 'demo@finwise-app.xyz',
      password: 'FinWise2026!',
    );
    expect(user, isNotNull);
    expect(user!.email, 'demo@finwise-app.xyz');
  });

  test(
      '8. User Database Separation - Isolated transaction partitions for separate user accounts',
      () async {
    final db = DatabaseService();
    const userA = '00000000-0000-4000-8000-000000000001';
    const userB = '00000000-0000-4000-8000-000000000002';

    // 1. Fetch User A's transactions
    final listA = await db.getTransactions(userA);
    // 2. Fetch User B's transactions
    final listB = await db.getTransactions(userB);

    // Verify User A and User B have separate partitions
    expect(listA.isNotEmpty, true);
    expect(listB.isNotEmpty, true);
    expect(listA.first.userId, userA);
    expect(listB.first.userId, userB);

    // Add transaction to User A only
    final newTxA = TransactionRecord(
      id: 'tx_userA_exclusive',
      userId: userA,
      title: 'User A Exclusive Tech Gear',
      amount: 199.00,
      type: TransactionType.expense,
      categoryId: 'shopping',
      date: DateTime.now(),
    );
    await db.createTransaction(newTxA);

    // Verify User A has it, but User B does NOT have it
    final updatedA = await db.getTransactions(userA);
    final updatedB = await db.getTransactions(userB);
    expect(updatedA.any((t) => t.id == 'tx_userA_exclusive'), true);
    expect(updatedB.any((t) => t.id == 'tx_userA_exclusive'), false);
  });

  testWidgets(
      '9. AuthGate startup redirect - active session lands on MainNavigationShell instead of LoginScreen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await AuthService().signInWithPassword(
      email: 'demo@finwise-app.xyz',
      password: 'FinWise2026!',
    );

    await tester.pumpWidget(const FinWiseApp());
    await tester.pumpAndSettle();

    expect(find.byType(MainNavigationShell), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.text('Total Net Balance'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      '10. Route guards - unauthenticated protected routes redirect to LoginScreen and authenticated routes open',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const FinWiseApp());
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);

    const protectedRoutes = [
      '/dashboard',
      '/budgets',
      '/goals',
      '/insights',
      '/simulator',
      '/profile',
      '/add-transaction',
      '/receipt-scanner',
      '/scanner',
    ];

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    for (final route in protectedRoutes) {
      navigator.pushNamed(route);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget,
          reason: 'Unauthenticated route $route should redirect to LoginScreen');
      expect(find.byType(MainNavigationShell), findsNothing);
      expect(find.byType(DashboardScreen), findsNothing);
      expect(find.byType(BudgetsScreen), findsNothing);
      expect(find.byType(InsightsScreen), findsNothing);
      expect(find.byType(SimulatorScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsNothing);
      expect(find.byType(AddTransactionScreen), findsNothing);
      expect(find.byType(ReceiptScannerScreen), findsNothing);
    }

    await AuthService().signInWithPassword(
      email: 'demo@finwise-app.xyz',
      password: 'FinWise2026!',
    );
    await tester.pumpAndSettle();

    navigator.pushNamed('/receipt-scanner');
    await tester.pumpAndSettle();

    expect(find.byType(ReceiptScannerScreen), findsOneWidget);
    expect(find.text('Smart Receipt AI'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      '11. signOut clears session state, resets provider caches, and clears navigation stack to LoginScreen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await AuthService().signInWithPassword(
      email: 'demo@finwise-app.xyz',
      password: 'FinWise2026!',
    );

    await tester.pumpWidget(const FinWiseApp());
    await tester.pumpAndSettle();

    final BuildContext appContext = tester.element(find.byType(MaterialApp));
    final txProvider =
        Provider.of<TransactionProvider>(appContext, listen: false);
    final goalProvider =
        Provider.of<SavingsGoalProvider>(appContext, listen: false);

    txProvider.setSearchQuery('Salary');
    expect(txProvider.transactions, isNotEmpty);
    expect(txProvider.currentUserId, isNotEmpty);
    expect(goalProvider.currentUserId, isNotEmpty);

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/profile');
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(navigator.canPop(), isTrue);

    await AuthService().signOut();
    await tester.pumpAndSettle();

    expect(AuthService().isAuthenticated, isFalse);
    expect(AuthService().currentUser, isNull);
    expect(txProvider.transactions, isEmpty);
    expect(txProvider.searchQuery, isEmpty);
    expect(txProvider.currentUserId, isEmpty);
    expect(goalProvider.goals, isEmpty);
    expect(goalProvider.currentUserId, isEmpty);
    expect(navigator.canPop(), isFalse);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.byType(MainNavigationShell), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      '12a. onAuthStateChange signedOut returns user to LoginScreen and clears stack & provider caches',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await AuthService().signInWithPassword(
      email: 'demo@finwise-app.xyz',
      password: 'FinWise2026!',
    );

    await tester.pumpWidget(const FinWiseApp());
    await tester.pumpAndSettle();

    final BuildContext appContext = tester.element(find.byType(MaterialApp));
    final txProvider =
        Provider.of<TransactionProvider>(appContext, listen: false);
    final goalProvider =
        Provider.of<SavingsGoalProvider>(appContext, listen: false);

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/add-transaction');
    await tester.pumpAndSettle();
    navigator.pushNamed('/profile');
    await tester.pumpAndSettle();
    expect(navigator.canPop(), isTrue);

    AuthService().handleAuthStateChange(AuthChangeEvent.signedOut, null);
    await tester.pumpAndSettle();

    expect(AuthService().isAuthenticated, isFalse);
    expect(AuthService().currentUser, isNull);
    expect(txProvider.transactions, isEmpty);
    expect(txProvider.currentUserId, isEmpty);
    expect(goalProvider.goals, isEmpty);
    expect(goalProvider.currentUserId, isEmpty);
    expect(navigator.canPop(), isFalse);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.byType(AddTransactionScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      '12b. onAuthStateChange tokenRefreshed with null session clears session and returns to LoginScreen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await AuthService().signInWithPassword(
      email: 'demo@finwise-app.xyz',
      password: 'FinWise2026!',
    );

    await tester.pumpWidget(const FinWiseApp());
    await tester.pumpAndSettle();

    final BuildContext appContext = tester.element(find.byType(MaterialApp));
    final txProvider =
        Provider.of<TransactionProvider>(appContext, listen: false);
    final goalProvider =
        Provider.of<SavingsGoalProvider>(appContext, listen: false);

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/profile');
    await tester.pumpAndSettle();
    expect(navigator.canPop(), isTrue);

    AuthService().handleAuthStateChange(AuthChangeEvent.tokenRefreshed, null);
    await tester.pumpAndSettle();

    expect(AuthService().isAuthenticated, isFalse);
    expect(AuthService().currentUser, isNull);
    expect(txProvider.transactions, isEmpty);
    expect(txProvider.currentUserId, isEmpty);
    expect(goalProvider.goals, isEmpty);
    expect(goalProvider.currentUserId, isEmpty);
    expect(navigator.canPop(), isFalse);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      '13. Add Transaction form validation - shows inline errors for empty fields and non-positive amounts',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await AuthService().signInWithPassword(
      email: 'demo@finwise-app.xyz',
      password: 'FinWise2026!',
    );

    await tester.pumpWidget(const FinWiseApp());
    await tester.pumpAndSettle();

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/add-transaction');
    await tester.pumpAndSettle();

    final saveButton = find.text('Save Transaction');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Enter amount'), findsOneWidget);
    expect(find.text('Please provide a description'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, '0');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Enter valid amount > 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

// AIO-141: Automated widget and unit tests.
