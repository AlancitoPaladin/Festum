import 'package:festum/features/provider/models/provider_product.dart';
import 'package:festum/features/provider/repositories/provider_products_repository.dart';

class GetProviderProductDetailUseCase {
  const GetProviderProductDetailUseCase(this._repository);

  final ProviderProductsRepository _repository;

  Future<ProviderProduct> call(String productId) {
    return _repository.fetchProduct(productId);
  }
}
