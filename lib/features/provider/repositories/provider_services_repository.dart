import 'package:dio/dio.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:festum/features/provider/models/provider_request_error.dart';
import 'package:festum/features/provider/models/provider_service_image_upload_response.dart';
import 'package:festum/features/provider/models/provider_service.dart';
import 'package:festum/features/provider/models/provider_service_upsert_request.dart';

class ProviderServicesRepository {
  ProviderServicesRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ProviderService>> fetchServices() async {
    final Map<String, dynamic> response = await _apiClient.getProviderServices();
    return ProviderServicesResponse.fromJson(response).items;
  }

  Future<ProviderService> createService(
    ProviderServiceUpsertRequest request,
  ) async {
    final Map<String, dynamic> response = await _apiClient.createProviderService(
      request.toJson(),
    );
    return ProviderService.fromJson(response);
  }

  Future<ProviderService> updateService({
    required String serviceId,
    required ProviderServiceUpsertRequest request,
  }) async {
    final Map<String, dynamic> response = await _apiClient.updateProviderService(
      serviceId,
      request.toJson(),
    );
    return ProviderService.fromJson(response);
  }

  Future<ProviderService> updateStatus(String serviceId, String status) async {
    final Map<String, dynamic> response = await _apiClient
        .updateProviderServiceStatus(serviceId, status);
    return ProviderService.fromJson(response);
  }

  Future<void> deleteService(String serviceId) async {
    await _apiClient.deleteProviderService(serviceId);
  }

  Future<ProviderServiceImageUploadResponse> uploadServiceImage({
    required String serviceId,
    required String filePath,
    required bool isMain,
  }) async {
    final Map<String, dynamic> response = await _apiClient.uploadProviderServiceImage(
      serviceId: serviceId,
      filePath: filePath,
      isMain: isMain,
    );
    return ProviderServiceImageUploadResponse.fromJson(response);
  }

  Future<void> setMainImage({
    required String serviceId,
    required String imageKey,
  }) async {
    await _apiClient.setProviderServiceMainImage(
      serviceId: serviceId,
      imageKey: imageKey,
    );
  }

  Future<void> reorderImages({
    required String serviceId,
    required List<String> imageKeys,
  }) async {
    await _apiClient.reorderProviderServiceImages(
      serviceId: serviceId,
      imageKeys: imageKeys,
    );
  }

  Future<void> deleteImage({
    required String serviceId,
    required String imageKey,
  }) async {
    await _apiClient.deleteProviderServiceImage(
      serviceId: serviceId,
      imageKey: imageKey,
    );
  }

  static ProviderRequestError mapRequestError(
    Object error, {
    String fallbackMessage = 'No se pudo guardar el servicio.',
  }) {
    if (error is DioException) {
      final dynamic data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final Map<String, String> fieldErrors = _extractFieldErrors(data);
        final String message = _extractMessage(
          data,
          fallbackMessage: fallbackMessage,
        );
        return ProviderRequestError(
          message: message,
          fieldErrors: fieldErrors,
        );
      }

      return ProviderRequestError(message: fallbackMessage);
    }

    if (error is FormatException) {
      return ProviderRequestError(message: error.message);
    }

    return ProviderRequestError(message: 'Ocurrio un error inesperado.');
  }

  static String mapApiError(
    Object error, {
    String fallbackMessage = 'No se pudieron cargar los servicios.',
  }) {
    return mapRequestError(
      error,
      fallbackMessage: fallbackMessage,
    ).message;
  }

  static String _extractMessage(
    Map<String, dynamic> data, {
    required String fallbackMessage,
  }) {
    final dynamic detail = data['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail.trim();
    }

    final dynamic message = data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }

    if (detail is List) {
      final List<String> messages = detail
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => (item['msg'] ?? '').toString())
          .where((String item) => item.trim().isNotEmpty)
          .toList();
      if (messages.isNotEmpty) {
        return messages.first;
      }
    }

    return fallbackMessage;
  }

  static Map<String, String> _extractFieldErrors(Map<String, dynamic> data) {
    final Map<String, String> errors = <String, String>{};

    final dynamic detail = data['detail'];
    if (detail is List) {
      for (final dynamic item in detail) {
        if (item is! Map) {
          continue;
        }
        final List<dynamic> rawLocation =
            item['loc'] as List<dynamic>? ?? <dynamic>[];
        if (rawLocation.isEmpty) {
          continue;
        }
        final String field = rawLocation.last.toString();
        final String message = (item['msg'] ?? '').toString().trim();
        if (field.isEmpty || message.isEmpty) {
          continue;
        }
        errors[field] = message;
      }
    }

    final dynamic backendErrors = data['errors'];
    if (backendErrors is Map) {
      backendErrors.forEach((dynamic key, dynamic value) {
        final String field = key.toString().trim();
        if (field.isEmpty) {
          return;
        }
        if (value is List && value.isNotEmpty) {
          errors[field] = value.first.toString();
          return;
        }
        final String message = value?.toString().trim() ?? '';
        if (message.isNotEmpty) {
          errors[field] = message;
        }
      });
    }

    return errors;
  }
}
