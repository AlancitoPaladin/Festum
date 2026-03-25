import 'package:festum/features/provider/models/provider_service.dart';
import 'package:festum/features/provider/models/provider_service_upsert_request.dart';
import 'package:festum/features/provider/repositories/provider_services_repository.dart';

class CreateProviderServiceUseCase {
  const CreateProviderServiceUseCase(this._repository);

  final ProviderServicesRepository _repository;

  Future<ProviderService> call(ProviderServiceUpsertRequest request) {
    return _repository.createService(request);
  }
}
