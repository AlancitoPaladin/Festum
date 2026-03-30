import 'package:dio/dio.dart';

class ApiErrorMapper {
  const ApiErrorMapper._();

  static String toUserMessage(
    Object error, {
    required String fallback,
    Map<String, String> codeOverrides = const <String, String>{},
    Map<int, String> statusOverrides = const <int, String>{},
  }) {
    if (error is DioException) {
      final _ParsedApiError parsed = _parse(error);

      final String? byCodeOverride = codeOverrides[parsed.code];
      if (byCodeOverride != null && byCodeOverride.trim().isNotEmpty) {
        return byCodeOverride;
      }

      final String? byCode = _defaultMessageByCode(parsed.code);
      if (byCode != null) {
        return byCode;
      }

      final String? byStatusOverride = statusOverrides[parsed.statusCode];
      if (byStatusOverride != null && byStatusOverride.trim().isNotEmpty) {
        return byStatusOverride;
      }

      final String? byStatus = _defaultMessageByStatus(parsed.statusCode);
      if (byStatus != null) {
        return byStatus;
      }

      if (parsed.detail.trim().isNotEmpty) {
        return parsed.detail.trim();
      }
      if (parsed.message.trim().isNotEmpty) {
        return parsed.message.trim();
      }

      final String? byType = _defaultMessageByDioType(error.type);
      if (byType != null) {
        return byType;
      }

      return fallback;
    }

    if (error is FormatException) {
      return error.message.trim().isEmpty ? fallback : error.message.trim();
    }

    return fallback;
  }

  static _ParsedApiError _parse(DioException error) {
    final int? status = error.response?.statusCode;
    String code = '';
    String detail = '';
    String message = '';

    final dynamic data = error.response?.data;
    if (data is Map<String, dynamic>) {
      code = (data['code'] ?? '').toString().trim();
      detail = (data['detail'] ?? data['error'] ?? '').toString().trim();
      message = (data['message'] ?? '').toString().trim();
    } else if (data is Map) {
      final Map<String, dynamic> normalized = Map<String, dynamic>.from(data);
      code = (normalized['code'] ?? '').toString().trim();
      detail = (normalized['detail'] ?? normalized['error'] ?? '')
          .toString()
          .trim();
      message = (normalized['message'] ?? '').toString().trim();
    } else if (data is String) {
      detail = data.trim();
    }

    return _ParsedApiError(
      statusCode: status,
      code: code,
      detail: detail,
      message: message,
    );
  }

  static String? _defaultMessageByCode(String code) {
    switch (code.trim().toUpperCase()) {
      case 'CART_DUPLICATE_ITEM':
        return 'Este servicio ya está en el carrito.';
      case 'CHECKOUT_EMPTY_CART':
        return 'El carrito está vacío. Agrega servicios antes de continuar.';
      case 'PRODUCT_REQUIRED':
        return 'Debes seleccionar al menos un producto para este servicio.';
      case 'INVALID_SELECTED_PRODUCTS':
        return 'La selección de productos no es válida. Revisa tu elección.';
      case 'SERVICE_NOT_AVAILABLE':
        return 'Este servicio ya no está disponible por el momento.';
      case 'ORDER_INVALID_TRANSITION':
        return 'La orden cambió de estado y la acción ya no es válida.';
      case 'FORBIDDEN':
        return 'No tienes permisos para realizar esta acción.';
      default:
        return null;
    }
  }

  static String? _defaultMessageByStatus(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'La solicitud no es válida. Revisa la información.';
      case 401:
        return 'Tu sesión expiró. Inicia sesión nuevamente.';
      case 403:
        return 'No tienes permisos para realizar esta acción.';
      case 404:
        return 'No encontramos el recurso solicitado.';
      case 409:
        return 'El recurso cambió de estado. Actualiza e intenta de nuevo.';
      case 422:
        return 'No se pudo procesar la solicitud. Revisa los datos enviados.';
      case 429:
        return 'Demasiadas solicitudes. Intenta de nuevo en unos segundos.';
      case 500:
        return 'El servidor presentó un error. Intenta nuevamente.';
      case 502:
      case 503:
      case 504:
        return 'El servicio no está disponible temporalmente. Intenta más tarde.';
      default:
        return null;
    }
  }

  static String? _defaultMessageByDioType(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'La conexión tardó demasiado. Verifica tu red e inténtalo de nuevo.';
      case DioExceptionType.connectionError:
        return 'No pudimos conectarnos al servidor. Verifica tu conexión.';
      case DioExceptionType.cancel:
        return 'La solicitud fue cancelada.';
      case DioExceptionType.unknown:
      case DioExceptionType.badResponse:
      case DioExceptionType.badCertificate:
        return null;
    }
  }
}

class _ParsedApiError {
  const _ParsedApiError({
    required this.statusCode,
    required this.code,
    required this.detail,
    required this.message,
  });

  final int? statusCode;
  final String code;
  final String detail;
  final String message;
}
