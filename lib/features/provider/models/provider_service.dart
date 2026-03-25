import 'package:festum/core/network/asset_url_safety.dart';
import 'package:festum/features/provider/models/provider_service_image.dart';
import 'package:festum/features/provider/models/provider_signed_asset.dart';
import 'package:festum/features/provider/models/service_category.dart';

class ProviderService {
  const ProviderService({
    required this.id,
    required this.category,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.unitPriceCents,
    required this.priceLabel,
    required this.badge,
    required this.status,
    required this.mainImageKey,
    required this.imageKeys,
    required this.image,
    required this.images,
    required this.legacyImageUrl,
  });

  final String id;
  final ServiceCategory category;
  final String name;
  final String subtitle;
  final String description;
  final int unitPriceCents;
  final String priceLabel;
  final String badge;
  final String status;
  final String mainImageKey;
  final List<String> imageKeys;
  final ProviderSignedAsset? image;
  final List<ProviderServiceImage> images;
  final String legacyImageUrl;

  String get normalizedStatus {
    switch (status.trim().toLowerCase()) {
      case 'active':
      case 'published':
        return 'published';
      case 'inactive':
        return 'inactive';
      case 'draft':
      default:
        return 'draft';
    }
  }

  bool get isPublished => normalizedStatus == 'published';
  bool get isInactive => normalizedStatus == 'inactive';
  bool get isDraft => normalizedStatus == 'draft';

  String get resolvedImageUrl {
    ProviderServiceImage? mainImage;
    for (final ProviderServiceImage item in images) {
      if (item.isMain) {
        mainImage = item;
        break;
      }
    }
    final String imageUrl = sanitizeAssetUrl(
      mainImage?.resolvedImageUrl.isNotEmpty == true
          ? mainImage!.resolvedImageUrl
          : (image?.url.trim().isNotEmpty == true ? image!.url : legacyImageUrl),
    );
    return imageUrl;
  }

  factory ProviderService.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? imagePayload = _asMap(json['image']);
    final String mainImageKey =
        (imagePayload?['key'] ?? json['main_image_key'] ?? '').toString();
    final String legacyImageUrl =
        (json['image_url'] ?? json['main_image_url'] ?? '').toString();
    final List<ProviderServiceImage> images = _parseImages(
      json,
      mainImageKey: mainImageKey,
      imagePayload: imagePayload,
      legacyImageUrl: legacyImageUrl,
    );
    return ProviderService(
      id: (json['id'] ?? '').toString(),
      category: ServiceCategory.fromProviderApiValue(
        (json['category'] ?? '').toString(),
      ),
      name: (json['name'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      unitPriceCents: _toInt(json['unit_price_cents']),
      priceLabel: (json['price_label'] ?? '').toString(),
      badge: (json['badge'] ?? '').toString(),
      status: (json['status'] ?? 'draft').toString(),
      mainImageKey: mainImageKey,
      imageKeys:
          ((json['image_keys'] as List<dynamic>? ?? <dynamic>[])
              .map((dynamic item) => item.toString().trim())
              .where((String item) => item.isNotEmpty)
              .toList()),
      image: imagePayload == null
          ? null
          : ProviderSignedAsset.fromJson(imagePayload),
      images: images,
      legacyImageUrl: legacyImageUrl,
    );
  }

  ProviderService copyWith({
    String? id,
    ServiceCategory? category,
    String? name,
    String? subtitle,
    String? description,
    int? unitPriceCents,
    String? priceLabel,
    String? badge,
    String? status,
    String? mainImageKey,
    List<String>? imageKeys,
    ProviderSignedAsset? image,
    List<ProviderServiceImage>? images,
    String? legacyImageUrl,
  }) {
    return ProviderService(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      priceLabel: priceLabel ?? this.priceLabel,
      badge: badge ?? this.badge,
      status: status ?? this.status,
      mainImageKey: mainImageKey ?? this.mainImageKey,
      imageKeys: imageKeys ?? this.imageKeys,
      image: image ?? this.image,
      images: images ?? this.images,
      legacyImageUrl: legacyImageUrl ?? this.legacyImageUrl,
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

  static List<ProviderServiceImage> _parseImages(
    Map<String, dynamic> json, {
    required String mainImageKey,
    required Map<String, dynamic>? imagePayload,
    required String legacyImageUrl,
  }) {
    final List<ProviderServiceImage> parsed = <ProviderServiceImage>[];

    final dynamic rawImages =
        json['images'] ?? json['gallery_images'] ?? json['service_images'];
    if (rawImages is List) {
      for (final dynamic item in rawImages) {
        if (item is Map<String, dynamic>) {
          parsed.add(
            ProviderServiceImage.fromJson(
              item,
              fallbackIsMain: _matchesMainImageKey(item, mainImageKey),
            ),
          );
        } else if (item is Map) {
          final Map<String, dynamic> normalized = Map<String, dynamic>.from(item);
          parsed.add(
            ProviderServiceImage.fromJson(
              normalized,
              fallbackIsMain: _matchesMainImageKey(normalized, mainImageKey),
            ),
          );
        }
      }
    }

    final List<String> imageKeys =
        ((json['image_keys'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic item) => item.toString().trim())
            .where((String item) => item.isNotEmpty)
            .toList());
    for (final String imageKey in imageKeys) {
      final bool alreadyIncluded = parsed.any(
        (ProviderServiceImage item) => item.key == imageKey,
      );
      if (alreadyIncluded) {
        continue;
      }
      parsed.add(
        ProviderServiceImage.fromJson(
          <String, dynamic>{
            'key': imageKey,
            'is_main': imageKey == mainImageKey,
          },
          fallbackIsMain: imageKey == mainImageKey,
        ),
      );
    }

    final String fallbackKey =
        (imagePayload?['key'] ?? json['main_image_key'] ?? '').toString();
    if (fallbackKey.isNotEmpty || legacyImageUrl.trim().isNotEmpty) {
      final bool alreadyIncluded = parsed.any(
        (ProviderServiceImage item) =>
            fallbackKey.isNotEmpty && item.key == fallbackKey,
      );
      if (!alreadyIncluded) {
        parsed.insert(
          0,
          ProviderServiceImage.fromJson(
            <String, dynamic>{
              'key': fallbackKey,
              'image': imagePayload,
              'image_url': legacyImageUrl,
              'is_main': true,
            },
            fallbackIsMain: true,
          ),
        );
      }
    }

    if (parsed.isNotEmpty && !parsed.any((item) => item.isMain)) {
      final int mainIndex = parsed.indexWhere(
        (ProviderServiceImage item) =>
            mainImageKey.isNotEmpty && item.key == mainImageKey,
      );
      if (mainIndex >= 0) {
        parsed[mainIndex] = parsed[mainIndex].copyWith(isMain: true);
      } else {
        parsed[0] = parsed[0].copyWith(isMain: true);
      }
    }

    return parsed;
  }

  static bool _matchesMainImageKey(
    Map<String, dynamic> json,
    String mainImageKey,
  ) {
    if (mainImageKey.isEmpty) {
      return false;
    }
    final String key =
        (json['key'] ?? json['image_key'] ?? json['main_image_key'] ?? '')
            .toString();
    return key == mainImageKey;
  }
}

class ProviderServicesResponse {
  const ProviderServicesResponse({
    required this.items,
    required this.total,
  });

  final List<ProviderService> items;
  final int total;

  factory ProviderServicesResponse.fromJson(Map<String, dynamic> json) {
    return ProviderServicesResponse(
      items:
          ((json['items'] as List<dynamic>? ?? <dynamic>[])
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (Map<dynamic, dynamic> item) =>
                    ProviderService.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()),
      total: _toInt(json['total']),
    );
  }
}

int _toInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
