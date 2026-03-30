import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:festum/app/router/app_router.dart';
import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/models/account_role.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:festum/core/services/auth_state_service.dart';
import 'package:festum/features/client/services/client_tab_ui_state_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Keep background handler best-effort.
  }
}

class PushNotificationsService {
  PushNotificationsService(
    this._apiClient,
    this._authStateService,
    this._appRouter,
    this._clientTabUiStateService,
  );

  final ApiClient _apiClient;
  final AuthStateService _authStateService;
  final AppRouter _appRouter;
  final ClientTabUiStateService _clientTabUiStateService;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final LinkedHashSet<String> _processedMessageKeys = LinkedHashSet<String>();

  bool _initialized = false;
  bool _firebaseReady = false;
  bool _localNotificationsReady = false;
  bool _isSyncingToken = false;
  String? _deviceToken;
  String? _registeredToken;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    _authStateService.addListener(_handleAuthStateChanged);

    try {
      await Firebase.initializeApp();
      _firebaseReady = true;
    } catch (error) {
      debugPrint('Push init skipped (Firebase not configured): $error');
      return;
    }

    await _initializeLocalNotifications();
    await _requestPermissions();
    await _configureMessageHandlers();
    await _syncTokenWithBackend(force: true);
  }

  Future<void> unregisterCurrentDeviceToken() async {
    if (!_firebaseReady || !_authStateService.isAuthenticated) {
      return;
    }

    final String? token =
        _deviceToken ?? await FirebaseMessaging.instance.getToken();
    if (token == null || token.trim().isEmpty) {
      return;
    }

    try {
      await _apiClient.unregisterDeviceToken(token: token);
      _registeredToken = null;
    } catch (_) {
      // Logout flow should continue even if this fails.
    }
  }

  void _handleAuthStateChanged() {
    if (!_authStateService.isAuthenticated) {
      _registeredToken = null;
      return;
    }
    unawaited(_syncTokenWithBackend(force: true));
  }

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsReady) {
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
    _localNotificationsReady = true;
  }

  Future<void> _requestPermissions() async {
    final NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Push notifications permission denied.');
    }
  }

  Future<void> _configureMessageHandlers() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      _deviceToken = token;
      unawaited(_registerDeviceToken(token, force: true));
    });

    final RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpened(initialMessage);
    }
  }

  Future<void> _syncTokenWithBackend({bool force = false}) async {
    if (!_firebaseReady || !_authStateService.isAuthenticated) {
      return;
    }
    final String? token = await FirebaseMessaging.instance.getToken();
    _deviceToken = token;
    if (token == null || token.trim().isEmpty) {
      return;
    }
    await _registerDeviceToken(token, force: force);
  }

  Future<void> _registerDeviceToken(String token, {bool force = false}) async {
    if (!_authStateService.isAuthenticated) {
      return;
    }
    if (!force && _registeredToken == token) {
      return;
    }
    if (_isSyncingToken) {
      return;
    }
    final String platform = _resolvePlatform();
    if (platform.isEmpty) {
      return;
    }

    _isSyncingToken = true;
    try {
      await _apiClient.registerDeviceToken(token: token, platform: platform);
      _registeredToken = token;
    } catch (_) {
      // Keep notification setup non-blocking for app usage.
    } finally {
      _isSyncingToken = false;
    }
  }

  String _resolvePlatform() {
    if (kIsWeb) {
      return '';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return '';
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (!_shouldHandleMessage(message)) {
      return;
    }
    _recordNotificationFromData(
      data: message.data,
      fallbackMessageId: message.messageId,
    );
    await _showForegroundNotification(message);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    if (!_localNotificationsReady) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'festum_domain_events',
          'Festum updates',
          channelDescription: 'Domain updates for orders and reservations',
          importance: Importance.high,
          priority: Priority.high,
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final String title =
        message.notification?.title ??
        message.data['title']?.toString() ??
        'Actualización de Festum';
    final String body =
        message.notification?.body ??
        message.data['body']?.toString() ??
        'Tienes una actualización nueva.';

    await _localNotifications.show(
      _notificationIdFor(message),
      title,
      body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  int _notificationIdFor(RemoteMessage message) {
    final String key =
        message.messageId ??
        message.data['request_id']?.toString() ??
        message.data['order_id']?.toString() ??
        DateTime.now().microsecondsSinceEpoch.toString();
    return key.hashCode & 0x7fffffff;
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final String payload = response.payload ?? '';
    if (payload.trim().isEmpty) {
      return;
    }
    try {
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        jsonDecode(payload) as Map,
      );
      _navigateFromData(data);
    } catch (_) {
      // Keep tap handling safe.
    }
  }

  void _handleMessageOpened(RemoteMessage message) {
    if (!_shouldHandleMessage(message)) {
      return;
    }
    _recordNotificationFromData(
      data: message.data,
      fallbackMessageId: message.messageId,
    );
    _navigateFromData(message.data);
  }

  bool _shouldHandleMessage(RemoteMessage message) {
    final String key =
        message.messageId ??
        '${message.data['type'] ?? ''}:${message.data['order_id'] ?? ''}:${message.data['request_id'] ?? ''}:${message.sentTime?.millisecondsSinceEpoch ?? 0}';
    if (_processedMessageKeys.contains(key)) {
      return false;
    }
    _processedMessageKeys.add(key);
    while (_processedMessageKeys.length > 200) {
      _processedMessageKeys.remove(_processedMessageKeys.first);
    }
    return true;
  }

  void _navigateFromData(Map<String, dynamic> data) {
    if (!_authStateService.isAuthenticated) {
      return;
    }
    final String target = (data['target_screen'] ?? '').toString().trim();
    if (target.isEmpty) {
      return;
    }

    final AccountRole? role = _authStateService.role;
    if (target == 'client_orders' && role == AccountRole.client) {
      _appRouter.router.go(AppRoutes.clientOrders);
      return;
    }
    if (target == 'provider_reservations' && role == AccountRole.provider) {
      _appRouter.router.go(AppRoutes.providerReservations);
    }
  }

  void _recordNotificationFromData({
    required Map<String, dynamic> data,
    String? fallbackMessageId,
  }) {
    final String type = (data['type'] ?? '').toString().trim();
    if (type.isEmpty) {
      return;
    }

    final String orderId = (data['order_id'] ?? '').toString().trim();
    final String requestId = (data['request_id'] ?? '').toString().trim();
    final String id =
        '$type:${orderId.isEmpty ? requestId : orderId}:${fallbackMessageId ?? ''}';

    String title = 'Actualización';
    String body = 'Tienes una notificación nueva.';

    if (type == 'order_accepted') {
      title = 'Orden aceptada';
      body = orderId.isEmpty
          ? 'Tu orden fue aceptada por el proveedor.'
          : 'Tu orden #$orderId fue aceptada por el proveedor.';
    } else if (type == 'order_rejected') {
      title = 'Solicitud rechazada';
      body = orderId.isEmpty
          ? 'Tu solicitud fue rechazada por el proveedor.'
          : 'Tu orden #$orderId fue rechazada por el proveedor.';
    } else if (type == 'reservation_updated') {
      title = 'Reserva actualizada';
      body = orderId.isEmpty
          ? 'Hubo un cambio en tu reserva.'
          : 'Se actualizó la reserva de la orden #$orderId.';
    }

    _clientTabUiStateService.addNotification(
      id: id,
      title: title,
      body: body,
      orderId: orderId.isEmpty ? null : orderId,
    );
  }
}
