import 'package:festum/features/client/models/client_home_bootstrap.dart';
import 'package:festum/features/client/repositories/client_services_repository.dart';

class GetClientHomeBootstrapUseCase {
  const GetClientHomeBootstrapUseCase(this._repository);

  final ClientServicesRepository _repository;

  Future<ClientHomeBootstrap> call() {
    return _repository.getHomeBootstrap();
  }
}
