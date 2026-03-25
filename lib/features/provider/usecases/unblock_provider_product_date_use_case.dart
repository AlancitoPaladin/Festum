import 'package:festum/features/provider/repositories/provider_availability_repository.dart';

class UnblockProviderProductDateUseCase {
  const UnblockProviderProductDateUseCase(this._repository);

  final ProviderAvailabilityRepository _repository;

  Future<void> call({
    required String productId,
    required DateTime date,
  }) {
    return _repository.unblockDate(productId: productId, date: date);
  }
}
