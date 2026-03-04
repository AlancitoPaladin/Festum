import 'package:dio/dio.dart';
import 'package:festum/core/services/auth_state_service.dart';

class SessionInterceptor extends Interceptor {
  SessionInterceptor(this._authStateService);

  final AuthStateService _authStateService;

  static const Set<String> _publicPaths = <String>{
    '/api/v1/auth/login',
    '/api/v1/auth/register',
    '/health',
  };

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final int? statusCode = err.response?.statusCode;
    final String path = err.requestOptions.path;

    final bool shouldClearSession = statusCode == 401 &&
        !_publicPaths.contains(path) &&
        _authStateService.isAuthenticated;

    if (shouldClearSession) {
      await _authStateService.signOut();
    }

    handler.next(err);
  }
}
