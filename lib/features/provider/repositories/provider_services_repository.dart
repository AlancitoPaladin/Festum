import 'package:dio/dio.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:festum/features/provider/models/provider_service.dart';

class ProviderServicesRepository {
  ProviderServicesRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ProviderService>> fetchServices() async {
    final Map<String, dynamic> response = await _apiClient.getProviderServices();
    return ProviderServicesResponse.fromJson(response).items;
  }

  Future<ProviderService> updateStatus(String serviceId, String status) async {
    final Map<String, dynamic> response = await _apiClient
        .updateProviderServiceStatus(serviceId, status);
    return ProviderService.fromJson(response);
  }

  Future<void> deleteService(String serviceId) async {
    await _apiClient.deleteProviderService(serviceId);
  }

  static String mapApiError(Object error) {
    if (error is DioException) {
      final dynamic data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final dynamic detail = data['detail'] ?? data['message'];
        if (detail is String && detail.trim().isNotEmpty) {
          return detail;
        }
      }

      return 'No se pudieron cargar los servicios.';
    }

    if (error is FormatException) {
      return error.message;
    }

    return 'Ocurrio un error inesperado.';
  }
}
