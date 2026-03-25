import 'package:festum/features/provider/repositories/provider_services_repository.dart';

class SetProviderServiceMainImageUseCase {
  const SetProviderServiceMainImageUseCase(this._repository);

  final ProviderServicesRepository _repository;

  Future<void> call({
    required String serviceId,
    required String imageKey,
  }) {
    return _repository.setMainImage(serviceId: serviceId, imageKey: imageKey);
  }
}
