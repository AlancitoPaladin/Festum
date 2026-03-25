import 'package:festum/features/provider/repositories/provider_reservations_repository.dart';

class DeleteProviderProductUseCase {
  const DeleteProviderProductUseCase(this._repository);

  final ProviderReservationsRepository _repository;

  Future<void> call(String productId) {
    return _repository.deleteProduct(productId);
  }
}
