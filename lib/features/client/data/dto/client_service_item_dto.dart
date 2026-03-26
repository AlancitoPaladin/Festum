import 'package:festum/core/network/image_json_resolver.dart';
import 'package:festum/features/client/models/client_service_catalog.dart';

class ClientServiceItemDto {
  const ClientServiceItemDto({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.priceLabel,
    required this.unitPriceCents,
    required this.badge,
    required this.products,
    required this.imageKey,
    required this.imageUrl,
    this.imageExpiresAt,
    this.shortTitle,
    this.shortSubtitle,
  });

  final String id;
  final String name;
  final String subtitle;
  final String priceLabel;
  final int unitPriceCents;
  final String badge;
  final List<ClientServiceProductDto> products;
  final String imageKey;
  final String imageUrl;
  final DateTime? imageExpiresAt;
  final String? shortTitle;
  final String? shortSubtitle;

  factory ClientServiceItemDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? imagePayload = _asMap(json['image']);
    final String imageKey = (imagePayload?['key'] ?? json['image_key'] ?? '')
        .toString()
        .trim();
    final String imageUrl = resolveImageUrlFromJson(
      json,
      directKeys: const <String>[
        'main_image_url',
        'image_url',
        'imageUrl',
        'asset_url',
        'url',
      ],
      objectKeys: const <String>['main_image', 'image', 'asset'],
      listKeys: const <String>['images', 'image_urls'],
    );
    final DateTime? imageExpiresAt = _parseDate(
      imagePayload?['expires_at'] ??
          imagePayload?['expiresAt'] ??
          json['image_expires_at'] ??
          json['imageExpiresAt'],
    );

    return ClientServiceItemDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      priceLabel: json['price_label'] as String? ?? '',
      unitPriceCents: (json['unit_price_cents'] as num?)?.toInt() ?? 0,
      badge: json['badge'] as String? ?? '',
      products:
          ((json['products'] as List<dynamic>? ?? <dynamic>[])
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (Map<dynamic, dynamic> item) =>
                    ClientServiceProductDto.fromJson(
                      Map<String, dynamic>.from(item),
                    ),
              )
              .toList()),
      imageKey: imageKey,
      imageUrl: imageUrl,
      imageExpiresAt: imageExpiresAt,
      shortTitle: json['short_title'] as String?,
      shortSubtitle: json['short_subtitle'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'price_label': priceLabel,
      'unit_price_cents': unitPriceCents,
      'badge': badge,
      'products': products
          .map((ClientServiceProductDto item) => item.toJson())
          .toList(),
      'image': <String, dynamic>{
        'key': imageKey,
        'url': imageUrl,
        if (imageExpiresAt != null)
          'expires_at': imageExpiresAt!.toIso8601String(),
      },
      'image_url': imageUrl,
      if (shortTitle != null) 'short_title': shortTitle,
      if (shortSubtitle != null) 'short_subtitle': shortSubtitle,
    };
  }

  ClientServiceItem toDomain() {
    return ClientServiceItem(
      id: id,
      name: name,
      subtitle: subtitle,
      priceLabel: priceLabel,
      unitPriceCents: unitPriceCents,
      badge: badge,
      products: products
          .map((ClientServiceProductDto item) => item.toDomain())
          .toList(),
      imageKey: imageKey,
      imageUrl: imageUrl,
      imageExpiresAt: imageExpiresAt,
      displayNameShort: shortTitle,
      displaySubtitleShort: shortSubtitle,
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value.trim())?.toUtc();
  }
}

class ClientServiceProductDto {
  const ClientServiceProductDto({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.description,
    required this.priceLabel,
    required this.unitPriceCents,
    required this.category,
    required this.imageKey,
    required this.imageUrl,
    this.imageExpiresAt,
  });

  final String id;
  final String serviceId;
  final String name;
  final String description;
  final String priceLabel;
  final int unitPriceCents;
  final String category;
  final String imageKey;
  final String imageUrl;
  final DateTime? imageExpiresAt;

  factory ClientServiceProductDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? imagePayload = ClientServiceItemDto._asMap(
      json['image'],
    );
    final String imageKey =
        (imagePayload?['key'] ?? json['image_key'] ?? '').toString().trim();
    final String imageUrl = resolveImageUrlFromJson(
      json,
      directKeys: const <String>['main_image_url', 'image_url', 'url'],
      objectKeys: const <String>['main_image', 'image'],
      listKeys: const <String>['images', 'image_urls'],
    );
    final int unitPriceCents =
        (json['unit_price_cents'] as num?)?.toInt() ??
        (((json['price'] as num?)?.toDouble() ?? 0) * 100).round();
    final String priceLabel =
        (json['price_label'] as String?)?.trim().isNotEmpty == true
        ? (json['price_label'] as String).trim()
        : _buildPriceLabel(
            unitPriceCents: unitPriceCents,
            pricingUnit: (json['pricing_unit'] as String?) ?? '',
          );

    return ClientServiceProductDto(
      id: (json['id'] ?? '').toString(),
      serviceId: (json['service_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      priceLabel: priceLabel,
      unitPriceCents: unitPriceCents,
      category: (json['category'] ?? '').toString(),
      imageKey: imageKey,
      imageUrl: imageUrl,
      imageExpiresAt: ClientServiceItemDto._parseDate(
        imagePayload?['expires_at'] ?? json['image_expires_at'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'service_id': serviceId,
      'name': name,
      'description': description,
      'price_label': priceLabel,
      'unit_price_cents': unitPriceCents,
      'category': category,
      'image': <String, dynamic>{
        'key': imageKey,
        'url': imageUrl,
        if (imageExpiresAt != null)
          'expires_at': imageExpiresAt!.toIso8601String(),
      },
      'image_url': imageUrl,
    };
  }

  ClientServiceProduct toDomain() {
    return ClientServiceProduct(
      id: id,
      serviceId: serviceId,
      name: name,
      description: description,
      priceLabel: priceLabel,
      unitPriceCents: unitPriceCents,
      category: category,
      imageKey: imageKey,
      imageUrl: imageUrl,
      imageExpiresAt: imageExpiresAt,
    );
  }

  static String _buildPriceLabel({
    required int unitPriceCents,
    required String pricingUnit,
  }) {
    if (unitPriceCents <= 0) {
      return 'Precio por definir';
    }

    final double amount = unitPriceCents / 100;
    final String fixed = amount.toStringAsFixed(
      amount.truncateToDouble() == amount ? 0 : 2,
    );
    final String trimmedUnit = pricingUnit.trim();
    if (trimmedUnit.isEmpty) {
      return '\$$fixed';
    }
    return '\$$fixed $trimmedUnit';
  }
}
