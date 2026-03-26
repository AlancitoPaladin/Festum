import 'package:dio/dio.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:festum/features/provider/models/provider_asset_upload_response.dart';
import 'package:festum/features/provider/models/provider_business_profile.dart';

class ProviderBusinessRepository {
  ProviderBusinessRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ProviderBusinessProfile> fetchProfile() async {
    final Map<String, dynamic> response = await _apiClient
        .getProviderBusinessProfile();
    return ProviderBusinessProfile.fromJson(response);
  }

  Future<ProviderBusinessProfile> saveProfile(
    ProviderBusinessProfile profile,
  ) async {
    final Map<String, dynamic> response = await _apiClient
        .upsertProviderBusinessProfile(profile.toJson());
    return ProviderBusinessProfile.fromJson(response);
  }

  Future<ProviderAssetUploadResponse> uploadLogo(String filePath) async {
    final Map<String, dynamic> response = await _apiClient
        .uploadProviderBusinessLogo(filePath);
    return ProviderAssetUploadResponse.fromJson(response);
  }

  Future<ProviderAssetUploadResponse> uploadPhoto(String filePath) async {
    final Map<String, dynamic> response = await _apiClient
        .uploadProviderBusinessPhoto(filePath);
    return ProviderAssetUploadResponse.fromJson(response);
  }

  static String mapApiError(Object error) {
    if (error is DioException) {
      final dynamic data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final dynamic detail = data['detail'];
        if (detail is String && detail.trim().isNotEmpty) {
          return detail;
        }
      }

      return 'No se pudo guardar la información del negocio.';
    }

    if (error is FormatException) {
      return error.message;
    }

    return 'Ocurrió un error inesperado.';
  }
}
