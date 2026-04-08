import 'package:festum/core/network/image_json_resolver.dart';

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
      avatarUrl: resolveImageUrlForUseCaseFromJson(
        json,
        useCase: ResolvedImageUseCase.list,
        directKeys: const <String>['avatar_url', 'image_url', 'url'],
        objectKeys: const <String>['avatar', 'image'],
        listKeys: const <String>['images'],
      ),
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

  ProviderHomeResponse copyWith({
    String? providerId,
    String? displayName,
    String? businessName,
    String? avatarUrl,
    ProviderQuickStats? quickStats,
    List<ProviderFeaturedService>? featuredServices,
  }) {
    return ProviderHomeResponse(
      providerId: providerId ?? this.providerId,
      displayName: displayName ?? this.displayName,
      businessName: businessName ?? this.businessName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      quickStats: quickStats ?? this.quickStats,
      featuredServices: featuredServices ?? this.featuredServices,
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
      imageUrl: resolveImageUrlForUseCaseFromJson(
        json,
        useCase: ResolvedImageUseCase.list,
        directKeys: const <String>[
          'main_image_url',
          'image_url',
          'asset_url',
          'url',
        ],
        objectKeys: const <String>['main_image', 'image', 'asset'],
        listKeys: const <String>['images', 'image_urls'],
      ),
    );
  }

  ProviderFeaturedService copyWith({
    String? id,
    String? title,
    String? category,
    String? status,
    String? priceLabel,
    int? reservations,
    String? imageUrl,
  }) {
    return ProviderFeaturedService(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      status: status ?? this.status,
      priceLabel: priceLabel ?? this.priceLabel,
      reservations: reservations ?? this.reservations,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

int _toInt(Object? value) {
  if (value is int) {
    return value;
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}
