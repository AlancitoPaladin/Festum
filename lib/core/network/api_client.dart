import 'package:dio/dio.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> healthCheck() {
    return _dio.get<dynamic>('/health');
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/v1/auth/register',
      data: <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'role': role,
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/v1/auth/login',
      data: <String, dynamic>{'email': email, 'password': password},
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> me() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/api/v1/auth/me',
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<Map<String, dynamic>>> getClientOrders() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/api/v1/client/orders',
    );
    return _extractItemsList(
      response.data,
      keys: const <String>['items', 'orders', 'results'],
    );
  }

  Future<Map<String, dynamic>> createClientOrder({
    required Map<String, dynamic> payload,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/v1/client/orders',
      data: payload,
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> updateClientOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await _dio.patch<dynamic>(
      '/api/v1/client/orders/$orderId/status',
      data: <String, dynamic>{'status': status},
    );
  }

  Future<List<Map<String, dynamic>>> getClientCartItems() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/api/v1/client/cart',
    );
    return _extractItemsList(
      response.data,
      keys: const <String>['items', 'cart', 'results'],
    );
  }

  Future<bool> containsServiceInClientCart({required String serviceId}) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/api/v1/client/cart/contains/$serviceId',
    );
    final dynamic payload = response.data;
    if (payload is bool) {
      return payload;
    }
    if (payload is Map) {
      final dynamic directContains = payload['contains'];
      if (directContains is bool) {
        return directContains;
      }
      final dynamic exists = payload['exists'];
      if (exists is bool) {
        return exists;
      }
      final dynamic inCart = payload['in_cart'];
      if (inCart is bool) {
        return inCart;
      }
    }
    return false;
  }

  Future<bool> addServiceToClientCart({
    required String serviceId,
    required String name,
    required int unitPriceCents,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/v1/client/cart/items',
      data: <String, dynamic>{
        'service_id': serviceId,
        'name': name,
        'unit_price_cents': unitPriceCents,
      },
    );
    final int? statusCode = response.statusCode;
    if (statusCode == 200 || statusCode == 201) {
      final dynamic payload = response.data;
      if (payload == null || payload is List) {
        return true;
      }
      if (payload is Map) {
        final dynamic added = payload['added'];
        if (added is bool) {
          return added;
        }
        final dynamic created = payload['created'];
        if (created is bool) {
          return created;
        }
        final dynamic ok = payload['ok'];
        if (ok is bool) {
          return ok;
        }
        if (payload.containsKey('item')) {
          return true;
        }
      }
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> removeClientCartItem({
    required String id,
  }) async {
    final Response<dynamic> response = await _dio.delete<dynamic>(
      '/api/v1/client/cart/items/$id',
    );
    final dynamic data = response.data;
    if (data is Map) {
      final Map<String, dynamic> payload = Map<String, dynamic>.from(data);
      final dynamic nestedItem = payload['item'];
      if (nestedItem is Map) {
        return Map<String, dynamic>.from(nestedItem);
      }
      return payload;
    }
    return null;
  }

  Future<void> restoreClientCartItem({
    required Map<String, dynamic> item,
    required int index,
  }) async {
    await _dio.post<dynamic>(
      '/api/v1/client/cart/restore',
      data: <String, dynamic>{'item': item, 'index': index},
    );
  }

  Future<void> clearClientCart() async {
    await _dio.delete<dynamic>('/api/v1/client/cart');
  }

  Future<Map<String, List<Map<String, dynamic>>>>
  getClientServicesHome() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/api/v1/client/services/home',
    );
    final dynamic payload = response.data;
    if (payload is! Map) {
      return <String, List<Map<String, dynamic>>>{};
    }

    final Map<String, List<Map<String, dynamic>>> result =
        <String, List<Map<String, dynamic>>>{};
    for (final MapEntry<dynamic, dynamic> entry in payload.entries) {
      if (entry.key is! String || entry.value is! List) {
        continue;
      }
      final List<Map<String, dynamic>> mapped = (entry.value as List)
          .whereType<Map>()
          .map((Map item) => Map<String, dynamic>.from(item))
          .toList();
      result[entry.key as String] = mapped;
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> getClientServicesByCategory({
    required String category,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/api/v1/client/services',
      queryParameters: <String, dynamic>{'category': category},
    );
    return _extractItemsList(
      response.data,
      keys: const <String>['items', 'services', 'results'],
    );
  }

  Future<Map<String, dynamic>?> getClientServiceById({
    required String category,
    required String serviceId,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/api/v1/client/services/$serviceId',
      queryParameters: <String, dynamic>{'category': category},
    );
    final dynamic payload = response.data;
    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }
    return null;
  }

  List<Map<String, dynamic>> _extractItemsList(
    dynamic payload, {
    required List<String> keys,
  }) {
    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((Map item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (payload is Map) {
      for (final String key in keys) {
        final dynamic value = payload[key];
        if (value is List) {
          return value
              .whereType<Map>()
              .map((Map item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
    }

    return <Map<String, dynamic>>[];
  }
}
