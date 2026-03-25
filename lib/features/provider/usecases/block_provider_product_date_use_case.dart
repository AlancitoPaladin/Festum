import 'package:festum/features/provider/repositories/provider_availability_repository.dart';

class BlockProviderProductDateUseCase {
  const BlockProviderProductDateUseCase(this._repository);

  final ProviderAvailabilityRepository _repository;

  Future<void> call({
    required String productId,
    required DateTime date,
  }) {
    return _repository.blockDate(productId: productId, date: date);
  }
}
