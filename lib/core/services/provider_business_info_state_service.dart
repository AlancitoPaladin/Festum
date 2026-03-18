import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderBusinessInfoStateService extends ChangeNotifier {
  ProviderBusinessInfoStateService(this._prefs) {
    _hasCompletedBusinessInfo =
        _prefs.getBool(_hasCompletedBusinessInfoKey) ?? false;
  }

  static const String _hasCompletedBusinessInfoKey =
      'provider_business_info_completed';

  final SharedPreferences _prefs;

  bool _hasCompletedBusinessInfo = false;

  bool get hasCompletedBusinessInfo => _hasCompletedBusinessInfo;
  bool get requiresBusinessInfo => !_hasCompletedBusinessInfo;

  Future<void> completeBusinessInfo() async {
    if (_hasCompletedBusinessInfo) {
      return;
    }

    _hasCompletedBusinessInfo = true;
    await _prefs.setBool(_hasCompletedBusinessInfoKey, true);
    notifyListeners();
  }

  Future<void> resetBusinessInfoProgress() async {
    _hasCompletedBusinessInfo = false;
    await _prefs.setBool(_hasCompletedBusinessInfoKey, false);
    notifyListeners();
  }
}
