import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStateService extends ChangeNotifier {
  AuthStateService(this._prefs) {
    _accessToken = _prefs.getString(_accessTokenKey);
  }

  static const String _accessTokenKey = 'auth_access_token';

  final SharedPreferences _prefs;
  String? _accessToken;

  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  String? get accessToken => _accessToken;

  Future<void> signIn(String accessToken) async {
    _accessToken = accessToken;
    await _prefs.setString(_accessTokenKey, accessToken);
    notifyListeners();
  }

  Future<void> signOut() async {
    _accessToken = null;
    await _prefs.remove(_accessTokenKey);
    notifyListeners();
  }
}
