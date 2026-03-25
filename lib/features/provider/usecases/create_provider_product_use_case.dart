import 'package:festum/features/provider/models/provider_product.dart';
import 'package:festum/features/provider/models/provider_product_request.dart';
import 'package:festum/features/provider/repositories/provider_products_repository.dart';

class CreateProviderProductUseCase {
  const CreateProviderProductUseCase(this._repository);

  final ProviderProductsRepository _repository;

  Future<ProviderProduct> call({
    required String serviceId,
    required CreateProviderProductRequest request,
  }) {
    return _repository.createProduct(serviceId, request);
  }
}
