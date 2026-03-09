import 'package:dio/dio.dart';
import 'package:festum/core/models/account_role.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:festum/features/auth/models/auth_session.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> response = await _apiClient.login(
      email: email,
      password: password,
    );

    return _extractSession(response);
  }

  Future<AuthSession> register({
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

    return _extractSession(response);
  }

  Future<AccountRole> me() async {
    final Map<String, dynamic> response = await _apiClient.me();
    return _extractRoleFromUser(response);
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

  AuthSession _extractSession(Map<String, dynamic> response) {
    final String accessToken = (response['access_token'] ?? '').toString();
    if (accessToken.isEmpty) {
      throw const FormatException('Token inválido en respuesta');
    }

    return AuthSession(
      accessToken: accessToken,
      role: _extractRoleFromUser(response),
      displayName: _extractDisplayNameFromUser(response),
    );
  }

  AccountRole _extractRoleFromUser(Map<String, dynamic> response) {
    final dynamic user = response['user'];
    if (user is! Map<String, dynamic>) {
      throw const FormatException('Usuario inválido en respuesta');
    }

    final String roleValue = (user['role'] ?? '').toString();
    final AccountRole? role = AccountRole.fromStorage(roleValue);
    if (role == null) {
      throw const FormatException('Rol inválido en respuesta');
    }

    return role;
  }

  String? _extractDisplayNameFromUser(Map<String, dynamic> response) {
    final dynamic user = response['user'];
    if (user is! Map<String, dynamic>) {
      return null;
    }

    final String firstName = (user['first_name'] ?? user['firstName'] ?? '')
        .toString()
        .trim();
    final String lastName = (user['last_name'] ?? user['lastName'] ?? '')
        .toString()
        .trim();
    final String fullName = <String>[
      firstName,
      lastName,
    ].where((String part) => part.isNotEmpty).join(' ').trim();

    if (fullName.isNotEmpty) {
      return fullName;
    }

    final String fallbackName = (user['name'] ?? user['username'] ?? '')
        .toString()
        .trim();
    return fallbackName.isEmpty ? null : fallbackName;
  }
}
