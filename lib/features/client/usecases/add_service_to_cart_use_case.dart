import 'package:festum/features/client/repositories/client_cart_repository.dart';

class AddServiceToCartUseCase {
  const AddServiceToCartUseCase(this._repository);

  final ClientCartRepository _repository;

  Future<bool> call({
    required String serviceId,
    required String name,
    required int unitPriceCents,
    String? productId,
    String? productName,
    List<String>? selectedProductIds,
  }) {
    return _repository.addService(
      serviceId: serviceId,
      name: name,
      unitPriceCents: unitPriceCents,
      productId: productId,
      productName: productName,
      selectedProductIds: selectedProductIds,
    );
  }
}
