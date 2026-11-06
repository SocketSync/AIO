import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finwise_app/main.dart';
import 'package:finwise_app/models/transaction_record.dart';
import 'package:finwise_app/services/database_service.dart';

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
}
