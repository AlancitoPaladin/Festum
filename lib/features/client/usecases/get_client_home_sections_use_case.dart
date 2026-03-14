import 'package:festum/features/client/models/client_service_catalog.dart';
import 'package:festum/features/client/repositories/client_services_repository.dart';

class GetClientHomeSectionsUseCase {
  const GetClientHomeSectionsUseCase(this._repository);

  final ClientServicesRepository _repository;

  Future<Map<ClientServiceCategory, List<ClientServiceItem>>> call() {
    return _repository.getHomeSections();
  }
}
