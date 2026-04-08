import 'package:festum/features/provider/models/provider_notification.dart';
import 'package:stacked/stacked.dart';

class ProviderNotificationsViewModel extends BaseViewModel {
  final List<ProviderNotification> _notifications = <ProviderNotification>[
    ProviderNotification(
      id: 'mock-notification-1',
      title: 'Nueva reserva recibida',
      subtitle: 'Mariana López solicitó información para el 20 de agosto.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      isUnread: true,
    ),
    ProviderNotification(
      id: 'mock-notification-2',
      title: 'Recordatorio de evento',
      subtitle: 'Tienes un servicio programado para mañana a las 18:00.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isUnread: true,
    ),
    ProviderNotification(
      id: 'mock-notification-3',
      title: 'Servicio actualizado',
      subtitle: 'Los cambios en DJ Sonido Fiesta se guardaron correctamente.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ProviderNotification(
      id: 'mock-notification-4',
      title: 'Pago confirmado',
      subtitle: 'Se confirmó el anticipo de una reserva reciente.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  List<ProviderNotification> get notifications =>
      List<ProviderNotification>.unmodifiable(_notifications);

  int get unreadCount =>
      _notifications.where((ProviderNotification item) => item.isUnread).length;

  void markAsRead(int index) {
    if (index < 0 || index >= _notifications.length) {
      return;
    }

    final ProviderNotification current = _notifications[index];
    if (!current.isUnread) {
      return;
    }

    _notifications[index] = current.copyWith(isUnread: false);
    notifyListeners();
  }

  void markAllAsRead() {
    bool hasChanges = false;

    for (int index = 0; index < _notifications.length; index++) {
      final ProviderNotification item = _notifications[index];
      if (!item.isUnread) {
        continue;
      }

      _notifications[index] = item.copyWith(isUnread: false);
      hasChanges = true;
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  void clearAll() {
    if (_notifications.isEmpty) {
      return;
    }

    _notifications.clear();
    notifyListeners();
  }
}
