import 'package:festum/features/provider/models/provider_notification.dart';
import 'package:stacked/stacked.dart';

class ProviderNotificationsViewModel extends BaseViewModel {
  final List<ProviderNotification> _notifications = <ProviderNotification>[
    const ProviderNotification(
      title: 'Nueva reserva recibida',
      subtitle: 'Mariana Lopez solicito informacion para el 20 de agosto.',
      timeLabel: 'Hace 5 min',
      isUnread: true,
    ),
    const ProviderNotification(
      title: 'Recordatorio de evento',
      subtitle: 'Tienes un servicio programado para manana a las 18:00.',
      timeLabel: 'Hace 1 hora',
      isUnread: true,
    ),
    const ProviderNotification(
      title: 'Servicio actualizado',
      subtitle: 'Los cambios en DJ Sonido Fiesta se guardaron correctamente.',
      timeLabel: 'Ayer',
    ),
    const ProviderNotification(
      title: 'Pago confirmado',
      subtitle: 'Se confirmo el anticipo de una reserva reciente.',
      timeLabel: 'Hace 2 dias',
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
