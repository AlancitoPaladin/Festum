import 'package:festum/core/network/asset_url_safety.dart';
import 'package:festum/core/network/image_json_resolver.dart';
import 'package:festum/features/provider/models/provider_signed_asset.dart';

class ProviderProductImage {
  const ProviderProductImage({
    required this.key,
    required this.asset,
    required this.legacyImageUrl,
    required this.isMain,
  });

  final String key;
  final ProviderSignedAsset? asset;
  final String legacyImageUrl;
  final bool isMain;

  String get resolvedImageUrl {
    return sanitizeAssetUrl(
      asset?.url.trim().isNotEmpty == true ? asset!.url : legacyImageUrl,
    );
  }

  ProviderProductImage copyWith({
    String? key,
    ProviderSignedAsset? asset,
    String? legacyImageUrl,
    bool? isMain,
  }) {
    return ProviderProductImage(
      key: key ?? this.key,
      asset: asset ?? this.asset,
      legacyImageUrl: legacyImageUrl ?? this.legacyImageUrl,
      isMain: isMain ?? this.isMain,
    );
  }

  factory ProviderProductImage.fromJson(
    Map<String, dynamic> json, {
    bool fallbackIsMain = false,
  }) {
    final Map<String, dynamic>? imagePayload = _asMap(json['image']);
    final ProviderSignedAsset? asset = imagePayload == null
        ? _fallbackAsset(json)
        : ProviderSignedAsset.fromJson(imagePayload);

    final String key =
        (json['key'] ??
                json['image_key'] ??
                imagePayload?['key'] ??
                asset?.key ??
                '')
            .toString()
            .trim();

    final String legacyImageUrl =
        resolveImageUrlFromJson(
          json,
          directKeys: const <String>[
            'main_image_url',
            'image_url',
            'url',
            'asset_url',
          ],
          objectKeys: const <String>['main_image', 'image', 'asset'],
          listKeys: const <String>['images', 'image_urls'],
        );

    return ProviderProductImage(
      key: key,
      asset: asset,
      legacyImageUrl: legacyImageUrl,
      isMain: _toBool(json['is_main'], fallbackValue: fallbackIsMain),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      'image': asset?.toJson(),
      'image_url': legacyImageUrl,
      'is_main': isMain,
    };
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

  static ProviderSignedAsset? _fallbackAsset(Map<String, dynamic> json) {
    final ProviderSignedAsset asset = ProviderSignedAsset.fromJson(
      <String, dynamic>{
        'key': (json['key'] ?? json['image_key'] ?? '').toString(),
        'url': (json['image_url'] ?? json['url'] ?? '').toString(),
        'expires_at': json['expires_at'] ?? json['expiresAt'],
      },
    );
    if (asset.key.isEmpty && !asset.hasUrl) {
      return null;
    }
    return asset;
  }

  static bool _toBool(dynamic value, {required bool fallbackValue}) {
    if (value is bool) {
      return value;
    }
    final String normalized = value?.toString().trim().toLowerCase() ?? '';
    if (normalized == 'true') {
      return true;
    }
    if (normalized == 'false') {
      return false;
    }
    return fallbackValue;
  }
}
