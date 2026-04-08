import 'package:festum/core/network/asset_url_safety.dart';
import 'package:festum/core/network/image_json_resolver.dart';
import 'package:festum/features/provider/models/provider_product_image.dart';
import 'package:festum/features/provider/models/provider_signed_asset.dart';
import 'package:festum/features/provider/models/service_category.dart';

class ProviderProduct {
  const ProviderProduct({
    required this.id,
    required this.serviceId,
    required this.providerId,
    required this.category,
    required this.name,
    required this.description,
    required this.price,
    required this.pricingUnit,
    required this.status,
    required this.mainImageUrl,
    required this.imageUrls,
    required this.image,
    required this.images,
    required this.details,
    required this.inclusions,
    required this.policies,
  });

  final String id;
  final String serviceId;
  final String providerId;
  final ServiceCategory category;
  final String name;
  final String description;
  final double price;
  final String pricingUnit;
  final String status;
  final String mainImageUrl;
  final List<String> imageUrls;
  final ProviderSignedAsset? image;
  final List<ProviderProductImage> images;
  final Map<String, dynamic> details;
  final Map<String, bool> inclusions;
  final Map<String, bool> policies;

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
  bool get isDraft => normalizedStatus == 'draft';
  bool get isInactive => normalizedStatus == 'inactive';

  String get resolvedImageUrl {
    ProviderProductImage? mainImage;
    for (final ProviderProductImage item in images) {
      if (item.isMain) {
        mainImage = item;
        break;
      }
    }

    return sanitizeAssetUrl(
      mainImage?.resolvedImageUrl.isNotEmpty == true
          ? mainImage!.resolvedImageUrl
          : image?.urlForUseCase(
                  ResolvedImageUseCase.list,
                  fallback: mainImageUrl,
                ) ??
                mainImageUrl,
    );
  }

  String get priceLabel {
    if (price <= 0) {
      return 'Precio por definir';
    }

    final String fixed = price.toStringAsFixed(
      price.truncateToDouble() == price ? 0 : 2,
    );
    return '\$$fixed ${pricingUnit.trim()}'.trim();
  }

  factory ProviderProduct.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? imagePayload = _asMap(json['image']);
    final String legacyMainImageUrl = resolveImageUrlFromJson(
      json,
      directKeys: const <String>['main_image_url', 'image_url', 'url'],
      objectKeys: const <String>['main_image', 'image'],
      listKeys: const <String>['images', 'image_urls'],
    );
    final List<String> legacyImageUrls = resolveImageUrlsFromJson(
      json,
      listKeys: const <String>['image_urls', 'images'],
    );

    final List<ProviderProductImage> images = _parseImages(
      json,
      imagePayload: imagePayload,
      legacyMainImageUrl: legacyMainImageUrl,
      legacyImageUrls: legacyImageUrls,
    );

    return ProviderProduct(
      id: (json['id'] ?? '').toString(),
      serviceId: (json['service_id'] ?? '').toString(),
      providerId: (json['provider_id'] ?? '').toString(),
      category: ServiceCategory.fromProviderApiValue(
        (json['category'] ?? '').toString(),
      ),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: _toDouble(json['price']),
      pricingUnit: (json['pricing_unit'] ?? '').toString(),
      status: (json['status'] ?? 'draft').toString(),
      mainImageUrl: legacyMainImageUrl,
      imageUrls: legacyImageUrls,
      image: imagePayload == null
          ? null
          : ProviderSignedAsset.fromJson(imagePayload),
      images: images,
      details: _asMap(json['details']) ?? <String, dynamic>{},
      inclusions: _asBoolMap(json['inclusions']),
      policies: _asBoolMap(json['policies']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'service_id': serviceId,
      'provider_id': providerId,
      'category': category.providerApiValue,
      'name': name,
      'description': description,
      'price': price,
      'pricing_unit': pricingUnit,
      'status': status,
      'main_image_url': mainImageUrl,
      'image_urls': imageUrls,
      if (image != null) 'image': image!.toJson(),
      'images': images
          .map((ProviderProductImage item) => item.toJson())
          .toList(),
      'details': details,
      'inclusions': inclusions,
      'policies': policies,
    };
  }

  ProviderProduct copyWith({
    String? id,
    String? serviceId,
    String? providerId,
    ServiceCategory? category,
    String? name,
    String? description,
    double? price,
    String? pricingUnit,
    String? status,
    String? mainImageUrl,
    List<String>? imageUrls,
    ProviderSignedAsset? image,
    List<ProviderProductImage>? images,
    Map<String, dynamic>? details,
    Map<String, bool>? inclusions,
    Map<String, bool>? policies,
  }) {
    return ProviderProduct(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      providerId: providerId ?? this.providerId,
      category: category ?? this.category,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      pricingUnit: pricingUnit ?? this.pricingUnit,
      status: status ?? this.status,
      mainImageUrl: mainImageUrl ?? this.mainImageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      image: image ?? this.image,
      images: images ?? this.images,
      details: details ?? this.details,
      inclusions: inclusions ?? this.inclusions,
      policies: policies ?? this.policies,
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

  static Map<String, bool> _asBoolMap(dynamic value) {
    final Map<String, dynamic>? rawMap = _asMap(value);
    if (rawMap == null) {
      return <String, bool>{};
    }

    final Map<String, bool> parsed = <String, bool>{};
    rawMap.forEach((String key, dynamic item) {
      if (key.trim().isEmpty) {
        return;
      }
      parsed[key] = _toBool(item);
    });
    return parsed;
  }

  static List<ProviderProductImage> _parseImages(
    Map<String, dynamic> json, {
    required Map<String, dynamic>? imagePayload,
    required String legacyMainImageUrl,
    required List<String> legacyImageUrls,
  }) {
    final List<ProviderProductImage> parsed = <ProviderProductImage>[];
    final dynamic rawImages =
        json['images'] ?? json['gallery_images'] ?? json['product_images'];

    if (rawImages is List) {
      for (final dynamic item in rawImages) {
        if (item is Map<String, dynamic>) {
          parsed.add(ProviderProductImage.fromJson(item));
        } else if (item is Map) {
          parsed.add(
            ProviderProductImage.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    if (parsed.isEmpty && imagePayload != null) {
      parsed.add(
        ProviderProductImage.fromJson(<String, dynamic>{
          'image': imagePayload,
          'image_url': imagePayload['url'],
          'key': imagePayload['key'],
          'is_main': true,
        }, fallbackIsMain: true),
      );
    }

    if (parsed.isEmpty && legacyMainImageUrl.isNotEmpty) {
      parsed.add(
        ProviderProductImage.fromJson(<String, dynamic>{
          'image_url': legacyMainImageUrl,
          'is_main': true,
        }, fallbackIsMain: true),
      );
    }

    for (final String imageUrl in legacyImageUrls) {
      final bool alreadyIncluded = parsed.any(
        (ProviderProductImage item) => item.legacyImageUrl == imageUrl,
      );
      if (alreadyIncluded) {
        continue;
      }
      parsed.add(
        ProviderProductImage.fromJson(<String, dynamic>{
          'image_url': imageUrl,
          'is_main': parsed.isEmpty,
        }, fallbackIsMain: parsed.isEmpty),
      );
    }

    if (parsed.isNotEmpty &&
        !parsed.any((ProviderProductImage item) => item.isMain)) {
      parsed[0] = parsed[0].copyWith(isMain: true);
    }

    return parsed;
  }
}

class ProviderProductsResponse {
  const ProviderProductsResponse({required this.items, required this.total});

  final List<ProviderProduct> items;
  final int total;

  factory ProviderProductsResponse.fromJson(Map<String, dynamic> json) {
    final List<ProviderProduct> items =
        ((json['items'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (Map<dynamic, dynamic> item) =>
                  ProviderProduct.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList());
    final dynamic rawTotal = json['total'];
    final int total = rawTotal is num
        ? rawTotal.toInt()
        : int.tryParse(rawTotal?.toString() ?? '') ?? items.length;

    return ProviderProductsResponse(items: items, total: total);
  }
}

double _toDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

bool _toBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  final String normalized = value?.toString().trim().toLowerCase() ?? '';
  if (normalized == 'true' || normalized == '1') {
    return true;
  }
  return false;
}
