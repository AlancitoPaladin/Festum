import 'package:festum/features/client/models/client_tab.dart';
import 'package:flutter/foundation.dart';

class ClientTabUiStateService extends ChangeNotifier {
  final Map<ClientTab, double> _scrollOffsets = <ClientTab, double>{};

  int _cartCount = 3;
  int _ordersCount = 2;

  double scrollOffsetFor(ClientTab tab) {
    return _scrollOffsets[tab] ?? 0;
  }

  void saveScrollOffset(ClientTab tab, double offset) {
    _scrollOffsets[tab] = offset;
  }

  int badgeFor(ClientTab tab) {
    switch (tab) {
      case ClientTab.services:
        return 0;
      case ClientTab.cart:
        return _cartCount;
      case ClientTab.orders:
        return _ordersCount;
    }
  }

  void setCartCount(int value) {
    final int next = value < 0 ? 0 : value;
    if (_cartCount == next) {
      return;
    }
    _cartCount = next;
    notifyListeners();
  }

  void setOrdersCount(int value) {
    final int next = value < 0 ? 0 : value;
    if (_ordersCount == next) {
      return;
    }
    _ordersCount = next;
    notifyListeners();
  }
}
