class ProviderAssetUploadResponse {
  const ProviderAssetUploadResponse({
    required this.providerId,
    required this.assetType,
    required this.storagePath,
    required this.assetUrl,
  });

  final String providerId;
  final String assetType;
  final String storagePath;
  final String assetUrl;

  factory ProviderAssetUploadResponse.fromJson(Map<String, dynamic> json) {
    return ProviderAssetUploadResponse(
      providerId: (json['provider_id'] ?? '').toString(),
      assetType: (json['asset_type'] ?? '').toString(),
      storagePath: (json['storage_path'] ?? '').toString(),
      assetUrl: (json['asset_url'] ?? '').toString(),
    );
  }
}
