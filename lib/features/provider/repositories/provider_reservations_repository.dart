import 'package:dio/dio.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:festum/features/provider/models/product_reservations_response.dart';

class ProviderReservationsRepository {
  ProviderReservationsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ProductReservationSummary>> fetchProducts() async {
    final Map<String, dynamic> response =
        await _apiClient.getProviderProductReservations();
    return ProductReservationsResponse.fromJson(response).items;
  }

  Future<void> deleteProduct(String productId) async {
    await _apiClient.deleteProviderProduct(productId);
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

      return 'No se pudieron cargar las reservaciones.';
    }

    if (error is FormatException) {
      return error.message;
    }

    return 'Ocurrio un error inesperado.';
  }
}
