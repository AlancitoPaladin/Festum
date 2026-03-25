import 'package:festum/features/provider/models/provider_asset_upload_response.dart';
import 'package:festum/features/provider/repositories/provider_business_repository.dart';

class UploadProviderBusinessPhotoUseCase {
  const UploadProviderBusinessPhotoUseCase(this._repository);

  final ProviderBusinessRepository _repository;

  Future<ProviderAssetUploadResponse> call(String filePath) {
    return _repository.uploadPhoto(filePath);
  }
}
