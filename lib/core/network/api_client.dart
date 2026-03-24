import 'package:dio/dio.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;
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
      data: <String, dynamic>{
        'email': email,
        'password': password,
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> me() async {
    final Response<dynamic> response =
        await _dio.get<dynamic>('/api/v1/auth/me');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getProviderHome() async {
    return _getProviderMap('/me/home');
  }

  Future<Map<String, dynamic>> getProviderNotifications() async {
    return _getProviderMap('/me/notifications');
  }

  Future<Map<String, dynamic>> markProviderNotificationAsRead(
    String notificationId,
  ) async {
    return _patchProviderMap('/me/notifications/$notificationId/read');
  }

  Future<Map<String, dynamic>> markAllProviderNotificationsAsRead() async {
    return _patchProviderMap('/me/notifications/read-all');
  }

  Future<Map<String, dynamic>> clearProviderNotifications() async {
    return _deleteProviderMap('/me/notifications');
  }

  Future<Map<String, dynamic>> getProviderBusinessProfile() async {
    return _getProviderMap('/me/business-profile');
  }

  Future<Map<String, dynamic>> upsertProviderBusinessProfile(
    Map<String, dynamic> body,
  ) async {
    return _putProviderMap('/me/business-profile', body);
  }

  Future<Map<String, dynamic>> uploadProviderBusinessLogo(
    String filePath,
  ) async {
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(filePath),
    });

    return _postProviderMap('/me/business-profile/logo', formData);
  }

  Future<Map<String, dynamic>> uploadProviderBusinessPhoto(
    String filePath,
  ) async {
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(filePath),
    });

    return _postProviderMap('/me/business-profile/photos', formData);
  }

  Future<Map<String, dynamic>> getProviderProductReservations() async {
    return _getProviderMap('/me/products/reservations');
  }

  Future<void> deleteProviderProduct(String productId) async {
    await _requestProviderEndpoint(
      (String basePath) => _dio.delete<dynamic>('$basePath/me/products/$productId'),
    );
  }

  Future<Map<String, dynamic>> getProviderServices() async {
    return _getProviderMap('/me/services');
  }

  Future<Map<String, dynamic>> updateProviderServiceStatus(
    String serviceId,
    String status,
  ) async {
    return _patchProviderMap(
      '/me/services/$serviceId',
      data: <String, dynamic>{'status': status},
    );
  }

  Future<void> deleteProviderService(String serviceId) async {
    await _requestProviderEndpoint(
      (String basePath) => _dio.delete<dynamic>('$basePath/me/services/$serviceId'),
    );
  }

  Future<Map<String, dynamic>> _getProviderMap(String suffix) async {
    final Response<dynamic> response = await _requestProviderEndpoint(
      (String basePath) => _dio.get<dynamic>('$basePath$suffix'),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> _patchProviderMap(
    String suffix, {
    Object? data,
  }) async {
    final Response<dynamic> response = await _requestProviderEndpoint(
      (String basePath) => _dio.patch<dynamic>('$basePath$suffix', data: data),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> _deleteProviderMap(String suffix) async {
    final Response<dynamic> response = await _requestProviderEndpoint(
      (String basePath) => _dio.delete<dynamic>('$basePath$suffix'),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> _putProviderMap(
    String suffix,
    Map<String, dynamic> body,
  ) async {
    final Response<dynamic> response = await _requestProviderEndpoint(
      (String basePath) => _dio.put<dynamic>('$basePath$suffix', data: body),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> _postProviderMap(
    String suffix,
    Object data,
  ) async {
    final Response<dynamic> response = await _requestProviderEndpoint(
      (String basePath) => _dio.post<dynamic>('$basePath$suffix', data: data),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Response<dynamic>> _requestProviderEndpoint(
    Future<Response<dynamic>> Function(String basePath) request,
  ) async {
    return request(_providersBasePath);
  }
}
