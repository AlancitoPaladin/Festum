import 'package:dio/dio.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:festum/features/provider/models/provider_order_request.dart';
import 'package:festum/features/provider/models/product_reservations_response.dart';

class ProviderReservationsRepository {
  ProviderReservationsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ProductReservationSummary>> fetchReservationsProducts() async {
    final Map<String, dynamic> response = await _apiClient
        .getProviderProductReservations();
    return ProductReservationsResponse.fromJson(response).items;
  }

  Future<List<ProviderOrderRequest>> fetchPendingOrderRequests() async {
    try {
      final List<Map<String, dynamic>> response = await _apiClient
          .getProviderOrderRequests();
      return response.map(ProviderOrderRequest.fromJson).toList();
    } on DioException catch (error) {
      final int? status = error.response?.statusCode;
      if (status == 404 || status == 405 || status == 501) {
        return const <ProviderOrderRequest>[];
      }
      rethrow;
    }
  }

  Future<void> decideOrderRequest({
    required String requestId,
    required bool accept,
  }) {
    return _apiClient.decideProviderOrderRequest(
      requestId: requestId,
      decision: accept ? 'accepted' : 'rejected',
    );
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

    return 'Ocurrió un error inesperado.';
  }
}
