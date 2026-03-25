import 'package:festum/features/provider/models/provider_product.dart';
import 'package:festum/features/provider/models/provider_product_request.dart';
import 'package:festum/features/provider/repositories/provider_products_repository.dart';

class UpdateProviderProductUseCase {
  const UpdateProviderProductUseCase(this._repository);

  final ProviderProductsRepository _repository;

  Future<ProviderProduct> call(
    String productId,
    UpdateProviderProductRequest request,
  ) {
    return _repository.updateProduct(productId, request);
  }
}
