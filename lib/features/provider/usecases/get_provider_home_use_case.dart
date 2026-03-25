import 'package:festum/features/provider/models/provider_home_response.dart';
import 'package:festum/features/provider/repositories/provider_home_repository.dart';

class GetProviderHomeUseCase {
  const GetProviderHomeUseCase(this._repository);

  final ProviderHomeRepository _repository;

  Future<ProviderHomeResponse> call() {
    return _repository.fetchHome();
  }
}
