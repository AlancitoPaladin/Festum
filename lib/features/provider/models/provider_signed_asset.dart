import 'package:festum/core/network/image_json_resolver.dart';

class ProviderAssetVariant {
  const ProviderAssetVariant({
    required this.key,
    required this.url,
    required this.expiresAt,
  });

  final String key;
  final String url;
  final DateTime? expiresAt;

  bool get hasUrl => url.trim().isNotEmpty;

  factory ProviderAssetVariant.fromJson(Map<String, dynamic> json) {
    final String key = (json['key'] ?? '').toString().trim();
    final String url =
        (json['url'] ?? json['image_url'] ?? json['asset_url'] ?? '')
            .toString()
            .trim();
    final dynamic rawExpiresAt = json['expires_at'] ?? json['expiresAt'];
    DateTime? expiresAt;
    if (rawExpiresAt is String && rawExpiresAt.trim().isNotEmpty) {
      expiresAt = DateTime.tryParse(rawExpiresAt.trim())?.toUtc();
    }
    return ProviderAssetVariant(key: key, url: url, expiresAt: expiresAt);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      'url': url,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }
}

class ProviderSignedAsset {
  const ProviderSignedAsset({
    required this.key,
    required this.url,
    required this.expiresAt,
    this.thumb,
    this.medium,
    this.original,
  });

  final String key;
  final String url;
  final DateTime? expiresAt;
  final ProviderAssetVariant? thumb;
  final ProviderAssetVariant? medium;
  final ProviderAssetVariant? original;

  bool get hasUrl => url.trim().isNotEmpty;

  bool get isExpired {
    if (expiresAt == null) {
      return false;
    }
    return DateTime.now().toUtc().isAfter(expiresAt!);
  }

  factory ProviderSignedAsset.fromJson(Map<String, dynamic> json) {
    final String key = (json['key'] ?? '').toString().trim();
    final String url =
        (json['url'] ??
                json['asset_url'] ??
                json['assetUrl'] ??
                json['logo_url'] ??
                json['logoUrl'] ??
                '')
            .toString()
            .trim();

    final dynamic rawExpiresAt = json['expires_at'] ?? json['expiresAt'];
    DateTime? expiresAt;
    if (rawExpiresAt is String && rawExpiresAt.trim().isNotEmpty) {
      expiresAt = DateTime.tryParse(rawExpiresAt.trim())?.toUtc();
    }

    return ProviderSignedAsset(
      key: key,
      url: url,
      expiresAt: expiresAt,
      thumb: _parseVariant(json['thumb']),
      medium: _parseVariant(json['medium']),
      original: _parseVariant(json['original']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      'url': url,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
      if (thumb != null) 'thumb': thumb!.toJson(),
      if (medium != null) 'medium': medium!.toJson(),
      if (original != null) 'original': original!.toJson(),
    };
  }

  String urlForUseCase(ResolvedImageUseCase useCase, {String fallback = ''}) {
    final String base = url.trim();
    final String fallbackUrl = fallback.trim();
    final String thumbUrl = thumb?.url.trim() ?? '';
    final String mediumUrl = medium?.url.trim() ?? '';
    final String originalUrl = original?.url.trim() ?? '';

    List<String> ordered;
    switch (useCase) {
      case ResolvedImageUseCase.list:
        ordered = <String>[thumbUrl, mediumUrl, base, originalUrl, fallbackUrl];
        break;
      case ResolvedImageUseCase.detail:
        ordered = <String>[mediumUrl, base, originalUrl, thumbUrl, fallbackUrl];
        break;
      case ResolvedImageUseCase.original:
        ordered = <String>[originalUrl, mediumUrl, base, thumbUrl, fallbackUrl];
        break;
    }
    for (final String candidate in ordered) {
      if (candidate.isNotEmpty) {
        return candidate;
      }
    }
    return '';
  }

  static ProviderAssetVariant? _parseVariant(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final ProviderAssetVariant parsed = ProviderAssetVariant.fromJson(raw);
      if (parsed.hasUrl || parsed.key.isNotEmpty) {
        return parsed;
      }
      return null;
    }
    if (raw is Map) {
      final ProviderAssetVariant parsed = ProviderAssetVariant.fromJson(
        Map<String, dynamic>.from(raw),
      );
      if (parsed.hasUrl || parsed.key.isNotEmpty) {
        return parsed;
      }
    }
    return null;
  }
}
