import 'package:festum/core/models/account_role.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationStateService extends ChangeNotifier {
  RegistrationStateService(this._prefs) {
    _hasCompletedRegistration =
        _prefs.getBool(_hasCompletedRegistrationKey) ?? false;
    _selectedRole = AccountRole.fromStorage(_prefs.getString(_roleKey));
  }

  static const String _hasCompletedRegistrationKey =
      'has_completed_registration';
  static const String _roleKey = 'selected_registration_role';

  final SharedPreferences _prefs;

  bool _hasCompletedRegistration = false;
  AccountRole? _selectedRole;

  bool get hasCompletedRegistration => _hasCompletedRegistration;
  AccountRole? get selectedRole => _selectedRole;

  Future<void> completeRegistration(AccountRole role) async {
    _hasCompletedRegistration = true;
    _selectedRole = role;
    await _prefs.setBool(_hasCompletedRegistrationKey, true);
    await _prefs.setString(_roleKey, role.storageValue);
    notifyListeners();
  }
}
