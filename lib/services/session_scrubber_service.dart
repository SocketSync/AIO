import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_service.dart';

typedef LocalSignOut = Future<void> Function();

class SessionScrubberService {
  SessionScrubberService({
    required VoidCallback resetInMemoryState,
    DatabaseService? databaseService,
    Future<SharedPreferences> Function()? loadPreferences,
  })  : _resetInMemoryState = resetInMemoryState,
        _databaseService = databaseService ?? DatabaseService(),
        _loadPreferences = loadPreferences ?? SharedPreferences.getInstance;

  final VoidCallback _resetInMemoryState;
  final DatabaseService _databaseService;
  final Future<SharedPreferences> Function() _loadPreferences;

  Future<void> scrubSession({LocalSignOut? signOut}) async {
    final errors = <Object>[];
    _resetInMemoryStateSafely(errors);

    if (signOut != null) {
      try {
        await signOut();
      } catch (error) {
        debugPrint('[SessionScrubberService] Supabase sign out failed: $error');
      }
    }

    await _clearLocalData(errors);
  }

  Future<void> scrubLocalData() async {
    final errors = <Object>[];
    _resetInMemoryStateSafely(errors);
    await _clearLocalData(errors);
  }

  void _resetInMemoryStateSafely(List<Object> errors) {
    try {
      _resetInMemoryState();
    } catch (error) {
      errors.add(error);
    }
  }

  Future<void> _clearLocalData(List<Object> errors) async {
    try {
      final preferences = await _loadPreferences();
      await preferences.clear();
    } catch (error) {
      errors.add(error);
    }

    try {
      _databaseService.clearLocalCache();
    } catch (error) {
      errors.add(error);
    }

    if (errors.isNotEmpty) {
      throw StateError(
        'Could not completely clear local session data: ${errors.join('; ')}',
      );
    }
  }
}
