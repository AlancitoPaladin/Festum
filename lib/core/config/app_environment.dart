import 'package:flutter/foundation.dart';

class AppEnvironment {
  const AppEnvironment._();

  static const String _apiBaseUrlFromDefine =
      String.fromEnvironment('API_BASE_URL');

  // Usa loopback local para debug en iOS/simulador/desktop.
  // Para Android emulator usa: --dart-define=API_BASE_URL=http://10.0.2.2:8000
  static const String _localApiBaseUrl = 'http://127.0.0.1:8000';
  static const String _productionApiBaseUrl = 'https://api.example.com';

  static String get apiBaseUrl {
    if (_apiBaseUrlFromDefine.isNotEmpty) {
      return _apiBaseUrlFromDefine;
    }

    return kReleaseMode ? _productionApiBaseUrl : _localApiBaseUrl;
  }
}
