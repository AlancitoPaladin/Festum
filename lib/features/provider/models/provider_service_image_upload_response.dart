import 'package:festum/features/provider/models/provider_service_image.dart';

class ProviderServiceImageUploadResponse {
  const ProviderServiceImageUploadResponse({
    required this.serviceId,
    required this.key,
    required this.image,
    required this.isMain,
  });

  final String serviceId;
  final String key;
  final ProviderServiceImage image;
  final bool isMain;

  factory ProviderServiceImageUploadResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final ProviderServiceImage image = ProviderServiceImage.fromJson(json);
    return ProviderServiceImageUploadResponse(
      serviceId: (json['service_id'] ?? '').toString(),
      key: (json['key'] ?? image.key).toString(),
      image: image,
      isMain: image.isMain,
    );
  }
}
