import 'package:festum/core/models/account_role.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStateService extends ChangeNotifier {
  AuthStateService(this._prefs) {
    _accessToken = _prefs.getString(_accessTokenKey);
    _role = AccountRole.fromStorage(_prefs.getString(_roleKey));
    _displayName = _prefs.getString(_displayNameKey);
  }

  static const String _accessTokenKey = 'auth_access_token';
  static const String _roleKey = 'auth_role';
  static const String _displayNameKey = 'auth_display_name';

  final SharedPreferences _prefs;
  String? _accessToken;
  AccountRole? _role;
  String? _displayName;

  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  String? get accessToken => _accessToken;
  AccountRole? get role => _role;
  String? get displayName => _displayName;

  Future<void> signIn({
    required String accessToken,
    required AccountRole role,
    String? displayName,
  }) async {
    _accessToken = accessToken;
    _role = role;
    _displayName = displayName?.trim().isEmpty ?? true ? null : displayName;
    await _prefs.setString(_accessTokenKey, accessToken);
    await _prefs.setString(_roleKey, role.storageValue);
    if (_displayName == null) {
      await _prefs.remove(_displayNameKey);
    } else {
      await _prefs.setString(_displayNameKey, _displayName!);
    }
    notifyListeners();
  }

  Future<void> syncRole(AccountRole role) async {
    if (_role == role) {
      return;
    }

    _role = role;
    await _prefs.setString(_roleKey, role.storageValue);
    notifyListeners();
  }

  Future<void> signOut() async {
    _accessToken = null;
    _role = null;
    _displayName = null;
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_roleKey);
    await _prefs.remove(_displayNameKey);
    notifyListeners();
  }
}
