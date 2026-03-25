import 'package:festum/features/provider/repositories/provider_products_repository.dart';

class SetProviderProductMainImageUseCase {
  const SetProviderProductMainImageUseCase(this._repository);

  final ProviderProductsRepository _repository;

  Future<void> call({
    required String productId,
    required String imageKey,
  }) {
    return _repository.setMainImage(productId: productId, imageKey: imageKey);
  }
}
