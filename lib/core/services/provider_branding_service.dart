import 'package:flutter/foundation.dart';

class ProviderBrandingService extends ChangeNotifier {
  String _businessName = '';
  String _logoUrl = '';

  String get businessName => _businessName;
  String get logoUrl => _logoUrl;
  bool get hasLogo => _logoUrl.trim().isNotEmpty;

  Future<void> sync({
    String? businessName,
    String? logoUrl,
  }) async {
    final String nextBusinessName = (businessName ?? '').trim();
    final String nextLogoUrl = (logoUrl ?? '').trim();

    if (_businessName == nextBusinessName && _logoUrl == nextLogoUrl) {
      return;
    }

    _businessName = nextBusinessName;
    _logoUrl = nextLogoUrl;
    notifyListeners();
  }

  Future<void> clear() async {
    if (_businessName.isEmpty && _logoUrl.isEmpty) {
      return;
    }

    _businessName = '';
    _logoUrl = '';
    notifyListeners();
  }
}
