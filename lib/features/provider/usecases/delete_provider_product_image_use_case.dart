import 'package:festum/features/provider/repositories/provider_products_repository.dart';

class DeleteProviderProductImageUseCase {
  const DeleteProviderProductImageUseCase(this._repository);

  final ProviderProductsRepository _repository;

  Future<void> call({
    required String productId,
    required String imageKey,
  }) {
    return _repository.deleteImage(productId: productId, imageKey: imageKey);
  }
}
