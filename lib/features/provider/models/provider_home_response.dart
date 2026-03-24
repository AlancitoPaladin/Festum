class ProviderHomeResponse {
  const ProviderHomeResponse({
    required this.providerId,
    required this.displayName,
    required this.businessName,
    required this.avatarUrl,
    required this.quickStats,
    required this.featuredServices,
  });

  final String providerId;
  final String displayName;
  final String businessName;
  final String avatarUrl;
  final ProviderQuickStats quickStats;
  final List<ProviderFeaturedService> featuredServices;

  factory ProviderHomeResponse.fromJson(Map<String, dynamic> json) {
    return ProviderHomeResponse(
      providerId: (json['provider_id'] ?? '').toString(),
      displayName: (json['display_name'] ?? '').toString(),
      businessName: (json['business_name'] ?? '').toString(),
      avatarUrl: (json['avatar_url'] ?? '').toString(),
      quickStats: ProviderQuickStats.fromJson(
        Map<String, dynamic>.from(
          (json['quick_stats'] as Map<dynamic, dynamic>? ??
              <dynamic, dynamic>{}),
        ),
      ),
      featuredServices:
          ((json['featured_services'] as List<dynamic>? ?? <dynamic>[])
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (Map<dynamic, dynamic> item) =>
                    ProviderFeaturedService.fromJson(
                      Map<String, dynamic>.from(item),
                    ),
              )
              .toList()),
    );
  }
}

class ProviderQuickStats {
  const ProviderQuickStats({
    required this.reservationsThisMonth,
    required this.activeServices,
  });

  final int reservationsThisMonth;
  final int activeServices;

  factory ProviderQuickStats.fromJson(Map<String, dynamic> json) {
    return ProviderQuickStats(
      reservationsThisMonth: _toInt(json['reservations_this_month']),
      activeServices: _toInt(json['active_services']),
    );
  }
}

class ProviderFeaturedService {
  const ProviderFeaturedService({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.priceLabel,
    required this.reservations,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String category;
  final String status;
  final String priceLabel;
  final int reservations;
  final String imageUrl;

  factory ProviderFeaturedService.fromJson(Map<String, dynamic> json) {
    return ProviderFeaturedService(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      priceLabel: (json['price_label'] ?? '').toString(),
      reservations: _toInt(json['reservations']),
      imageUrl: (json['image_url'] ?? '').toString(),
    );
  }
}

int _toInt(Object? value) {
  if (value is int) {
    return value;
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}
