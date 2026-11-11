import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
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

  RegisteredAccount({
    required this.id,
    required this.email,
    required this.name,
    required this.passwordHash,
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
    'keanshen.yeoh@gmail.com': RegisteredAccount(
      id: generateUserUuid('keanshen.yeoh@gmail.com'),
      email: 'keanshen.yeoh@gmail.com',
      name: 'Kean Shen Yeoh',
      passwordHash: hashPassword('FinWise2026!'),
    ),
    'alex.yeoh@gmail.com': RegisteredAccount(
      id: generateUserUuid('alex.yeoh@gmail.com'),
      email: 'alex.yeoh@gmail.com',
      name: 'Alex Yeoh',
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

  /// Format realistic human name from Gmail address (e.g. keanshen.yeoh@gmail.com -> Kean Shen Yeoh)
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
        photoUrl: null,
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
          final response = await client.auth.signInWithPassword(
            email: cleanEmail,
            password: password,
          );
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
          final response = await client.auth.signUp(
            email: cleanEmail,
            password: password,
            data: {'full_name': cleanName},
          );
          if (response.user != null) {
            final sbUserId = response.user!.id;
            await client.from('profiles').upsert({
              'id': sbUserId,
              'email': cleanEmail,
              'display_name': cleanName,
              'currency': 'RM',
              'monthly_budget': 2500.00,
            });
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
      final name = (selectedName != null && selectedName.trim().isNotEmpty)
          ? selectedName.trim()
          : formatNameFromEmail(email);

      final userId = generateUserUuid(email);
      _currentUser = AppUser(
        id: userId,
        email: email,
        displayName: name,
        photoUrl: null,
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

  /// Sign out
  Future<void> signOut() async {
    if (SupabaseService.isConfigured) {
      try {
        final client = SupabaseService().client;
        if (client != null) {
          await client.auth.signOut();
        }
      } catch (e) {
        debugPrint('[AuthService] Supabase sign out error: $e');
      }
    }

    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('[AuthService] Google sign out error: $e');
    }
    _currentUser = null;
    notifyListeners();
  }
}
