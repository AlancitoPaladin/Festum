import 'package:dio/dio.dart';
import 'package:festum/core/network/api_client.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> response = await _apiClient.login(
      email: email,
      password: password,
    );

    return _extractToken(response);
  }

  Future<String> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    final Map<String, dynamic> response = await _apiClient.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      role: role,
    );

    return _extractToken(response);
  }

  Future<void> me() async {
    await _apiClient.me();
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

      return 'Error de conexión con la API. Verifica servidor y credenciales.';
    }

    if (error is FormatException) {
      return error.message;
    }

    return 'Ocurrió un error inesperado.';
  }

  String _extractToken(Map<String, dynamic> response) {
    final String accessToken = (response['access_token'] ?? '').toString();
    if (accessToken.isEmpty) {
      throw const FormatException('Token inválido en respuesta');
    }
    return accessToken;
  }
}
