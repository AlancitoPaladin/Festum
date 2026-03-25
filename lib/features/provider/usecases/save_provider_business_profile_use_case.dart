import 'package:festum/features/provider/models/provider_business_profile.dart';
import 'package:festum/features/provider/repositories/provider_business_repository.dart';

class SaveProviderBusinessProfileUseCase {
  const SaveProviderBusinessProfileUseCase(this._repository);

  final ProviderBusinessRepository _repository;

  Future<ProviderBusinessProfile> call(ProviderBusinessProfile profile) {
    return _repository.saveProfile(profile);
  }
}
