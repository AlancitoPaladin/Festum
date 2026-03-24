class ProviderSignedAsset {
  const ProviderSignedAsset({
    required this.key,
    required this.url,
    required this.expiresAt,
  });

  final String key;
  final String url;
  final DateTime? expiresAt;

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

    return ProviderSignedAsset(key: key, url: url, expiresAt: expiresAt);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      'url': url,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }
}
