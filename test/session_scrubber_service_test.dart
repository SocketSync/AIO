import 'package:finwise_app/services/session_scrubber_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('clears local storage when Supabase sign out fails', () async {
    SharedPreferences.setMockInitialValues({
      'profile_theme_preference': 'dark',
      'profile_ai_insights': false,
      'unrelated_cached_data': 'private',
    });
    var resetInMemoryStateCalled = false;
    final scrubber = SessionScrubberService(
      resetInMemoryState: () => resetInMemoryStateCalled = true,
    );

    await scrubber.scrubSession(
      signOut: () async => throw StateError('offline'),
    );

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getKeys(), isEmpty);
    expect(resetInMemoryStateCalled, isTrue);
  });
}
