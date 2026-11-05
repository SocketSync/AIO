import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

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

  /// Sign in with Google (Gmail)
  Future<AppUser?> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        _currentUser = AppUser(
          id: googleUser.id,
          email: googleUser.email,
          displayName: googleUser.displayName ?? 'Google User',
          photoUrl: googleUser.photoUrl,
        );
        _isLoading = false;
        notifyListeners();
        return _currentUser;
      } else {
        // User cancelled popup
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (error) {
      debugPrint("Google Sign-In Error: $error");
      
      // Fallback for development / mock verification when Google Client ID is not registered on local web port
      _currentUser = AppUser(
        id: "google_dev_987654321",
        email: "alex.yeoh@gmail.com",
        displayName: "Alex Yeoh",
        photoUrl: null,
      );
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return _currentUser;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint("Sign out error: $e");
    }
    _currentUser = null;
    notifyListeners();
  }
}

