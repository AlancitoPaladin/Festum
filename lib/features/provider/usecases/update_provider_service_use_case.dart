import 'package:festum/features/provider/models/provider_service.dart';
import 'package:festum/features/provider/models/provider_service_upsert_request.dart';
import 'package:festum/features/provider/repositories/provider_services_repository.dart';

class UpdateProviderServiceUseCase {
  const UpdateProviderServiceUseCase(this._repository);

  final ProviderServicesRepository _repository;

  Future<ProviderService> call({
    required String serviceId,
    required ProviderServiceUpsertRequest request,
  }) {
    return _repository.updateService(serviceId: serviceId, request: request);
  }
}
