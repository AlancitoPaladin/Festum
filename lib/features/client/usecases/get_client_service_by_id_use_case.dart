import 'package:festum/features/client/models/client_service_catalog.dart';
import 'package:festum/features/client/repositories/client_services_repository.dart';

class GetClientServiceByIdUseCase {
  const GetClientServiceByIdUseCase(this._repository);

  final ClientServicesRepository _repository;

  Future<ClientServiceItem?> call({
    required ClientServiceCategory category,
    required String serviceId,
  }) {
    return _repository.getServiceById(category: category, serviceId: serviceId);
  }
}
