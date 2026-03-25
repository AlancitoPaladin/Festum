import 'package:festum/features/provider/models/provider_product_image.dart';

class ProviderProductImageUploadResponse {
  const ProviderProductImageUploadResponse({
    required this.productId,
    required this.key,
    required this.image,
    required this.isMain,
  });

  final String productId;
  final String key;
  final ProviderProductImage image;
  final bool isMain;

  factory ProviderProductImageUploadResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final ProviderProductImage image = ProviderProductImage.fromJson(json);
    return ProviderProductImageUploadResponse(
      productId: (json['product_id'] ?? '').toString(),
      key: (json['key'] ?? image.key).toString(),
      image: image,
      isMain: image.isMain,
    );
  }
}
