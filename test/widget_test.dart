import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finwise_app/main.dart';
import 'package:finwise_app/models/transaction_record.dart';
import 'package:finwise_app/services/database_service.dart';
import 'package:finwise_app/services/auth_service.dart';

void main() {
  testWidgets('1. Login screen smoke test - strictly renders FinWise branding & Google Sign-In only', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const FinWiseApp());
    await tester.pumpAndSettle();

    expect(find.text('FinWise'), findsWidgets);
    expect(find.text('AI-Powered Personal Financial Intelligence'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);

    // Verify zero school or UTM ID options exist
    expect(find.textContaining('UTM'), findsNothing);
    expect(find.textContaining('Matric'), findsNothing);
  });

  testWidgets('2. Dashboard screen smoke test - renders balance, quick services, recent transactions & FAB', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const FinWiseApp());
    await tester.pumpAndSettle();

    // Navigate to dashboard
    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/dashboard');
    await tester.pumpAndSettle();

    // Verify Dashboard Core Components
    expect(find.text('Total Net Balance'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);

    // Verify 4 Quick Action Modules Grid
    expect(find.text('Budgeting'), findsWidgets);
    expect(find.text('AI Insights'), findsWidgets);
    expect(find.text('Forecast'), findsWidgets);
    expect(find.text('Simulator'), findsWidgets);

    // Verify Floating Action Button
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Add Transaction'), findsWidgets);
  });

  testWidgets('3. Add Transaction screen smoke test - renders inputs and form controls', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

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

  test('4. Database Service CRUD test - Create, Read, Update, Delete', () async {
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

  testWidgets('5. Register screen smoke test - Google Sign-Up and zero school/matric references', (WidgetTester tester) async {
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

  testWidgets('6. Forgot Password screen test - renders email input, send button, and zero school references', (WidgetTester tester) async {
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

  test('7. Password Verification with Database - Rejects incorrect password and accepts matching password', () async {
    final auth = AuthService();

    // Test 1: Incorrect password fails with exception
    expect(
      () => auth.signInWithPassword(email: 'keanshen.yeoh@gmail.com', password: 'WrongPassword123!'),
      throwsA(isA<Exception>()),
    );

    // Test 2: Unregistered email fails with exception
    expect(
      () => auth.signInWithPassword(email: 'unregistered.user@gmail.com', password: 'AnyPassword!'),
      throwsA(isA<Exception>()),
    );

    // Test 3: Matching password succeeds
    final user = await auth.signInWithPassword(
      email: 'keanshen.yeoh@gmail.com',
      password: 'FinWise2026!',
    );
    expect(user, isNotNull);
    expect(user!.email, 'keanshen.yeoh@gmail.com');
  });

  test('8. User Database Separation - Isolated transaction partitions for separate user accounts', () async {
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
}
