import 'package:festum/core/network/asset_url_safety.dart';
import 'package:festum/core/network/image_json_resolver.dart';
import 'package:festum/features/provider/models/provider_signed_asset.dart';

class ProviderBusinessProfile {
  const ProviderBusinessProfile({
    required this.providerId,
    required this.businessName,
    required this.location,
    required this.coverageArea,
    required this.contactNumber,
    required this.whatsapp,
    required this.instagram,
    required this.facebook,
    required this.website,
    required this.logoUrl,
    required this.photoUrls,
    this.createdAt,
    this.logo,
    this.photos = const <ProviderSignedAsset>[],
  });

  final String providerId;
  final String businessName;
  final String location;
  final String coverageArea;
  final String contactNumber;
  final String whatsapp;
  final String instagram;
  final String facebook;
  final String website;
  final String logoUrl;
  final List<String> photoUrls;
  final DateTime? createdAt;
  final ProviderSignedAsset? logo;
  final List<ProviderSignedAsset> photos;

  factory ProviderBusinessProfile.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> source = _resolveSource(json);
    final ProviderSignedAsset? logo = _parseLogo(source);
    final List<ProviderSignedAsset> photos = _parsePhotos(source);
    final String fallbackLogoUrl = resolveImageUrlFromJson(
      source,
      directKeys: const <String>['logo_url', 'image_url', 'asset_url', 'url'],
      objectKeys: const <String>['logo', 'asset', 'image'],
      listKeys: const <String>['photos', 'photo_urls', 'images'],
    );
    final List<String> fallbackPhotoUrls = _parseLegacyPhotoUrls(source);

    return ProviderBusinessProfile(
      providerId: (source['provider_id'] ?? source['providerId'] ?? '')
          .toString(),
      businessName: (source['business_name'] ?? source['businessName'] ?? '')
          .toString(),
      location: (source['location'] ?? '').toString(),
      coverageArea: (source['coverage_area'] ?? source['coverageArea'] ?? '')
          .toString(),
      contactNumber: (source['contact_number'] ?? source['contactNumber'] ?? '')
          .toString(),
      whatsapp: (source['whatsapp'] ?? '').toString(),
      instagram: (source['instagram'] ?? '').toString(),
      facebook: (source['facebook'] ?? '').toString(),
      website: (source['website'] ?? '').toString(),
      logoUrl: logo?.url.isNotEmpty == true ? logo!.url : fallbackLogoUrl,
      photoUrls: photos.isNotEmpty
          ? photos
                .where((ProviderSignedAsset item) => item.url.isNotEmpty)
                .map((ProviderSignedAsset item) => item.url)
                .toList()
          : fallbackPhotoUrls,
      createdAt: _parseDateTime(
        source['created_at'] ?? source['createdAt'] ?? source['member_since'],
      ),
      logo: logo,
      photos: photos,
    );
  }

  static ProviderSignedAsset? _parseLogo(Map<String, dynamic> source) {
    final dynamic logo = source['logo'];
    if (logo is Map<String, dynamic>) {
      final ProviderSignedAsset parsed = ProviderSignedAsset.fromJson(logo);
      if (parsed.hasUrl || parsed.key.isNotEmpty) {
        return parsed;
      }
    } else if (logo is Map) {
      final ProviderSignedAsset parsed = ProviderSignedAsset.fromJson(
        Map<String, dynamic>.from(logo),
      );
      if (parsed.hasUrl || parsed.key.isNotEmpty) {
        return parsed;
      }
    }

    final Map<String, dynamic> fallback = <String, dynamic>{
      'key': (source['logo_key'] ?? source['logoKey'] ?? '').toString(),
      'url': (source['logo_url'] ?? source['logoUrl'] ?? '').toString(),
      'expires_at': source['logo_expires_at'] ?? source['logoExpiresAt'],
    };
    final ProviderSignedAsset parsed = ProviderSignedAsset.fromJson(fallback);
    if (parsed.hasUrl || parsed.key.isNotEmpty) {
      return parsed;
    }

    return null;
  }

  static List<String> _parseLegacyPhotoUrls(Map<String, dynamic> source) {
    return resolveImageUrlsFromJson(
      source,
      listKeys: const <String>['photo_urls', 'photoUrls', 'photos', 'images'],
    );
  }

  static List<ProviderSignedAsset> _parsePhotos(Map<String, dynamic> source) {
    final dynamic rawPhotos = source['photos'];
    if (rawPhotos is List) {
      return rawPhotos
          .map((dynamic item) {
            if (item is Map<String, dynamic>) {
              return ProviderSignedAsset.fromJson(item);
            }
            if (item is Map) {
              return ProviderSignedAsset.fromJson(
                Map<String, dynamic>.from(item),
              );
            }
            if (item is String && item.trim().isNotEmpty) {
              final String safeUrl = sanitizeAssetUrl(item);
              if (safeUrl.isEmpty) {
                return null;
              }
              return ProviderSignedAsset.fromJson(<String, dynamic>{
                'url': safeUrl,
              });
            }
            return null;
          })
          .whereType<ProviderSignedAsset>()
          .where(
            (ProviderSignedAsset asset) => asset.hasUrl || asset.key.isNotEmpty,
          )
          .toList();
    }

    final dynamic rawLegacyUrls = source['photo_urls'] ?? source['photoUrls'];
    if (rawLegacyUrls is List) {
      return rawLegacyUrls
          .whereType<String>()
          .map(sanitizeAssetUrl)
          .where((String item) => item.trim().isNotEmpty)
          .map(
            (String item) =>
                ProviderSignedAsset.fromJson(<String, dynamic>{'url': item}),
          )
          .toList();
    }

    return const <ProviderSignedAsset>[];
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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'business_name': businessName,
      'location': location,
      'coverage_area': coverageArea,
      'contact_number': contactNumber,
      'whatsapp': whatsapp,
      'instagram': instagram,
      'facebook': facebook,
      'website': website,
      'logo_url': logoUrl,
      'photo_urls': photoUrls,
      'created_at': createdAt?.toIso8601String(),
      if (logo != null) 'logo': logo!.toJson(),
      if (photos.isNotEmpty)
        'photos': photos
            .map((ProviderSignedAsset item) => item.toJson())
            .toList(),
    };
  }

  ProviderBusinessProfile copyWith({
    String? providerId,
    String? businessName,
    String? location,
    String? coverageArea,
    String? contactNumber,
    String? whatsapp,
    String? instagram,
    String? facebook,
    String? website,
    String? logoUrl,
    List<String>? photoUrls,
    DateTime? createdAt,
    ProviderSignedAsset? logo,
    List<ProviderSignedAsset>? photos,
  }) {
    return ProviderBusinessProfile(
      providerId: providerId ?? this.providerId,
      businessName: businessName ?? this.businessName,
      location: location ?? this.location,
      coverageArea: coverageArea ?? this.coverageArea,
      contactNumber: contactNumber ?? this.contactNumber,
      whatsapp: whatsapp ?? this.whatsapp,
      instagram: instagram ?? this.instagram,
      facebook: facebook ?? this.facebook,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
      logo: logo ?? this.logo,
      photos: photos ?? this.photos,
    );
  }
}

DateTime? _parseDateTime(Object? value) {
  final String raw = (value ?? '').toString().trim();
  if (raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}
