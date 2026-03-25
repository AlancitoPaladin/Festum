import 'package:festum/features/provider/models/provider_product.dart';
import 'package:festum/features/provider/repositories/provider_products_repository.dart';

class UpdateProviderProductStatusUseCase {
  const UpdateProviderProductStatusUseCase(this._repository);

  final ProviderProductsRepository _repository;

  Future<ProviderProduct> call({
    required String productId,
    required String status,
  }) {
    return _repository.updateStatus(productId, status);
  }
}
