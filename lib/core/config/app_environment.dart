import 'package:flutter/foundation.dart';

class AppEnvironment {
  const AppEnvironment._();

  static const String _apiBaseUrlFromDefine = String.fromEnvironment(
    'API_BASE_URL',
  );

  static const String _productionApiBaseUrl = 'https://api.example.com';
  static const bool _useClientMocksFromDefine = bool.fromEnvironment(
    'USE_CLIENT_MOCKS',
    defaultValue: true,
  );

  static String get apiBaseUrl {
    if (_apiBaseUrlFromDefine.isNotEmpty) {
      return _apiBaseUrlFromDefine;
    }

    if (kReleaseMode) {
      return _productionApiBaseUrl;
    }

    // En Android emulator, 10.0.2.2 apunta al localhost de la máquina host.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    // iOS simulator y desktop pueden usar loopback directo.
    return 'http://127.0.0.1:8000';
  }

  static bool get useClientMocks => _useClientMocksFromDefine;
}
