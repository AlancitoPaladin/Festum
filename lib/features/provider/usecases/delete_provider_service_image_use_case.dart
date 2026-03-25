import 'package:festum/features/provider/repositories/provider_services_repository.dart';

class DeleteProviderServiceImageUseCase {
  const DeleteProviderServiceImageUseCase(this._repository);

  final ProviderServicesRepository _repository;

  Future<void> call({
    required String serviceId,
    required String imageKey,
  }) {
    return _repository.deleteImage(serviceId: serviceId, imageKey: imageKey);
  }
}
