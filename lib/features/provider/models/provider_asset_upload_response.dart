import 'package:festum/features/provider/models/provider_signed_asset.dart';
import 'package:festum/core/network/image_json_resolver.dart';

class ProviderAssetUploadResponse {
  const ProviderAssetUploadResponse({
    required this.providerId,
    required this.assetType,
    required this.storagePath,
    required this.assetUrl,
    this.asset,
  });

  final String providerId;
  final String assetType;
  final String storagePath;
  final String assetUrl;
  final ProviderSignedAsset? asset;
  DateTime? get expiresAt => asset?.expiresAt;

  factory ProviderAssetUploadResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> source = _resolveSource(json);
    final ProviderSignedAsset? asset = _parseAsset(source);

    return ProviderAssetUploadResponse(
      providerId: (source['provider_id'] ?? source['providerId'] ?? '')
          .toString(),
      assetType: (source['asset_type'] ?? source['assetType'] ?? '').toString(),
      storagePath: (source['storage_path'] ?? source['storagePath'] ?? '')
          .toString(),
      assetUrl: asset?.url.isNotEmpty == true
          ? asset!.url
          : resolveImageUrlFromJson(
              source,
              directKeys: const <String>[
                'asset_url',
                'logo_url',
                'image_url',
                'main_image_url',
                'url',
              ],
              objectKeys: const <String>['asset', 'logo', 'image'],
              listKeys: const <String>['images', 'image_urls', 'photos'],
            ),
      asset: asset,
    );
  }

  static ProviderSignedAsset? _parseAsset(Map<String, dynamic> source) {
    final dynamic rawAsset = source['asset'];
    if (rawAsset is Map<String, dynamic>) {
      return ProviderSignedAsset.fromJson(rawAsset);
    }
    if (rawAsset is Map) {
      return ProviderSignedAsset.fromJson(Map<String, dynamic>.from(rawAsset));
    }

    final ProviderSignedAsset fallback =
        ProviderSignedAsset.fromJson(<String, dynamic>{
          'key':
              (source['key'] ??
                      source['asset_key'] ??
                      source['storage_path'] ??
                      source['storagePath'] ??
                      '')
                  .toString(),
          'url':
              (source['asset_url'] ??
                      source['assetUrl'] ??
                      source['logo_url'] ??
                      source['logoUrl'] ??
                      source['url'] ??
                      '')
                  .toString(),
          'expires_at': source['expires_at'] ?? source['expiresAt'],
        });

    if (fallback.hasUrl || fallback.key.isNotEmpty) {
      return fallback;
    }
    return null;
  }

  static Map<String, dynamic> _resolveSource(Map<String, dynamic> json) {
    final dynamic data = json['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return json;
  }
}
