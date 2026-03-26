import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/models/client_order_item.dart';
import 'package:flutter/foundation.dart';

class ClientTabUiStateService extends ChangeNotifier {
  final Map<ClientTab, double> _scrollOffsets = <ClientTab, double>{};
  final Map<String, ClientOrderStatus> _lastKnownOrderStatuses =
      <String, ClientOrderStatus>{};

  int _cartCount = 0;
  int _ordersCount = 0;
  int _orderNotificationsCount = 0;

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

  int get orderNotificationsCount => _orderNotificationsCount;

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

  void clearOrderNotifications() {
    if (_orderNotificationsCount == 0) {
      return;
    }
    _orderNotificationsCount = 0;
    notifyListeners();
  }

  void ingestOrders(List<ClientOrderItem> orders) {
    int acceptedTransitions = 0;

    for (final ClientOrderItem order in orders) {
      final ClientOrderStatus? previous = _lastKnownOrderStatuses[order.id];
      final ClientOrderStatus current = order.status;
      if (previous == ClientOrderStatus.pendingProviderApproval &&
          (current == ClientOrderStatus.confirmed ||
              current == ClientOrderStatus.pendingPayment)) {
        acceptedTransitions += 1;
      }
      _lastKnownOrderStatuses[order.id] = current;
    }

    final Set<String> incomingIds = orders
        .map((ClientOrderItem order) => order.id)
        .toSet();
    _lastKnownOrderStatuses.removeWhere(
      (String orderId, ClientOrderStatus _) => !incomingIds.contains(orderId),
    );

    if (acceptedTransitions <= 0) {
      return;
    }
    _orderNotificationsCount += acceptedTransitions;
    notifyListeners();
  }
}
