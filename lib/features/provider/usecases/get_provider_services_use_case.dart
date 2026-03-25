import 'package:festum/features/provider/models/provider_service.dart';
import 'package:festum/features/provider/repositories/provider_services_repository.dart';

class GetProviderServicesUseCase {
  const GetProviderServicesUseCase(this._repository);

  final ProviderServicesRepository _repository;

  Future<List<ProviderService>> call() {
    return _repository.fetchServices();
  }
}
