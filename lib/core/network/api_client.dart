import 'package:dio/dio.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  static const String _authBasePath = '/api/v1/auth';
  static const String _clientBasePath = '/api/v1/client';
  static const String _providersBasePath = '/api/v1/providers';

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
      '$_authBasePath/register',
      data: <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'role': role,
      },
    );

    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '$_authBasePath/login',
      data: <String, dynamic>{
        'email': email,
        'password': password,
      },
    );

    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> me() async {
    final Response<dynamic> response = await _dio.get<dynamic>('$_authBasePath/me');
    return _toMap(response.data);
  }

  Future<Map<String, List<Map<String, dynamic>>>> getClientServicesHome() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_clientBasePath/services/home',
    );

    final Map<String, dynamic> data = _toMap(response.data);
    final Map<String, List<Map<String, dynamic>>> sections =
        <String, List<Map<String, dynamic>>>{};

    for (final MapEntry<String, dynamic> entry in data.entries) {
      sections[entry.key] = _extractItemsList(entry.value);
    }

    return sections;
  }

  Future<List<Map<String, dynamic>>> getClientServicesByCategory({
    required String category,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_clientBasePath/services',
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
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '$_clientBasePath/services/$serviceId',
        queryParameters: <String, dynamic>{'category': category},
      );

      return _toMap(response.data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getClientCartItems() async {
    final Response<dynamic> response = await _dio.get<dynamic>('$_clientBasePath/cart');
    return _extractItemsList(
      response.data,
      keys: const <String>['items', 'cart_items', 'cart', 'results'],
    );
  }

  Future<bool> containsServiceInClientCart({
    required String serviceId,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_clientBasePath/cart/contains/$serviceId',
    );
    final Map<String, dynamic> data = _toMap(response.data);
    return data['contains'] == true;
  }

  Future<bool> addServiceToClientCart({
    required String serviceId,
    required String name,
    required int unitPriceCents,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '$_clientBasePath/cart/items',
      data: <String, dynamic>{
        'service_id': serviceId,
        'name': name,
        'unit_price_cents': unitPriceCents,
      },
    );

    final Map<String, dynamic> data = _toMap(response.data);
    return data['added'] != false;
  }

  Future<Map<String, dynamic>?> removeClientCartItem({
    required String id,
  }) async {
    try {
      final Response<dynamic> response = await _dio.delete<dynamic>(
        '$_clientBasePath/cart/items/$id',
      );
      final Map<String, dynamic> data = _toMap(response.data);
      if (data.isEmpty) {
        return null;
      }
      return data;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> restoreClientCartItem({
    required Map<String, dynamic> item,
    required int index,
  }) async {
    await _dio.post<dynamic>(
      '$_clientBasePath/cart/restore',
      data: <String, dynamic>{
        'item': item,
        'index': index,
      },
    );
  }

  Future<void> clearClientCart() async {
    await _dio.delete<dynamic>('$_clientBasePath/cart');
  }

  Future<List<Map<String, dynamic>>> getClientOrders() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_clientBasePath/orders',
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
      '$_clientBasePath/orders',
      data: payload,
    );
    return _toMap(response.data);
  }

  Future<void> updateClientOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await _dio.patch<dynamic>(
      '$_clientBasePath/orders/$orderId/status',
      data: <String, dynamic>{'status': status},
    );
  }

  Future<Map<String, dynamic>> getProviderHome() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_providersBasePath/me/home',
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> getProviderNotifications() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_providersBasePath/me/notifications',
    );
    return _toMap(response.data);
  }

  Future<void> markProviderNotificationAsRead(String notificationId) async {
    await _dio.patch<dynamic>(
      '$_providersBasePath/me/notifications/$notificationId/read',
    );
  }

  Future<void> markAllProviderNotificationsAsRead() async {
    await _dio.patch<dynamic>('$_providersBasePath/me/notifications/read-all');
  }

  Future<void> clearProviderNotifications() async {
    await _dio.delete<dynamic>('$_providersBasePath/me/notifications');
  }

  Future<Map<String, dynamic>> getProviderBusinessProfile() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_providersBasePath/me/business-profile',
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> upsertProviderBusinessProfile(
    Map<String, dynamic> payload,
  ) async {
    final Response<dynamic> response = await _dio.put<dynamic>(
      '$_providersBasePath/me/business-profile',
      data: payload,
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> uploadProviderBusinessLogo(String filePath) async {
    final String fileName = _fileNameFromPath(filePath);
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final Response<dynamic> response = await _dio.post<dynamic>(
      '$_providersBasePath/me/business-profile/logo',
      data: formData,
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> uploadProviderBusinessPhoto(String filePath) async {
    final String fileName = _fileNameFromPath(filePath);
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final Response<dynamic> response = await _dio.post<dynamic>(
      '$_providersBasePath/me/business-profile/photos',
      data: formData,
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> getProviderProductReservations() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_providersBasePath/me/products/reservations',
    );
    return _toMap(response.data);
  }

  Future<void> deleteProviderProduct(String productId) async {
    await _dio.delete<dynamic>('$_providersBasePath/me/products/$productId');
  }

  Future<Map<String, dynamic>> getProviderServices() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_providersBasePath/me/services',
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> updateProviderServiceStatus(
    String serviceId,
    String status,
  ) async {
    final Response<dynamic> response = await _dio.patch<dynamic>(
      '$_providersBasePath/me/services/$serviceId',
      data: <String, dynamic>{'status': status},
    );
    return _toMap(response.data);
  }

  Future<void> deleteProviderService(String serviceId) async {
    await _dio.delete<dynamic>('$_providersBasePath/me/services/$serviceId');
  }

  List<Map<String, dynamic>> _extractItemsList(
    dynamic source, {
    List<String> keys = const <String>['items'],
  }) {
    if (source is List) {
      return source
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (source is Map) {
      final Map<String, dynamic> map = _toMap(source);
      for (final String key in keys) {
        final dynamic value = map[key];
        if (value is List) {
          return value
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item),
              )
              .toList();
        }
      }
    }

    return <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  String _fileNameFromPath(String filePath) {
    final List<String> segments = filePath.split(RegExp(r'[\\/]'));
    if (segments.isEmpty) {
      return 'upload_file';
    }
    return segments.last.isEmpty ? 'upload_file' : segments.last;
  }
}
