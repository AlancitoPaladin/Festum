import 'package:festum/features/client/repositories/client_cart_repository.dart';

class AddServiceToCartUseCase {
  const AddServiceToCartUseCase(this._repository);

  final ClientCartRepository _repository;

  Future<bool> call({
    required String serviceId,
    required String name,
    required int unitPriceCents,
  }) {
    return _repository.addService(
      serviceId: serviceId,
      name: name,
      unitPriceCents: unitPriceCents,
    );
  }
}
