import 'package:finwise_app/providers/profile_provider.dart';
import 'package:finwise_app/services/auth_service.dart';
import 'package:finwise_app/widgets/profile/danger_zone_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Profile provider validates required fields and username', () {
    final provider = ProfileProvider();

    provider.setDisplayName('');
    provider.setUsername('valid_user');
    provider.setBio('A short bio');
    expect(provider.validate(), 'Display name is required.');

    provider.setDisplayName('Jane Doe');
    provider.setUsername('bad name');
    expect(provider.validate(),
        'Username must be 3-30 characters using letters, numbers, or underscores.');

    provider.setUsername('jane_doe');
    provider.setBio(List.filled(161, 'x').join());
    expect(provider.validate(), 'Bio must be 160 characters or fewer.');

    provider.setBio('A short bio');
    expect(provider.validate(), isNull);
  });

  test('Profile provider stays clean before loading', () {
    final provider = ProfileProvider();
    expect(provider.isDirty, isFalse);
    provider.setDisplayName('Jane Doe');
    expect(provider.isDirty, isFalse);
  });

  testWidgets('Danger zone requires typing DELETE', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => DangerZoneModal(
                      authService: AuthService(),
                    ),
                  );
                },
                child: const Text('Open Danger Zone'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Danger Zone'));
    await tester.pump();

    final deleteButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Permanently Delete'),
    );
    expect(deleteButton.onPressed, isNull);

    await tester.enterText(
      find.widgetWithText(TextField, 'Type DELETE to confirm'),
      'DELETE',
    );
    await tester.pump();

    final enabledButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Permanently Delete'),
    );
    expect(enabledButton.onPressed, isNotNull);
  });
}
