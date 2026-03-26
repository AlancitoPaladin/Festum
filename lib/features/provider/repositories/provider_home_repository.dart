import 'package:dio/dio.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:festum/features/provider/models/provider_home_response.dart';
import 'package:festum/features/provider/models/provider_notifications_response.dart';

class ProviderHomeRepository {
  ProviderHomeRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ProviderHomeResponse> fetchHome() async {
    final Map<String, dynamic> response = await _apiClient.getProviderHome();
    return ProviderHomeResponse.fromJson(response);
  }

  Future<ProviderNotificationsResponse> fetchNotifications() async {
    final Map<String, dynamic> response = await _apiClient
        .getProviderNotifications();
    return ProviderNotificationsResponse.fromJson(response);
  }

  Future<void> markAsRead(String notificationId) async {
    await _apiClient.markProviderNotificationAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    await _apiClient.markAllProviderNotificationsAsRead();
  }

  Future<void> clearAll() async {
    await _apiClient.clearProviderNotifications();
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

      return 'No se pudo cargar el inicio del proveedor.';
    }

    if (error is FormatException) {
      return error.message;
    }

    return 'Ocurrió un error inesperado.';
  }
}
