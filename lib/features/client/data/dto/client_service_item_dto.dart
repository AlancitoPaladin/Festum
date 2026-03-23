import 'package:festum/features/client/models/client_service_catalog.dart';

class ClientServiceItemDto {
  const ClientServiceItemDto({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.priceLabel,
    required this.unitPriceCents,
    required this.badge,
    this.shortTitle,
    this.shortSubtitle,
  });

  final String id;
  final String name;
  final String subtitle;
  final String priceLabel;
  final int unitPriceCents;
  final String badge;
  final String? shortTitle;
  final String? shortSubtitle;

  factory ClientServiceItemDto.fromJson(Map<String, dynamic> json) {
    return ClientServiceItemDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      priceLabel: json['price_label'] as String? ?? '',
      unitPriceCents: (json['unit_price_cents'] as num?)?.toInt() ?? 0,
      badge: json['badge'] as String? ?? '',
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
      displayNameShort: shortTitle,
      displaySubtitleShort: shortSubtitle,
    );
  }
}
