class ClientInAppNotification {
  const ClientInAppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.orderId,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? orderId;
  final bool isRead;

  factory ClientInAppNotification.fromJson(Map<String, dynamic> json) {
    return ClientInAppNotification(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      orderId: (json['order_id'] ?? '').toString().trim().isEmpty
          ? null
          : (json['order_id'] ?? '').toString(),
      isRead: json['is_read'] == true,
    );
  }

  ClientInAppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    String? orderId,
    bool? isRead,
  }) {
    return ClientInAppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      orderId: orderId ?? this.orderId,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      'order_id': orderId,
      'is_read': isRead,
    };
  }
}
