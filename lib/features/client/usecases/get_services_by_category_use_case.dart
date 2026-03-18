import 'package:festum/features/client/models/client_service_catalog.dart';
import 'package:festum/features/client/repositories/client_services_repository.dart';

class GetServicesByCategoryUseCase {
  const GetServicesByCategoryUseCase(this._repository);

  final ClientServicesRepository _repository;

  Future<List<ClientServiceItem>> call(ClientServiceCategory category) {
    return _repository.getServicesByCategory(category);
  }
}
