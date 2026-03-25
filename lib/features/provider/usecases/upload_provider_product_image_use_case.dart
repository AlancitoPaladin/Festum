import 'package:festum/features/provider/models/provider_product_image_upload_response.dart';
import 'package:festum/features/provider/repositories/provider_products_repository.dart';

class UploadProviderProductImageUseCase {
  const UploadProviderProductImageUseCase(this._repository);

  final ProviderProductsRepository _repository;

  Future<ProviderProductImageUploadResponse> call({
    required String productId,
    required String filePath,
    required bool isMain,
  }) {
    return _repository.uploadProductImage(
      productId: productId,
      filePath: filePath,
      isMain: isMain,
    );
  }
}
