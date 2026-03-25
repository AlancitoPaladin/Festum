import 'package:festum/features/provider/models/provider_product.dart';
import 'package:festum/features/provider/repositories/provider_products_repository.dart';

class GetProviderServiceProductsUseCase {
  const GetProviderServiceProductsUseCase(this._repository);

  final ProviderProductsRepository _repository;

  Future<List<ProviderProduct>> call(String serviceId) {
    return _repository.fetchProductsByServiceId(serviceId);
  }
}
