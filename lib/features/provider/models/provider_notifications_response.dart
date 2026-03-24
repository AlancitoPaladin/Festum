import 'package:festum/features/provider/models/provider_notification.dart';

class ProviderNotificationsResponse {
  const ProviderNotificationsResponse({
    required this.items,
    required this.unreadCount,
  });

  final List<ProviderNotification> items;
  final int unreadCount;

  factory ProviderNotificationsResponse.fromJson(Map<String, dynamic> json) {
    return ProviderNotificationsResponse(
      items:
          ((json['items'] as List<dynamic>? ?? <dynamic>[])
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (Map<dynamic, dynamic> item) => ProviderNotification.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()),
      unreadCount: _toInt(json['unread_count']),
    );
  }
}

int _toInt(Object? value) {
  if (value is int) {
    return value;
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}
