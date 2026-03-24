import 'package:festum/core/network/asset_url_safety.dart';
import 'package:festum/features/client/models/client_service_catalog.dart';

class ClientServiceItemDto {
  const ClientServiceItemDto({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.priceLabel,
    required this.unitPriceCents,
    required this.badge,
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
    final String imageUrl = sanitizeAssetUrl(
      ((imagePayload?['url'] ??
              json['image_url'] ??
              json['imageUrl'] ??
              json['asset_url'] ??
              '')
          .toString()
          .trim()),
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
