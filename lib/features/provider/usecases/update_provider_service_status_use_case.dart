import 'package:festum/features/provider/models/provider_service.dart';
import 'package:festum/features/provider/repositories/provider_services_repository.dart';

class UpdateProviderServiceStatusUseCase {
  const UpdateProviderServiceStatusUseCase(this._repository);

  final ProviderServicesRepository _repository;

  Future<ProviderService> call({
    required String serviceId,
    required String status,
  }) {
    return _repository.updateStatus(serviceId, status);
  }
}
