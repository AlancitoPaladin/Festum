import 'package:festum/features/provider/models/provider_service_image_upload_response.dart';
import 'package:festum/features/provider/repositories/provider_services_repository.dart';

class UploadProviderServiceImageUseCase {
  const UploadProviderServiceImageUseCase(this._repository);

  final ProviderServicesRepository _repository;

  Future<ProviderServiceImageUploadResponse> call({
    required String serviceId,
    required String filePath,
    required bool isMain,
  }) {
    return _repository.uploadServiceImage(
      serviceId: serviceId,
      filePath: filePath,
      isMain: isMain,
    );
  }
}
