import 'dart:async';

import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/features/provider/models/provider_home_response.dart';
import 'package:festum/features/provider/models/provider_notification.dart';
import 'package:festum/features/provider/models/provider_notifications_response.dart';
import 'package:festum/features/provider/repositories/provider_home_repository.dart';
import 'package:festum/features/provider/usecases/clear_provider_notifications_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_home_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_notifications_use_case.dart';
import 'package:festum/features/provider/usecases/mark_all_provider_notifications_as_read_use_case.dart';
import 'package:festum/features/provider/usecases/mark_provider_notification_as_read_use_case.dart';
import 'package:stacked/stacked.dart';

class ProviderHomeViewModel extends BaseViewModel {
  ProviderHomeViewModel(
    this._getProviderHomeUseCase,
    this._getProviderNotificationsUseCase,
    this._markProviderNotificationAsReadUseCase,
    this._markAllProviderNotificationsAsReadUseCase,
    this._clearProviderNotificationsUseCase,
    this._providerReactivityService,
  ) {
    _lastServicesRevision = _providerReactivityService.servicesRevision;
    _lastBusinessRevision = _providerReactivityService.businessRevision;
    _providerReactivityService.addListener(_handleReactivityChanged);
  }

  final GetProviderHomeUseCase _getProviderHomeUseCase;
  final GetProviderNotificationsUseCase _getProviderNotificationsUseCase;
  final MarkProviderNotificationAsReadUseCase
  _markProviderNotificationAsReadUseCase;
  final MarkAllProviderNotificationsAsReadUseCase
  _markAllProviderNotificationsAsReadUseCase;
  final ClearProviderNotificationsUseCase _clearProviderNotificationsUseCase;
  final ProviderReactivityService _providerReactivityService;

  ProviderHomeResponse? _home;
  List<ProviderNotification> _notifications = <ProviderNotification>[];
  String? _errorMessage;
  int _lastServicesRevision = 0;
  int _lastBusinessRevision = 0;
  bool _hasInitialized = false;

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
        _getProviderHomeUseCase(),
        _getProviderNotificationsUseCase(),
      ]);

      _home = results[0] as ProviderHomeResponse;
      final ProviderNotificationsResponse notificationsResponse =
          results[1] as ProviderNotificationsResponse;
      _notifications = notificationsResponse.items;
      _lastServicesRevision = _providerReactivityService.servicesRevision;
      _lastBusinessRevision = _providerReactivityService.businessRevision;
      _hasInitialized = true;
    } catch (error) {
      _errorMessage = ProviderHomeRepository.mapApiError(error);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _runNotificationAction(() async {
      await _markProviderNotificationAsReadUseCase(notificationId);
    });
  }

  Future<void> markAllAsRead() async {
    await _runNotificationAction(() async {
      await _markAllProviderNotificationsAsReadUseCase();
    });
  }

  Future<void> clearAll() async {
    await _runNotificationAction(() async {
      await _clearProviderNotificationsUseCase();
    });
  }

  Future<void> refresh() async {
    await initialize();
  }

  Future<void> _reloadNotifications() async {
    final ProviderNotificationsResponse notificationsResponse =
        await _getProviderNotificationsUseCase();
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

  @override
  void dispose() {
    _providerReactivityService.removeListener(_handleReactivityChanged);
    super.dispose();
  }

  void _handleReactivityChanged() {
    if (!_hasInitialized) {
      return;
    }

    final bool servicesChanged =
        _lastServicesRevision != _providerReactivityService.servicesRevision;
    final bool businessChanged =
        _lastBusinessRevision != _providerReactivityService.businessRevision;

    if (!servicesChanged && !businessChanged) {
      return;
    }

    _lastServicesRevision = _providerReactivityService.servicesRevision;
    _lastBusinessRevision = _providerReactivityService.businessRevision;

    if (isBusy) {
      return;
    }

    unawaited(refresh());
  }
}
