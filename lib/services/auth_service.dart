import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'database_service.dart';
import 'supabase_service.dart';

enum AuthSessionEvent {
  signedIn,
  signedOut,
  sessionExpired,
}

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String provider;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.provider = 'google',
  });
}

class RegisteredAccount {
  final String id;
  final String email;
  final String name;
  final String passwordHash;
  final String? photoUrl;
  final String? phone;
  final String? occupation;
  final String? currency;
  final double? monthlyBudget;

  RegisteredAccount({
    required this.id,
    required this.email,
    required this.name,
    required this.passwordHash,
    this.photoUrl,
    this.phone,
    this.occupation,
    this.currency,
    this.monthlyBudget,
  });
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _initSupabaseAuthListener();
  }

  static const _uuid = Uuid();

  /// Configured Google Sign-In client requesting email and profile scopes
  /// for the Google authentication entry point (AIO-72).
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<AuthState>? _authStateSubscription;
  final StreamController<AuthSessionEvent> _sessionEventController =
      StreamController<AuthSessionEvent>.broadcast();
  final List<VoidCallback> _sessionResetCallbacks = [];
  bool _isSessionInitialized = false;
  bool _isSupabaseSession = false;
  bool _isSigningOut = false;
  bool _usedDeviceGoogleSignIn = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSessionInitialized => _isSessionInitialized;
  Stream<AuthSessionEvent> get sessionEvents => _sessionEventController.stream;

  bool get isAuthenticated {
    if (_currentUser == null) return false;
    if (_isSupabaseSession && SupabaseService.isConfigured) {
      final client = SupabaseService().client;
      if (client != null) {
        final session = client.auth.currentSession;
        if (session == null || session.isExpired) {
          return false;
        }
      }
    }
    return true;
  }

  void registerSessionResetCallback(VoidCallback callback) {
    if (!_sessionResetCallbacks.contains(callback)) {
      _sessionResetCallbacks.add(callback);
    }
  }

  void unregisterSessionResetCallback(VoidCallback callback) {
    _sessionResetCallbacks.remove(callback);
  }

  void _invokeSessionResetCallbacks() {
    for (final callback in List<VoidCallback>.from(_sessionResetCallbacks)) {
      try {
        callback();
      } catch (e) {
        debugPrint('[AuthService] Session reset callback error: $e');
      }
    }
  }

  void _emitSessionEvent(AuthSessionEvent event) {
    if (!_sessionEventController.isClosed) {
      _sessionEventController.add(event);
    }
  }

  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // Secure registered user accounts registry (isolated by email & UUID)
  final Map<String, RegisteredAccount> _registeredAccounts = {
    'demo@finwise-app.xyz': RegisteredAccount(
      id: '00000000-0000-4000-8000-000000000001',
      email: 'demo@finwise-app.xyz',
      name: 'Demo Finwise',
      passwordHash: hashPassword('FinWise2026!'),
    ),
  };

  /// AIO-93: Check and restore any persisted Supabase session on app startup.
  Future<bool> initializeSession() async {
    _initSupabaseAuthListener();

    if (SupabaseService.isConfigured) {
      try {
        final client = SupabaseService().client;
        if (client != null) {
          final session = client.auth.currentSession;
          if (session != null && !session.isExpired) {
            _setUserFromSupabase(session.user, notify: false);
          } else if (session != null && session.isExpired) {
            try {
              final refreshed = await client.auth
                  .refreshSession()
                  .timeout(const Duration(seconds: 10));
              final refreshedSession = refreshed.session;
              if (refreshedSession != null && !refreshedSession.isExpired) {
                _setUserFromSupabase(refreshedSession.user, notify: false);
              } else {
                await _clearExpiredSupabaseSession(client);
              }
            } catch (e) {
              debugPrint('[AuthService] Expired session refresh failed: $e');
              await _clearExpiredSupabaseSession(client);
            }
          } else if (_isSupabaseSession) {
            _currentUser = null;
            _isSupabaseSession = false;
          }
        }
      } catch (e) {
        debugPrint('[AuthService] Session initialization notice: $e');
      }
    }

    _isSessionInitialized = true;
    notifyListeners();
    return isAuthenticated;
  }

  Future<void> _clearExpiredSupabaseSession(SupabaseClient client) async {
    _isSigningOut = true;
    try {
      await client.auth.signOut().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('[AuthService] Clear expired Supabase session notice: $e');
    } finally {
      _isSigningOut = false;
      _currentUser = null;
      _isSupabaseSession = false;
      _errorMessage = null;
    }
  }

  void _initSupabaseAuthListener() {
    if (_authStateSubscription != null || !SupabaseService.isConfigured) {
      return;
    }

    try {
      final client = SupabaseService().client;
      if (client == null) return;

      final session = client.auth.currentSession;
      if (session != null && !session.isExpired) {
        _setUserFromSupabase(session.user, notify: false);
      }

      _authStateSubscription = client.auth.onAuthStateChange.listen(
        (data) => handleAuthStateChange(data.event, data.session),
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('[AuthService] Supabase auth stream error: $error');
          if (_isSupabaseSession) {
            final current = client.auth.currentSession;
            if (current == null || current.isExpired) {
              handleSessionExpired();
            }
          }
        },
      );
    } catch (e) {
      debugPrint('[AuthService] Supabase auth listener notice: $e');
    }
  }

  /// AIO-93: Process auth state transitions from Supabase or tests.
  void handleAuthStateChange(AuthChangeEvent event, Session? session) {
    if (_isSigningOut && event == AuthChangeEvent.signedOut) {
      return;
    }

    if (event == AuthChangeEvent.signedOut) {
      handleSessionExpired();
      return;
    }

    if (event == AuthChangeEvent.initialSession) {
      _isSessionInitialized = true;
      if (session != null && !session.isExpired) {
        final wasAuthenticated = _currentUser != null;
        _setUserFromSupabase(session.user);
        if (!wasAuthenticated) {
          _emitSessionEvent(AuthSessionEvent.signedIn);
        }
      } else if (_isSupabaseSession && _currentUser != null) {
        handleSessionExpired();
      } else {
        notifyListeners();
      }
      return;
    }

    if (event == AuthChangeEvent.signedIn) {
      _isSessionInitialized = true;
      if (session != null && !session.isExpired) {
        _setUserFromSupabase(session.user);
        _emitSessionEvent(AuthSessionEvent.signedIn);
      } else if (_isSupabaseSession && _currentUser != null) {
        handleSessionExpired();
      }
      return;
    }

    if (event == AuthChangeEvent.tokenRefreshed ||
        event == AuthChangeEvent.userUpdated) {
      if (session != null && !session.isExpired) {
        _setUserFromSupabase(session.user);
      } else if (_currentUser != null) {
        handleSessionExpired();
      }
      return;
    }

    // Fallback for any other auth event (including account deletion/revocation).
    if (session != null && !session.isExpired) {
      _setUserFromSupabase(session.user);
    } else if (session == null && _currentUser != null) {
      handleSessionExpired();
    }
  }

  /// Clear active session state and trigger cache reset + login redirect.
  void handleSessionExpired() {
    final hadSession = _currentUser != null || _isSupabaseSession;
    _currentUser = null;
    _isSupabaseSession = false;
    _errorMessage = null;
    _isLoading = false;
    _invokeSessionResetCallbacks();
    notifyListeners();
    if (hadSession) {
      _emitSessionEvent(AuthSessionEvent.sessionExpired);
    }
  }

  void _setUserFromSupabase(User user, {bool notify = true}) {
    final meta = user.userMetadata ?? {};
    final fullName = (meta['full_name'] as String?) ??
        (meta['name'] as String?) ??
        formatNameFromEmail(user.email ?? 'Google User');
    final avatar = (meta['avatar_url'] as String?) ?? (meta['picture'] as String?);
    final provider = (user.appMetadata['provider'] as String?) ?? 'google';

    _currentUser = AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: fullName,
      photoUrl: avatar,
      provider: provider,
    );
    _isSupabaseSession = true;
    if (notify) {
      notifyListeners();
    }
  }

  /// Format realistic human name from email address (e.g. demo@finwise-app.xyz -> Demo Finwise)
  static String formatNameFromEmail(String email) {
    final prefix = email.split('@')[0];
    final parts = prefix.replaceAll(RegExp(r'[._-]'), ' ').split(' ');
    return parts
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  /// Deterministic valid UUID v5 from email
  static String generateUserUuid(String email) {
    return _uuid.v5(Namespace.url.value, 'mailto:${email.trim().toLowerCase()}');
  }

  /// Sign in with Email and Password (verifies against database and registry)
  Future<AppUser?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final cleanEmail = email.trim().toLowerCase();

    // 1. If account exists in the local database registry, verify password hash
    if (_registeredAccounts.containsKey(cleanEmail)) {
      final account = _registeredAccounts[cleanEmail]!;
      final expectedHash = hashPassword(password);

      if (account.passwordHash != expectedHash) {
        _errorMessage = 'Incorrect password. Please try again.';
        _isLoading = false;
        notifyListeners();
        throw Exception(_errorMessage);
      }

      // Password matches!
      _currentUser = AppUser(
        id: account.id,
        email: account.email,
        displayName: account.name,
        photoUrl: account.photoUrl,
        provider: 'email',
      );
      _isSupabaseSession = false;
      _isSessionInitialized = true;
      _isLoading = false;
      notifyListeners();
      return _currentUser;
    }

    // 2. If not in registry, attempt Supabase backend authentication
    if (SupabaseService.isConfigured) {
      final client = SupabaseService().client;
      if (client != null) {
        try {
          final response = await client.auth
              .signInWithPassword(
                email: cleanEmail,
                password: password,
              )
              .timeout(const Duration(seconds: 10));
          if (response.user != null) {
            _setUserFromSupabase(response.user!);
            _isSessionInitialized = true;
            _isLoading = false;
            notifyListeners();
            return _currentUser;
          }
        } on AuthException catch (e) {
          debugPrint('[AuthService] Supabase AuthException: ${e.message}');
          if (e.message.toLowerCase().contains('invalid login credentials') ||
              e.message.toLowerCase().contains('invalid credentials')) {
            _errorMessage = 'Incorrect password. Please try again.';
            _isLoading = false;
            notifyListeners();
            throw Exception(_errorMessage);
          } else if (e.message.toLowerCase().contains('confirm')) {
            _errorMessage = 'Please confirm your email address or check your inbox.';
            _isLoading = false;
            notifyListeners();
            throw Exception(_errorMessage);
          }
        } catch (e) {
          debugPrint('[AuthService] Supabase signIn notice: $e');
        }
      }
    }

    _errorMessage = 'No account found with this email. Please register first.';
    _isLoading = false;
    notifyListeners();
    throw Exception(_errorMessage);
  }

  /// Register new user with Email and Password
  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();
    final userId = generateUserUuid(cleanEmail);

    // Check if account already exists in local registry
    if (_registeredAccounts.containsKey(cleanEmail)) {
      _isLoading = false;
      notifyListeners();
      throw Exception('An account with this email is already registered. If you forgot your password, please reset it on the login screen.');
    }

    // 1. Attempt Supabase Auth SignUp
    if (SupabaseService.isConfigured) {
      final client = SupabaseService().client;
      if (client != null) {
        try {
          final response = await client.auth
              .signUp(
                email: cleanEmail,
                password: password,
                data: {'full_name': cleanName},
              )
              .timeout(const Duration(seconds: 10));
          if (response.user != null) {
            final identities = response.user!.identities;
            if (identities != null && identities.isEmpty) {
              _isLoading = false;
              notifyListeners();
              throw Exception('An account with this email is already registered. If you forgot your password, please reset it on the login screen.');
            }
            final sbUserId = response.user!.id;
            await client.from('profiles').upsert({
              'id': sbUserId,
              'email': cleanEmail,
              'display_name': cleanName,
              'currency': 'RM',
              'monthly_budget': 2500.00,
            }).timeout(const Duration(seconds: 10));
          }
        } catch (e) {
          debugPrint('[AuthService] Supabase signUp notice: $e');
          if (e.toString().contains('already registered') || e.toString().contains('already exists')) {
            _isLoading = false;
            notifyListeners();
            rethrow;
          }
        }
      }
    }

    // 2. Store hashed credentials in registry
    _registeredAccounts[cleanEmail] = RegisteredAccount(
      id: userId,
      email: cleanEmail,
      name: cleanName,
      passwordHash: hashPassword(password),
    );

    _currentUser = AppUser(
      id: userId,
      email: cleanEmail,
      displayName: cleanName,
      photoUrl: null,
      provider: 'email',
    );
    _isSupabaseSession = false;
    _isSessionInitialized = true;

    _isLoading = false;
    notifyListeners();
    return _currentUser;
  }

  /// Sign in with Google (Gmail)
  Future<AppUser?> signInWithGoogle({
    String? selectedEmail,
    String? selectedName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 1. Explicit Google account specified by user
    if (selectedEmail != null && selectedEmail.trim().isNotEmpty) {
      final email = selectedEmail.trim();
      final cleanEmail = email.trim().toLowerCase();
      final account = _registeredAccounts[cleanEmail];
      final name = (selectedName != null && selectedName.trim().isNotEmpty)
          ? selectedName.trim()
          : (account?.name ?? formatNameFromEmail(cleanEmail));

      final userId = account?.id ?? generateUserUuid(cleanEmail);

      // Ensure account is stored in registered accounts so future logins succeed seamlessly
      if (!_registeredAccounts.containsKey(cleanEmail)) {
        _registeredAccounts[cleanEmail] = RegisteredAccount(
          id: userId,
          email: cleanEmail,
          name: name,
          passwordHash: hashPassword('FinWise2026!'),
        );
      }

      _currentUser = AppUser(
        id: userId,
        email: cleanEmail,
        displayName: name,
        photoUrl: account?.photoUrl,
        provider: 'google',
      );
      _isSupabaseSession = false;
      _isSessionInitialized = true;
      _isLoading = false;
      notifyListeners();
      return _currentUser;
    }

    // 2. Try Supabase Native Google OAuth
    if (SupabaseService.isConfigured) {
      final client = SupabaseService().client;
      if (client != null) {
        try {
          await client.auth.signInWithOAuth(
            OAuthProvider.google,
            redirectTo: kIsWeb ? null : 'io.supabase.finwise://login-callback',
          );
          _isLoading = false;
          notifyListeners();
          return _currentUser;
        } catch (e) {
          debugPrint('[AuthService] Supabase OAuth notice: $e');
          _errorMessage = e.toString();
        }
      }
    }

    // Web OAuth is handled by Supabase; the device plugin needs a client ID.
    if (!kIsWeb) {
      try {
        _usedDeviceGoogleSignIn = true;
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser != null) {
          final userId = generateUserUuid(googleUser.email);
          _currentUser = AppUser(
            id: userId,
            email: googleUser.email,
            displayName: googleUser.displayName ?? formatNameFromEmail(googleUser.email),
            photoUrl: googleUser.photoUrl,
            provider: 'google',
          );
          _isSupabaseSession = false;
          _isSessionInitialized = true;
          _isLoading = false;
          notifyListeners();
          return _currentUser;
        }
      } catch (error) {
        debugPrint('[AuthService] Device Google Sign-In notice: $error');
      }
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  /// Register new account with Google credentials
  Future<AppUser?> registerWithGoogle({
    required String email,
    required String name,
    String? password,
  }) async {
    return signUpWithEmail(email: email, password: password ?? 'FinWise2026!', name: name);
  }

  /// Send password reset link to user's email
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (SupabaseService.isConfigured) {
        final client = SupabaseService().client;
        if (client != null) {
          await client.auth.resetPasswordForEmail(
            email.trim(),
            redirectTo: kIsWeb ? null : 'io.supabase.finwise://reset-password',
          );
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      // Offline / local preview simulation
      await Future.delayed(const Duration(milliseconds: 600));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[AuthService] Password reset notice: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update password with recovery token
  Future<bool> updatePassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (SupabaseService.isConfigured) {
        final client = SupabaseService().client;
        if (client != null) {
          await client.auth.updateUser(
            UserAttributes(password: newPassword),
          );
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      await Future.delayed(const Duration(milliseconds: 600));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[AuthService] Update password notice: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update User Profile details (Name, Email, Password, Photo, etc.)
  Future<bool> updateUserProfile({
    required String newName,
    required String newEmail,
    String? currentPassword,
    String? newPassword,
    String? photoUrl,
    String? phone,
    String? occupation,
    String? currency,
    double? monthlyBudget,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanOldEmail = (_currentUser?.email ?? '').trim().toLowerCase();
      final cleanNewEmail = newEmail.trim().toLowerCase();

      // Security Check: Demo account is strictly prohibited from altering profile information
      if (cleanOldEmail == 'demo@finwise-app.xyz' ||
          cleanNewEmail == 'demo@finwise-app.xyz' ||
          _currentUser?.id == '00000000-0000-4000-8000-000000000001') {
        _errorMessage = 'On demo account, you cannot alter or delete profile info. The demo account is strictly reserved for testing input and output transactions, while profile information is strictly prohibited to edit or delete.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Password verification if changing password
      if (newPassword != null && newPassword.isNotEmpty) {
        if (_registeredAccounts.containsKey(cleanOldEmail)) {
          final account = _registeredAccounts[cleanOldEmail]!;
          if (currentPassword == null || hashPassword(currentPassword) != account.passwordHash) {
            _errorMessage = 'Current password does not match database record.';
            _isLoading = false;
            notifyListeners();
            return false;
          }
        }
      }

      final existingAcc = _registeredAccounts[cleanNewEmail] ?? _registeredAccounts[cleanOldEmail];
      final currentPassHash = (newPassword != null && newPassword.isNotEmpty)
          ? hashPassword(newPassword)
          : (existingAcc?.passwordHash ?? hashPassword('FinWise2026!'));

      if (cleanNewEmail != cleanOldEmail && _registeredAccounts.containsKey(cleanOldEmail)) {
        _registeredAccounts.remove(cleanOldEmail);
      }

      final newPhoto = photoUrl ?? _currentUser?.photoUrl ?? existingAcc?.photoUrl;
      final userId = _currentUser?.id ?? existingAcc?.id ?? generateUserUuid(cleanNewEmail);

      _registeredAccounts[cleanNewEmail] = RegisteredAccount(
        id: userId,
        email: cleanNewEmail,
        name: newName,
        passwordHash: currentPassHash,
        photoUrl: newPhoto,
        phone: phone ?? existingAcc?.phone,
        occupation: occupation ?? existingAcc?.occupation,
        currency: currency ?? existingAcc?.currency,
        monthlyBudget: monthlyBudget ?? existingAcc?.monthlyBudget,
      );

      _currentUser = AppUser(
        id: userId,
        email: cleanNewEmail,
        displayName: newName,
        photoUrl: newPhoto,
        provider: _currentUser?.provider ?? 'email',
      );

      // Sync with Supabase and DatabaseService
      try {
        await DatabaseService().updateFullUserProfile(
          userId: userId,
          displayName: newName,
          email: cleanNewEmail,
          phone: phone,
          occupation: occupation,
          avatarUrl: newPhoto,
          currency: currency ?? 'RM',
          monthlyBudget: monthlyBudget ?? 2500.00,
        );
      } catch (e) {
        debugPrint('[AuthService] Profile database sync notice: $e');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete Account & Profile permanently from Supabase & local state
  Future<bool> deleteAccount() async {
    final user = _currentUser;
    if (user == null) return false;

    final cleanEmail = user.email.toLowerCase().trim();

    // Security Check: Demo account is strictly prohibited from deletion
    if (cleanEmail == 'demo@finwise-app.xyz' ||
        user.id == '00000000-0000-4000-8000-000000000001') {
      _errorMessage = 'On demo account, you cannot alter or delete profile info. The demo account is strictly reserved for testing input and output transactions, while profile information is strictly prohibited to edit or delete.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (SupabaseService.isConfigured) {
        final client = SupabaseService().client;
        if (client != null) {
          try {
            // 1. Try secure PostgreSQL RPC function delete_user_account
            await client.rpc('delete_user_account').timeout(const Duration(seconds: 10));
          } catch (rpcErr) {
            debugPrint('[AuthService] RPC delete notice: $rpcErr. Falling back to direct RLS deletion.');
            // 2. Direct RLS table deletion
            await client.from('transactions').delete().eq('user_id', user.id).timeout(const Duration(seconds: 10));
            await client.from('savings_goals').delete().eq('user_id', user.id).timeout(const Duration(seconds: 10));
            await client.from('profiles').delete().eq('id', user.id).timeout(const Duration(seconds: 10));
          }
        }
      }

      // 3. Remove from local database service
      await DatabaseService().deleteUserRecords(user.id);

      // 4. Remove from registered accounts registry
      _registeredAccounts.remove(cleanEmail);

      // 5. Sign out and clear active session
      await signOut();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out and completely scrub active session state
  Future<void> signOut() async {
    final shouldSignOutGoogle = !kIsWeb &&
        (_usedDeviceGoogleSignIn ||
            (_isSupabaseSession && _currentUser?.provider == 'google'));
    _isSigningOut = true;

    try {
      if (SupabaseService.isConfigured) {
        try {
          final client = SupabaseService().client;
          if (client != null) {
            await client.auth.signOut().timeout(const Duration(seconds: 10));
          }
        } catch (e) {
          debugPrint('[AuthService] Supabase sign out error: $e');
        }
      }

      if (shouldSignOutGoogle) {
        try {
          await _googleSignIn.signOut().timeout(const Duration(seconds: 5));
        } catch (e) {
          debugPrint('[AuthService] Google sign out error: $e');
        }
      }
    } finally {
      _isSigningOut = false;
      _usedDeviceGoogleSignIn = false;
      _currentUser = null;
      _isSupabaseSession = false;
      _errorMessage = null;
      _isLoading = false;
      _invokeSessionResetCallbacks();
      notifyListeners();
      _emitSessionEvent(AuthSessionEvent.signedOut);
    }
  }
}

// AIO-84: Local/demo mode session handling.
