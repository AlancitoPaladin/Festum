import 'package:festum/features/provider/models/provider_business_profile.dart';
import 'package:festum/features/provider/repositories/provider_business_repository.dart';

class GetProviderBusinessProfileUseCase {
  const GetProviderBusinessProfileUseCase(this._repository);

  final ProviderBusinessRepository _repository;

  Future<ProviderBusinessProfile> call() {
    return _repository.fetchProfile();
  }
}
