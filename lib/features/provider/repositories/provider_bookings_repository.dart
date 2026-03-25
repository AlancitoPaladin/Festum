import 'package:dio/dio.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:festum/features/provider/models/booking.dart';
import 'package:festum/features/provider/models/manual_booking_request.dart';
import 'package:festum/features/provider/models/update_booking_request.dart';

class ProviderBookingsRepository {
  ProviderBookingsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Booking> createManualBooking({
    required String productId,
    required ManualBookingRequest request,
  }) async {
    final Map<String, dynamic> response = await _apiClient.createManualBooking(
      productId: productId,
      body: request.toJson(),
    );
    return Booking.fromJson(response);
  }

  Future<Booking> fetchBookingDetail(String bookingId) async {
    final Map<String, dynamic> response = await _apiClient.getProviderBookingDetail(
      bookingId,
    );
    return Booking.fromJson(response);
  }

  Future<Booking> updateBooking(
    String bookingId,
    UpdateBookingRequest request,
  ) async {
    final Map<String, dynamic> response = await _apiClient.updateProviderBooking(
      bookingId,
      request.toJson(),
    );
    return Booking.fromJson(response);
  }

  Future<Booking> updateBookingStatus(String bookingId, String status) async {
    final Map<String, dynamic> response =
        await _apiClient.updateProviderBookingStatus(bookingId, status);
    return Booking.fromJson(response);
  }

  static String mapApiError(
    Object error, {
    String fallbackMessage = 'No se pudo crear la reserva manual.',
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
