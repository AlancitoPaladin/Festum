import 'package:dio/dio.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  static const String _authBasePath = '/api/v1/auth';
  static const String _clientBasePath = '/api/v1/client';
  static const String _providersBasePath = '/api/v1/providers';
  static const String _notificationsBasePath = '/api/v1/notifications';
  static const Duration _homeServicesReceiveTimeout = Duration(seconds: 30);
  static const Duration _bootstrapReceiveTimeout = Duration(seconds: 30);

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
      data: <String, dynamic>{'email': email, 'password': password},
    );

    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> me() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_authBasePath/me',
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '$_notificationsBasePath/device-token',
      data: <String, dynamic>{'token': token, 'platform': platform},
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> unregisterDeviceToken({
    required String token,
  }) async {
    final Response<dynamic> response = await _dio.delete<dynamic>(
      '$_notificationsBasePath/device-token',
      data: <String, dynamic>{'token': token},
    );
    return _toMap(response.data);
  }

  Future<Map<String, List<Map<String, dynamic>>>>
  getClientServicesHome() async {
    Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        '$_clientBasePath/services/home',
        options: Options(receiveTimeout: _homeServicesReceiveTimeout),
      );
    } on DioException catch (error) {
      if (!_isRetryableHomeError(error)) {
        rethrow;
      }
      await Future<void>.delayed(const Duration(milliseconds: 450));
      response = await _dio.get<dynamic>(
        '$_clientBasePath/services/home',
        options: Options(receiveTimeout: _homeServicesReceiveTimeout),
      );
    }

    final Map<String, dynamic> data = _toMap(response.data);
    final Map<String, List<Map<String, dynamic>>> sections =
        <String, List<Map<String, dynamic>>>{};

    for (final MapEntry<String, dynamic> entry in data.entries) {
      sections[entry.key] = _extractItemsList(entry.value);
    }

    return sections;
  }

  Future<Map<String, dynamic>> getClientBootstrap() async {
    Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        '$_clientBasePath/bootstrap',
        options: Options(receiveTimeout: _bootstrapReceiveTimeout),
      );
    } on DioException catch (error) {
      if (!_isRetryableHomeError(error)) {
        rethrow;
      }
      await Future<void>.delayed(const Duration(milliseconds: 450));
      response = await _dio.get<dynamic>(
        '$_clientBasePath/bootstrap',
        options: Options(receiveTimeout: _bootstrapReceiveTimeout),
      );
    }
    return _toMap(response.data);
  }

  bool _isRetryableHomeError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }
    return false;
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
    final Set<String> attemptedCategories = <String>{};
    final List<String> categoriesToTry = <String>[
      category,
      ..._clientServiceCategoryFallbacks(category),
    ];

    for (final String candidate in categoriesToTry) {
      final String normalized = candidate.trim();
      if (normalized.isEmpty || !attemptedCategories.add(normalized)) {
        continue;
      }
      try {
        final Response<dynamic> response = await _dio.get<dynamic>(
          '$_clientBasePath/services/$serviceId',
          queryParameters: <String, dynamic>{'category': normalized},
        );
        return _toMap(response.data);
      } on DioException catch (error) {
        if (error.response?.statusCode == 404) {
          continue;
        }
        rethrow;
      }
    }

    return null;
  }

  List<String> _clientServiceCategoryFallbacks(String category) {
    switch (category.trim().toLowerCase()) {
      case 'salones-sociales':
        return const <String>['venue'];
      case 'venue':
        return const <String>['salones-sociales'];
      case 'mobiliario':
        return const <String>['furniture', 'equipment'];
      case 'furniture':
      case 'equipment':
        return const <String>['mobiliario'];
      case 'banquetes':
        return const <String>['banquet'];
      case 'banquet':
        return const <String>['banquetes'];
      case 'entretenimiento':
        return const <String>['entertainment'];
      case 'entertainment':
        return const <String>['entretenimiento'];
      case 'decoracion':
        return const <String>['decoration'];
      case 'decoration':
        return const <String>['decoracion'];
      case 'fotografia':
        return const <String>['photography'];
      case 'photography':
        return const <String>['fotografia'];
      default:
        return const <String>[];
    }
  }

  Future<List<Map<String, dynamic>>> getClientCartItems() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_clientBasePath/cart',
    );
    return _extractItemsList(
      response.data,
      keys: const <String>['items', 'cart_items', 'cart', 'results'],
    );
  }

  Future<bool> containsServiceInClientCart({required String serviceId}) async {
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
    String? productId,
    String? productName,
    List<String>? selectedProductIds,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'service_id': serviceId,
      'name': name,
      'unit_price_cents': unitPriceCents,
      if (productId != null && productId.trim().isNotEmpty)
        'product_id': productId.trim(),
      if (productName != null && productName.trim().isNotEmpty)
        'product_name': productName.trim(),
      if (selectedProductIds != null && selectedProductIds.isNotEmpty)
        'selected_product_ids': selectedProductIds
            .map((String value) => value.trim())
            .where((String value) => value.isNotEmpty)
            .toList(),
    };
    final Response<dynamic> response = await _dio.post<dynamic>(
      '$_clientBasePath/cart/items',
      data: payload,
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
      data: <String, dynamic>{'item': item, 'index': index},
    );
  }

  Future<void> clearClientCart() async {
    await _dio.delete<dynamic>('$_clientBasePath/cart');
  }

  Future<List<Map<String, dynamic>>> getClientOrders({
    bool includeItems = false,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_clientBasePath/orders',
      queryParameters: <String, dynamic>{
        if (includeItems) 'include_items': true,
      },
    );
    return _extractItemsList(
      response.data,
      keys: const <String>['items', 'orders', 'results'],
    );
  }

  Future<Set<String>> getClientActiveOrderServiceIds() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_clientBasePath/orders/active-service-ids',
    );
    final Map<String, dynamic> data = _toMap(response.data);
    final dynamic raw = data['service_ids'] ?? data['items'] ?? <dynamic>[];
    if (raw is! List) {
      return <String>{};
    }
    return raw
        .map((dynamic value) => value.toString().trim())
        .where((String value) => value.isNotEmpty)
        .toSet();
  }

  Future<Map<String, dynamic>?> getClientOrderById({
    required String orderId,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '$_clientBasePath/orders/$orderId',
      );
      return _toMap(response.data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
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

  Future<Map<String, dynamic>> checkoutClientOrder() async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '$_clientBasePath/orders/checkout',
      data: const <String, dynamic>{},
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> submitClientOrderRequest({
    required Map<String, dynamic> payload,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '$_clientBasePath/orders/requests',
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

  Future<Map<String, dynamic>> uploadProviderBusinessLogo(
    String filePath,
  ) async {
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

  Future<Map<String, dynamic>> uploadProviderBusinessPhoto(
    String filePath,
  ) async {
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

  Future<List<Map<String, dynamic>>> getProviderOrderRequests() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_providersBasePath/me/order-requests',
    );
    return _extractItemsList(
      response.data,
      keys: const <String>['items', 'requests', 'results'],
    );
  }

  Future<void> decideProviderOrderRequest({
    required String requestId,
    required String decision,
  }) async {
    await _dio.patch<dynamic>(
      '$_providersBasePath/me/order-requests/$requestId/decision',
      data: <String, dynamic>{'decision': decision},
    );
  }

  Future<Map<String, dynamic>> getProviderProductAvailability({
    required String productId,
    required int year,
    required int month,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_providersBasePath/me/products/$productId/availability',
      queryParameters: <String, dynamic>{'year': year, 'month': month},
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> createManualBooking({
    required String productId,
    required Map<String, dynamic> body,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '$_providersBasePath/me/products/$productId/bookings/manual',
      data: body,
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> getProviderBookingDetail(
    String bookingId,
  ) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_providersBasePath/me/bookings/$bookingId',
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> updateProviderBooking(
    String bookingId,
    Map<String, dynamic> body,
  ) async {
    final Response<dynamic> response = await _dio.patch<dynamic>(
      '$_providersBasePath/me/bookings/$bookingId',
      data: body,
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> updateProviderBookingStatus(
    String bookingId,
    String status,
  ) async {
    final Response<dynamic> response = await _dio.patch<dynamic>(
      '$_providersBasePath/me/bookings/$bookingId/status',
      data: <String, dynamic>{'status': status},
    );
    return _toMap(response.data);
  }

  Future<void> blockProviderProductDate({
    required String productId,
    required String date,
  }) async {
    await _dio.post<dynamic>(
      '$_providersBasePath/me/products/$productId/availability/blocks',
      data: <String, dynamic>{'date': date},
    );
  }

  Future<void> unblockProviderProductDate({
    required String productId,
    required String date,
  }) async {
    await _dio.delete<dynamic>(
      '$_providersBasePath/me/products/$productId/availability/blocks',
      data: <String, dynamic>{'date': date},
    );
  }

  Future<Map<String, dynamic>> getProviderServiceProductsById(
    String serviceId,
  ) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_providersBasePath/me/services/$serviceId/products',
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> createProviderProduct(
    String serviceId,
    Map<String, dynamic> payload,
  ) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '$_providersBasePath/me/services/$serviceId/products',
      data: payload,
    );
    return _toMap(response.data);
  }

  Future<void> deleteProviderProduct(String productId) async {
    await _dio.delete<dynamic>('$_providersBasePath/me/products/$productId');
  }

  Future<Map<String, dynamic>> getProviderProductById(String productId) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_providersBasePath/me/products/$productId',
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> updateProviderProductById(
    String productId,
    Map<String, dynamic> payload,
  ) async {
    final Response<dynamic> response = await _dio.patch<dynamic>(
      '$_providersBasePath/me/products/$productId',
      data: payload,
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> updateProviderProductStatus(
    String productId,
    String status,
  ) async {
    final Response<dynamic> response = await _dio.patch<dynamic>(
      '$_providersBasePath/me/products/$productId/status',
      data: <String, dynamic>{'status': status},
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> uploadProviderProductImage({
    required String productId,
    required String filePath,
    required bool isMain,
  }) async {
    final String fileName = _fileNameFromPath(filePath);
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      'is_main': isMain,
    });

    final Response<dynamic> response = await _dio.post<dynamic>(
      '$_providersBasePath/me/products/$productId/images',
      data: formData,
    );
    return _toMap(response.data);
  }

  Future<void> setProviderProductMainImage({
    required String productId,
    required String imageKey,
  }) async {
    await _dio.patch<dynamic>(
      '$_providersBasePath/me/products/$productId/images/main',
      data: <String, dynamic>{'image_key': imageKey},
    );
  }

  Future<void> deleteProviderProductImage({
    required String productId,
    required String imageKey,
  }) async {
    await _dio.delete<dynamic>(
      '$_providersBasePath/me/products/$productId/images',
      data: <String, dynamic>{'image_key': imageKey},
    );
  }

  Future<Map<String, dynamic>> getProviderServices() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_providersBasePath/me/services',
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> getClientProductAvailability({
    required String productId,
    required int year,
    required int month,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$_clientBasePath/products/$productId/availability',
      queryParameters: <String, dynamic>{'year': year, 'month': month},
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> createProviderService(
    Map<String, dynamic> payload,
  ) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '$_providersBasePath/me/services',
      data: payload,
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> updateProviderService(
    String serviceId,
    Map<String, dynamic> payload,
  ) async {
    final Response<dynamic> response = await _dio.patch<dynamic>(
      '$_providersBasePath/me/services/$serviceId',
      data: payload,
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> updateProviderServiceStatus(
    String serviceId,
    String status,
  ) async {
    final Response<dynamic> response = await _dio.patch<dynamic>(
      '$_providersBasePath/me/services/$serviceId/status',
      data: <String, dynamic>{'status': status},
    );
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> uploadProviderServiceImage({
    required String serviceId,
    required String filePath,
    required bool isMain,
  }) async {
    final String fileName = _fileNameFromPath(filePath);
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      'is_main': isMain,
    });

    final Response<dynamic> response = await _dio.post<dynamic>(
      '$_providersBasePath/me/services/$serviceId/images',
      data: formData,
    );
    return _toMap(response.data);
  }

  Future<void> setProviderServiceMainImage({
    required String serviceId,
    required String imageKey,
  }) async {
    await _dio.patch<dynamic>(
      '$_providersBasePath/me/services/$serviceId/images/main',
      data: <String, dynamic>{'image_key': imageKey},
    );
  }

  Future<void> reorderProviderServiceImages({
    required String serviceId,
    required List<String> imageKeys,
  }) async {
    await _dio.patch<dynamic>(
      '$_providersBasePath/me/services/$serviceId/images/reorder',
      data: <String, dynamic>{'image_keys': imageKeys},
    );
  }

  Future<void> deleteProviderServiceImage({
    required String serviceId,
    required String imageKey,
  }) async {
    await _dio.delete<dynamic>(
      '$_providersBasePath/me/services/$serviceId/images',
      data: <String, dynamic>{'image_key': imageKey},
    );
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
