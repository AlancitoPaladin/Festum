import 'package:festum/core/network/api_client.dart';
import 'package:festum/features/provider/models/provider_product.dart';
import 'package:festum/features/provider/models/provider_product_image_upload_response.dart';
import 'package:festum/features/provider/models/provider_product_request.dart';
import 'package:festum/features/provider/repositories/provider_services_repository.dart';

class ProviderProductsRepository {
  ProviderProductsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ProviderProduct>> fetchProductsByServiceId(String serviceId) async {
    final Map<String, dynamic> response = await _apiClient
        .getProviderServiceProductsById(serviceId);
    return ProviderProductsResponse.fromJson(response).items;
  }

  Future<ProviderProduct> createProduct(
    String serviceId,
    CreateProviderProductRequest request,
  ) async {
    final Map<String, dynamic> response = await _apiClient.createProviderProduct(
      serviceId,
      request.toJson(),
    );
    return ProviderProduct.fromJson(response);
  }

  Future<void> deleteProduct(String productId) async {
    await _apiClient.deleteProviderProduct(productId);
  }

  Future<ProviderProduct> fetchProduct(String productId) async {
    final Map<String, dynamic> response = await _apiClient.getProviderProductById(
      productId,
    );
    return ProviderProduct.fromJson(response);
  }

  Future<ProviderProduct> updateProduct(
    String productId,
    UpdateProviderProductRequest request,
  ) async {
    final Map<String, dynamic> response = await _apiClient.updateProviderProductById(
      productId,
      request.toJson(),
    );
    return ProviderProduct.fromJson(response);
  }

  Future<ProviderProduct> updateStatus(String productId, String status) async {
    final Map<String, dynamic> response = await _apiClient.updateProviderProductStatus(
      productId,
      status,
    );
    return ProviderProduct.fromJson(response);
  }

  Future<ProviderProductImageUploadResponse> uploadProductImage({
    required String productId,
    required String filePath,
    required bool isMain,
  }) async {
    final Map<String, dynamic> response = await _apiClient.uploadProviderProductImage(
      productId: productId,
      filePath: filePath,
      isMain: isMain,
    );
    return ProviderProductImageUploadResponse.fromJson(response);
  }

  Future<void> setMainImage({
    required String productId,
    required String imageKey,
  }) async {
    await _apiClient.setProviderProductMainImage(
      productId: productId,
      imageKey: imageKey,
    );
  }

  Future<void> deleteImage({
    required String productId,
    required String imageKey,
  }) async {
    await _apiClient.deleteProviderProductImage(
      productId: productId,
      imageKey: imageKey,
    );
  }

  static String mapApiError(
    Object error, {
    String fallbackMessage = 'No se pudieron cargar los productos.',
  }) {
    return ProviderServicesRepository.mapApiError(
      error,
      fallbackMessage: fallbackMessage,
    );
  }
}
