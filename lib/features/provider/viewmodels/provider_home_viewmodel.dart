import 'package:festum/features/provider/models/provider_home_response.dart';
import 'package:festum/features/provider/models/provider_notification.dart';
import 'package:festum/features/provider/models/provider_notifications_response.dart';
import 'package:festum/features/provider/repositories/provider_home_repository.dart';
import 'package:stacked/stacked.dart';

class ProviderHomeViewModel extends BaseViewModel {
  ProviderHomeViewModel(this._repository);

  final ProviderHomeRepository _repository;

  ProviderHomeResponse? _home;
  List<ProviderNotification> _notifications = <ProviderNotification>[];
  String? _errorMessage;

  ProviderHomeResponse? get home => _home;
  List<ProviderNotification> get notifications =>
      List<ProviderNotification>.unmodifiable(_notifications);
  int get unreadCount =>
      _notifications.where((ProviderNotification item) => item.isUnread).length;
  String? get errorMessage => _errorMessage;
  bool get hasContent => _home != null;

  Future<void> initialize() async {
    if (isBusy) {
      return;
    }

    setBusy(true);
    _errorMessage = null;

    try {
      final List<Object> results = await Future.wait<Object>(<Future<Object>>[
        _repository.fetchHome(),
        _repository.fetchNotifications(),
      ]);

      _home = results[0] as ProviderHomeResponse;
      final ProviderNotificationsResponse notificationsResponse =
          results[1] as ProviderNotificationsResponse;
      _notifications = notificationsResponse.items;
    } catch (error) {
      _errorMessage = ProviderHomeRepository.mapApiError(error);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _runNotificationAction(() async {
      await _repository.markAsRead(notificationId);
    });
  }

  Future<void> markAllAsRead() async {
    await _runNotificationAction(_repository.markAllAsRead);
  }

  Future<void> clearAll() async {
    await _runNotificationAction(_repository.clearAll);
  }

  Future<void> refresh() async {
    await initialize();
  }

  Future<void> _reloadNotifications() async {
    final ProviderNotificationsResponse notificationsResponse =
        await _repository.fetchNotifications();
    _notifications = notificationsResponse.items;
    notifyListeners();
  }

  Future<void> _runNotificationAction(Future<void> Function() action) async {
    try {
      await action();
      await _reloadNotifications();
    } catch (_) {
      // Keep the current UI state if a notification action fails.
    }
  }
}
