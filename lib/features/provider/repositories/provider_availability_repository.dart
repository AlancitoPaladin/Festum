import 'package:dio/dio.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:festum/features/provider/models/provider_product_availability.dart';

class ProviderAvailabilityRepository {
  ProviderAvailabilityRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ProviderProductAvailabilityMonthResponse> fetchMonth({
    required String productId,
    required int year,
    required int month,
  }) async {
    final Map<String, dynamic> response = await _apiClient
        .getProviderProductAvailability(
          productId: productId,
          year: year,
          month: month,
        );
    return ProviderProductAvailabilityMonthResponse.fromJson(response);
  }

  Future<void> blockDate({
    required String productId,
    required DateTime date,
  }) {
    return _apiClient.blockProviderProductDate(
      productId: productId,
      date: _dateString(date),
    );
  }

  Future<void> unblockDate({
    required String productId,
    required DateTime date,
  }) {
    return _apiClient.unblockProviderProductDate(
      productId: productId,
      date: _dateString(date),
    );
  }

  static String mapApiError(
    Object error, {
    String fallbackMessage = 'No se pudo cargar la disponibilidad.',
  }) {
    if (error is DioException) {
      final dynamic data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final dynamic detail = data['detail'] ?? data['message'];
        if (detail is String && detail.trim().isNotEmpty) {
          return detail;
        }
      }
      return fallbackMessage;
    }

    if (error is FormatException) {
      return error.message;
    }

    return fallbackMessage;
  }
}

String _dateString(DateTime date) {
  final DateTime normalized = DateTime(date.year, date.month, date.day);
  final String month = normalized.month.toString().padLeft(2, '0');
  final String day = normalized.day.toString().padLeft(2, '0');
  return '${normalized.year}-$month-$day';
}
