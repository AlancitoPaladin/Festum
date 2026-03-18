class ProviderNotification {
  final String title;
  final String subtitle;
  final String timeLabel;
  final bool isUnread;

  const ProviderNotification({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    this.isUnread = false,
  });

  ProviderNotification copyWith({
    String? title,
    String? subtitle,
    String? timeLabel,
    bool? isUnread,
  }) {
    return ProviderNotification(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      timeLabel: timeLabel ?? this.timeLabel,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}
