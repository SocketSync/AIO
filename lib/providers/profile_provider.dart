import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/supabase_service.dart';

class ProfileProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  String _displayName = '';
  String _username = '';
  String _email = '';
  String _bio = '';
  String _phone = '';
  String _currency = 'RM';
  double _monthlyBudget = 2500;
  String _themePreference = 'system';
  bool _aiInsightsEnabled = true;
  bool _overspendingAlertsEnabled = true;
  String? _avatarUrl;
  Uint8List? _avatarBytes;
  String? _avatarFileName;
  Map<String, dynamic> _baseline = {};
  AuthService? _sessionAuth;
  late final VoidCallback _sessionResetCallback = clear;
  int _loadEpoch = 0;
  bool _disposed = false;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get displayName => _displayName;
  String get username => _username;
  String get email => _email;
  String get bio => _bio;
  String get phone => _phone;
  String get currency => _currency;
  double get monthlyBudget => _monthlyBudget;
  String get themePreference => _themePreference;
  bool get aiInsightsEnabled => _aiInsightsEnabled;
  bool get overspendingAlertsEnabled => _overspendingAlertsEnabled;
  String? get avatarUrl => _avatarUrl;
  Uint8List? get avatarBytes => _avatarBytes;

  bool get isDirty {
    if (!_hasLoaded) return false;
    final current = _snapshot();
    return current.entries.any((entry) => _baseline[entry.key] != entry.value);
  }

  Map<String, dynamic> _snapshot() => {
        'displayName': _displayName,
        'username': _username,
        'bio': _bio,
        'phone': _phone,
        'currency': _currency,
        'monthlyBudget': _monthlyBudget,
        'themePreference': _themePreference,
        'aiInsightsEnabled': _aiInsightsEnabled,
        'overspendingAlertsEnabled': _overspendingAlertsEnabled,
        'avatarUrl': _avatarUrl,
        'avatarChanged': _avatarBytes != null,
      };

  Future<void> load(AuthService auth) async {
    final user = auth.currentUser;
    if (user == null) return;
    _sessionAuth ??= auth;
    auth.registerSessionResetCallback(_sessionResetCallback);
    final loadEpoch = ++_loadEpoch;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await DatabaseService().getUserProfile(
        userId: user.id,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
      );
      final preferences = await SharedPreferences.getInstance();
      if (_disposed ||
          loadEpoch != _loadEpoch ||
          auth.currentUser?.id != user.id) {
        return;
      }
      _displayName = profile.displayName;
      _username = profile.username.isNotEmpty
          ? profile.username
          : user.email
              .split('@')
              .first
              .replaceAll(RegExp(r'[^A-Za-z0-9_]'), '');
      _email = profile.email;
      _bio = profile.bio.isNotEmpty ? profile.bio : (profile.occupation ?? '');
      _phone = profile.phone ?? '';
      _currency = profile.currency;
      _monthlyBudget = profile.monthlyBudget;
      _themePreference = preferences.getString('profile_theme_preference') ??
          profile.themePreference;
      _aiInsightsEnabled = preferences.getBool('profile_ai_insights') ??
          profile.aiInsightsEnabled;
      _overspendingAlertsEnabled =
          preferences.getBool('profile_overspending_alerts') ??
              profile.overspendingAlertsEnabled;
      _avatarUrl = profile.avatarUrl;
      _avatarBytes = null;
      _avatarFileName = null;
      _baseline = _snapshot();
      _hasLoaded = true;
    } catch (e) {
      _errorMessage = 'Could not load your profile. Please try again.';
      debugPrint('[ProfileProvider] load error: $e');
    } finally {
      if (!_disposed && loadEpoch == _loadEpoch) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void setDisplayName(String value) {
    _displayName = value;
    notifyListeners();
  }

  void setUsername(String value) {
    _username = value.trim();
    notifyListeners();
  }

  void setBio(String value) {
    _bio = value;
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void setCurrency(String value) {
    _currency = value;
    notifyListeners();
  }

  void setMonthlyBudget(double value) {
    _monthlyBudget = value;
    notifyListeners();
  }

  void setThemePreference(String value) {
    _themePreference = value;
    notifyListeners();
  }

  void setAiInsightsEnabled(bool value) {
    _aiInsightsEnabled = value;
    notifyListeners();
  }

  void setOverspendingAlertsEnabled(bool value) {
    _overspendingAlertsEnabled = value;
    notifyListeners();
  }

  String? validate() {
    if (_displayName.trim().isEmpty) return 'Display name is required.';
    if (!RegExp(r'^[A-Za-z0-9_]{3,30}$').hasMatch(_username)) {
      return 'Username must be 3-30 characters using letters, numbers, or underscores.';
    }
    if (_bio.length > 160) return 'Bio must be 160 characters or fewer.';
    return null;
  }

  Future<String?> pickAvatar() async {
    final operationEpoch = _loadEpoch;
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (file == null) return null;
      final length = await file.length();
      if (_disposed || operationEpoch != _loadEpoch) return null;
      if (length > 5 * 1024 * 1024) {
        return 'Avatar must be 5 MB or smaller.';
      }
      final mime = file.mimeType?.toLowerCase() ?? '';
      final name = file.name.toLowerCase();
      if (!mime.startsWith('image/') &&
          !name.endsWith('.jpg') &&
          !name.endsWith('.jpeg') &&
          !name.endsWith('.png') &&
          !name.endsWith('.webp')) {
        return 'Choose a JPG, PNG, or WebP image.';
      }
      final avatarBytes = await file.readAsBytes();
      if (_disposed || operationEpoch != _loadEpoch) return null;
      _avatarBytes = avatarBytes;
      _avatarFileName = file.name;
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('[ProfileProvider] avatar pick error: $e');
      return 'Could not open that image.';
    }
  }

  Future<bool> save(AuthService auth) async {
    final user = auth.currentUser;
    if (user == null) return false;
    final validationError = validate();
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    final operationEpoch = _loadEpoch;
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      var photoUrl = _avatarUrl;
      if (_avatarBytes != null) {
        photoUrl = await _uploadAvatar(user.id) ??
            'data:image/png;base64,${base64Encode(_avatarBytes!)}';
      }
      if (_disposed ||
          operationEpoch != _loadEpoch ||
          auth.currentUser?.id != user.id) {
        return false;
      }

      final success = await auth.updateUserProfile(
        newName: _displayName.trim(),
        newEmail: _email,
        photoUrl: photoUrl,
        phone: _phone.trim(),
        occupation: _bio.trim(),
        currency: _currency,
        monthlyBudget: _monthlyBudget,
        username: _username,
        bio: _bio.trim(),
        themePreference: _themePreference,
        aiInsightsEnabled: _aiInsightsEnabled,
        overspendingAlertsEnabled: _overspendingAlertsEnabled,
      );
      if (!success) {
        _errorMessage = auth.errorMessage ?? 'Failed to save profile.';
        return false;
      }
      if (_disposed ||
          operationEpoch != _loadEpoch ||
          auth.currentUser?.id != user.id) {
        return false;
      }

      final preferences = await SharedPreferences.getInstance();
      if (_disposed ||
          operationEpoch != _loadEpoch ||
          auth.currentUser?.id != user.id) {
        return false;
      }
      await preferences.setString('profile_theme_preference', _themePreference);
      if (_disposed ||
          operationEpoch != _loadEpoch ||
          auth.currentUser?.id != user.id) {
        return false;
      }
      await preferences.setBool('profile_ai_insights', _aiInsightsEnabled);
      if (_disposed ||
          operationEpoch != _loadEpoch ||
          auth.currentUser?.id != user.id) {
        return false;
      }
      await preferences.setBool(
          'profile_overspending_alerts', _overspendingAlertsEnabled);
      _avatarUrl = photoUrl;
      _avatarBytes = null;
      _avatarFileName = null;
      _baseline = _snapshot();
      return true;
    } catch (e) {
      if (!_disposed &&
          operationEpoch == _loadEpoch &&
          auth.currentUser?.id == user.id) {
        _errorMessage = 'Failed to save profile. Please try again.';
      }
      debugPrint('[ProfileProvider] save error: $e');
      return false;
    } finally {
      if (!_disposed && operationEpoch == _loadEpoch) {
        _isSaving = false;
        notifyListeners();
      }
    }
  }

  Future<String?> _uploadAvatar(String userId) async {
    if (!SupabaseService.isConfigured) return null;
    final client = SupabaseService().client;
    if (client == null || _avatarBytes == null) return null;
    final parts = _avatarFileName?.split('.') ?? const <String>[];
    final extension = parts.length > 1 ? parts.last.toLowerCase() : 'jpg';
    final path =
        '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';
    await client.storage.from('avatars').uploadBinary(
          path,
          _avatarBytes!,
          fileOptions: const FileOptions(upsert: true),
        );
    return client.storage.from('avatars').getPublicUrl(path);
  }

  Future<void> reset() async {
    _displayName = _baseline['displayName'] as String;
    _username = _baseline['username'] as String;
    _bio = _baseline['bio'] as String;
    _phone = _baseline['phone'] as String;
    _currency = _baseline['currency'] as String;
    _monthlyBudget = _baseline['monthlyBudget'] as double;
    _themePreference = _baseline['themePreference'] as String;
    _aiInsightsEnabled = _baseline['aiInsightsEnabled'] as bool;
    _overspendingAlertsEnabled = _baseline['overspendingAlertsEnabled'] as bool;
    _avatarUrl = _baseline['avatarUrl'] as String?;
    _avatarBytes = null;
    _avatarFileName = null;
    notifyListeners();
  }

  void clear() {
    _loadEpoch++;
    _isLoading = false;
    _isSaving = false;
    _hasLoaded = false;
    _errorMessage = null;
    _displayName = '';
    _username = '';
    _email = '';
    _bio = '';
    _phone = '';
    _currency = 'RM';
    _monthlyBudget = 2500;
    _themePreference = 'system';
    _aiInsightsEnabled = true;
    _overspendingAlertsEnabled = true;
    _avatarUrl = null;
    _avatarBytes = null;
    _avatarFileName = null;
    _baseline = {};
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _sessionAuth?.unregisterSessionResetCallback(_sessionResetCallback);
    super.dispose();
  }
}
