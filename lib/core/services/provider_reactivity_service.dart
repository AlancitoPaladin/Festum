import 'package:flutter/foundation.dart';

class ProviderReactivityService extends ChangeNotifier {
  int _servicesRevision = 0;
  int _productsRevision = 0;
  int _businessRevision = 0;

  int get servicesRevision => _servicesRevision;
  int get productsRevision => _productsRevision;
  int get businessRevision => _businessRevision;

  Future<void> notifyServicesChanged() async {
    _servicesRevision++;
    notifyListeners();
  }

  Future<void> notifyProductsChanged() async {
    _productsRevision++;
    notifyListeners();
  }

  Future<void> notifyBusinessChanged() async {
    _businessRevision++;
    notifyListeners();
  }

  Future<void> clear() async {
    if (_servicesRevision == 0 &&
        _productsRevision == 0 &&
        _businessRevision == 0) {
      return;
    }

    _servicesRevision = 0;
    _productsRevision = 0;
    _businessRevision = 0;
    notifyListeners();
  }
}
