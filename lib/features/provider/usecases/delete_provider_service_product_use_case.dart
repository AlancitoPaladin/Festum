import 'package:festum/features/provider/repositories/provider_products_repository.dart';

class DeleteProviderServiceProductUseCase {
  const DeleteProviderServiceProductUseCase(this._repository);

  final ProviderProductsRepository _repository;

  Future<void> call(String productId) {
    return _repository.deleteProduct(productId);
  }
}
