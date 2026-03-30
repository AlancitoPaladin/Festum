import 'dart:convert';

import 'package:festum/features/client/models/client_in_app_notification.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/models/client_order_item.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientTabUiStateService extends ChangeNotifier {
  ClientTabUiStateService(this._prefs) {
    _hydrateNotifications();
  }

  static const String _notificationsKey = 'client_in_app_notifications_v1';

  final SharedPreferences _prefs;
  final Map<ClientTab, double> _scrollOffsets = <ClientTab, double>{};
  final Map<String, ClientOrderStatus> _lastKnownOrderStatuses =
      <String, ClientOrderStatus>{};
  final List<ClientInAppNotification> _notifications =
      <ClientInAppNotification>[];

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
  List<ClientInAppNotification> get notifications =>
      List<ClientInAppNotification>.unmodifiable(_notifications);

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
    markAllNotificationsAsRead();
  }

  void markAllNotificationsAsRead() {
    if (_notifications.isEmpty && _orderNotificationsCount == 0) {
      return;
    }
    for (int index = 0; index < _notifications.length; index++) {
      final ClientInAppNotification item = _notifications[index];
      if (!item.isRead) {
        _notifications[index] = item.copyWith(isRead: true);
      }
    }
    if (_orderNotificationsCount == 0) {
      _persistNotifications();
      notifyListeners();
      return;
    }
    _orderNotificationsCount = 0;
    _persistNotifications();
    notifyListeners();
  }

  void addNotification({
    required String id,
    required String title,
    required String body,
    String? orderId,
  }) {
    final bool changed = _appendNotification(
      id: id,
      title: title,
      body: body,
      orderId: orderId,
    );
    if (!changed) {
      return;
    }
    _recomputeUnreadCounter();
    _persistNotifications();
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    final int index = _notifications.indexWhere(
      (ClientInAppNotification item) => item.id == id,
    );
    if (index < 0) {
      return;
    }
    final ClientInAppNotification current = _notifications[index];
    if (current.isRead) {
      return;
    }
    _notifications[index] = current.copyWith(isRead: true);
    _recomputeUnreadCounter();
    _persistNotifications();
    notifyListeners();
  }

  ClientInAppNotification? removeNotification(String id) {
    final int index = _notifications.indexWhere(
      (ClientInAppNotification item) => item.id == id,
    );
    if (index < 0) {
      return null;
    }
    final ClientInAppNotification removed = _notifications.removeAt(index);
    _recomputeUnreadCounter();
    _persistNotifications();
    notifyListeners();
    return removed;
  }

  void restoreNotification(ClientInAppNotification item, {int index = 0}) {
    final String normalizedId = item.id.trim();
    if (normalizedId.isEmpty) {
      return;
    }
    if (_notifications.any(
      (ClientInAppNotification notification) => notification.id == normalizedId,
    )) {
      return;
    }
    final int safeIndex = index.clamp(0, _notifications.length);
    _notifications.insert(safeIndex, item);
    _recomputeUnreadCounter();
    _persistNotifications();
    notifyListeners();
  }

  void ingestOrders(List<ClientOrderItem> orders) {
    bool changed = false;
    for (final ClientOrderItem order in orders) {
      final ClientOrderStatus? previous = _lastKnownOrderStatuses[order.id];
      final ClientOrderStatus current = order.status;
      if (previous == ClientOrderStatus.pendingProviderApproval &&
          (current == ClientOrderStatus.confirmed ||
              current == ClientOrderStatus.pendingPayment)) {
        changed =
            _appendNotification(
              id: 'order_accepted:${order.id}:${current.apiValue}',
              title: 'Orden aceptada',
              body: 'Tu orden #${order.id} fue aceptada por el proveedor.',
              orderId: order.id,
            ) ||
            changed;
      }
      if (previous == ClientOrderStatus.pendingProviderApproval &&
          current == ClientOrderStatus.cancelled) {
        changed =
            _appendNotification(
              id: 'order_rejected:${order.id}:${current.apiValue}',
              title: 'Solicitud rechazada',
              body: 'La orden #${order.id} fue rechazada por el proveedor.',
              orderId: order.id,
            ) ||
            changed;
      }
      if (previous == ClientOrderStatus.pendingPayment &&
          current == ClientOrderStatus.cancelled) {
        changed =
            _appendNotification(
              id: 'order_cancelled:${order.id}:${current.apiValue}',
              title: 'Orden cancelada',
              body: 'La orden #${order.id} fue cancelada.',
              orderId: order.id,
            ) ||
            changed;
      }
      _lastKnownOrderStatuses[order.id] = current;
    }

    final Set<String> incomingIds = orders
        .map((ClientOrderItem order) => order.id)
        .toSet();
    _lastKnownOrderStatuses.removeWhere(
      (String orderId, ClientOrderStatus _) => !incomingIds.contains(orderId),
    );

    if (!changed) {
      return;
    }
    _recomputeUnreadCounter();
    _persistNotifications();
    notifyListeners();
  }

  void _recomputeUnreadCounter() {
    _orderNotificationsCount = _notifications
        .where((ClientInAppNotification item) => !item.isRead)
        .length;
  }

  bool _appendNotification({
    required String id,
    required String title,
    required String body,
    String? orderId,
  }) {
    final String normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      return false;
    }
    if (_notifications.any(
      (ClientInAppNotification item) => item.id == normalizedId,
    )) {
      return false;
    }
    _notifications.insert(
      0,
      ClientInAppNotification(
        id: normalizedId,
        title: title,
        body: body,
        orderId: orderId,
        createdAt: DateTime.now(),
      ),
    );
    if (_notifications.length > 100) {
      _notifications.removeRange(100, _notifications.length);
    }
    return true;
  }

  void _hydrateNotifications() {
    final String raw = _prefs.getString(_notificationsKey) ?? '';
    if (raw.trim().isEmpty) {
      return;
    }
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) {
        return;
      }
      _notifications
        ..clear()
        ..addAll(
          decoded
              .whereType<Map>()
              .map(
                (Map<dynamic, dynamic> item) =>
                    ClientInAppNotification.fromJson(
                      Map<String, dynamic>.from(item),
                    ),
              )
              .where(
                (ClientInAppNotification item) => item.id.trim().isNotEmpty,
              )
              .take(100),
        );
      _recomputeUnreadCounter();
    } catch (_) {
      // Keep the app resilient even with corrupted local data.
    }
  }

  void _persistNotifications() {
    final List<Map<String, dynamic>> payload = _notifications
        .take(100)
        .map((ClientInAppNotification item) => item.toJson())
        .toList();
    _prefs.setString(_notificationsKey, jsonEncode(payload));
  }
}
