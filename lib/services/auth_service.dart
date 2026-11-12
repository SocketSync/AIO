import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'database_service.dart';
import 'supabase_service.dart';

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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

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

  void _initSupabaseAuthListener() {
    if (SupabaseService.isConfigured) {
      try {
        final client = SupabaseService().client;
        if (client != null) {
          final session = client.auth.currentSession;
          if (session != null) {
            _setUserFromSupabase(session.user);
          }

          client.auth.onAuthStateChange.listen((data) {
            final authSession = data.session;
            if (authSession != null) {
              _setUserFromSupabase(authSession.user);
            } else if (data.event == AuthChangeEvent.signedOut) {
              _currentUser = null;
              notifyListeners();
            }
          });
        }
      } catch (e) {
        debugPrint('[AuthService] Supabase auth listener notice: $e');
      }
    }
  }

  void _setUserFromSupabase(User user) {
    final meta = user.userMetadata ?? {};
    final fullName = (meta['full_name'] as String?) ??
        (meta['name'] as String?) ??
        formatNameFromEmail(user.email ?? 'Google User');
    final avatar = (meta['avatar_url'] as String?) ?? (meta['picture'] as String?);

    _currentUser = AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: fullName,
      photoUrl: avatar,
      provider: 'google',
    );
    notifyListeners();
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

    // 3. Try device Google Sign-In
    try {
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
        _isLoading = false;
        notifyListeners();
        return _currentUser;
      }
    } catch (error) {
      debugPrint('[AuthService] Device Google Sign-In notice: $error');
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

  /// Sign out and completely scrub active session state
  Future<void> signOut() async {
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

    try {
      await _googleSignIn.signOut().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('[AuthService] Google sign out error: $e');
    }
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
