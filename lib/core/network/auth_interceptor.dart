import 'package:dio/dio.dart';
import 'package:festum/core/services/auth_state_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._authStateService);

  final AuthStateService _authStateService;

  static const Set<String> _publicPaths = <String>{
    '/api/v1/auth/login',
    '/api/v1/auth/register',
    '/health',
  };

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final String path = options.path;
    final String? token = _authStateService.accessToken;

    if (!_publicPaths.contains(path) && token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}
