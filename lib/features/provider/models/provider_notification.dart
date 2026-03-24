class ProviderNotification {
  final String id;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final bool isUnread;

  const ProviderNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    this.isUnread = false,
  });

  String get timeLabel => _buildTimeLabel(createdAt);

  factory ProviderNotification.fromJson(Map<String, dynamic> json) {
    return ProviderNotification(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      createdAt: _parseDateTime(json['created_at']),
      isUnread: json['is_unread'] == true,
    );
  }

  ProviderNotification copyWith({
    String? id,
    String? title,
    String? subtitle,
    DateTime? createdAt,
    bool? isUnread,
  }) {
    return ProviderNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      createdAt: createdAt ?? this.createdAt,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}

DateTime _parseDateTime(Object? value) {
  final String rawValue = value?.toString() ?? '';
  return DateTime.tryParse(rawValue) ?? DateTime.now();
}

String _buildTimeLabel(DateTime createdAt) {
  final Duration difference = DateTime.now().difference(createdAt);

  if (difference.inMinutes < 1) {
    return 'Ahora';
  }

  if (difference.inMinutes < 60) {
    return 'Hace ${difference.inMinutes} min';
  }

  if (difference.inHours < 24) {
    return 'Hace ${difference.inHours} h';
  }

  if (difference.inDays == 1) {
    return 'Ayer';
  }

  return 'Hace ${difference.inDays} d';
}
