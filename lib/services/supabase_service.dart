import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton wrapper managing Supabase client initialization and connectivity.
///
/// Reads public client credentials exclusively from compile-time
/// `--dart-define` values (`SUPABASE_URL` and `SUPABASE_ANON_KEY`) so secrets
/// are never hardcoded in source control.
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const _configuredUrl = String.fromEnvironment('SUPABASE_URL');
  static const _configuredAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  bool _isInitialized = false;

  /// Compile-time Supabase project URL provided via `--dart-define=SUPABASE_URL=...`.
  static String? get supabaseUrl =>
      _configuredUrl.isEmpty ? null : _configuredUrl;

  /// Compile-time Supabase public anon key provided via `--dart-define=SUPABASE_ANON_KEY=...`.
  static String? get supabaseAnonKey =>
      _configuredAnonKey.isEmpty ? null : _configuredAnonKey;

  /// Returns `true` only when both `SUPABASE_URL` and `SUPABASE_ANON_KEY` are
  /// provided at compile time and do not contain template placeholders.
  static bool get isConfigured {
    final url = supabaseUrl;
    final key = supabaseAnonKey;
    return url != null &&
        url.isNotEmpty &&
        !url.contains('your-project') &&
        key != null &&
        key.isNotEmpty &&
        !key.contains('your-supabase');
  }

  /// Whether [initialize] has successfully initialized [Supabase.instance].
  bool get isInitialized => _isInitialized;

  /// Returns the active [SupabaseClient] once initialized, or `null` when
  /// credentials are unconfigured or initialization was deferred.
  SupabaseClient? get client {
    if (_isInitialized) {
      try {
        return Supabase.instance.client;
      } catch (e) {
        debugPrint('Supabase client error: $e');
        return null;
      }
    }
    return null;
  }

  /// Initialize the Supabase client via [Supabase.initialize] using
  /// compile-time environment credentials; safely no-ops if unconfigured.
  Future<bool> initialize() async {
    if (!isConfigured) {
      debugPrint('[SupabaseService] Configuration not found or using placeholders in .env.');
      return false;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl!,
        // ignore: deprecated_member_use
        anonKey: supabaseAnonKey!,
      );
      _isInitialized = true;
      debugPrint('[SupabaseService] Successfully connected to Supabase: $supabaseUrl');
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] Initialization failed: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Tests Supabase connectivity by querying up to five category records.
  Future<Map<String, dynamic>> testConnection() async {
    if (!isConfigured) {
      return {
        'connected': false,
        'message': 'Supabase URL or Anon Key is missing in .env file.',
        'url': supabaseUrl ?? 'Not set',
      };
    }

    try {
      final supaClient = client;
      if (supaClient == null) {
        await initialize();
      }

      final activeClient = client;
      if (activeClient == null) {
        return {
          'connected': false,
          'message': 'Failed to instantiate Supabase client.',
          'url': supabaseUrl,
        };
      }

      // Query categories table to verify schema and connectivity
      final response = await activeClient
          .from('categories')
          .select('id, name')
          .limit(5);

      return {
        'connected': true,
        'message': 'Connected to Supabase PostgreSQL database successfully!',
        'url': supabaseUrl,
        'categories_count': (response as List).length,
      };
    } catch (e) {
      return {
        'connected': false,
        'message': 'Error querying Supabase: $e',
        'url': supabaseUrl,
      };
    }
  }
}
