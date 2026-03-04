import 'package:festum/app/router/app_router.dart';
import 'package:dio/dio.dart';
import 'package:festum/core/config/app_environment.dart';
import 'package:festum/core/models/account_role.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:festum/core/network/auth_interceptor.dart';
import 'package:festum/core/network/session_interceptor.dart';
import 'package:festum/core/services/auth_state_service.dart';
import 'package:festum/core/services/registration_state_service.dart';
import 'package:festum/features/auth/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  if (locator.isRegistered<Dio>()) {
    await locator.reset();
  }

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  locator.registerLazySingleton<SharedPreferences>(
    () => prefs,
  );

  locator.registerLazySingleton<AuthStateService>(
    () => AuthStateService(locator<SharedPreferences>()),
  );

  locator.registerLazySingleton<Dio>(
    () {
      final Dio dio = Dio(
        BaseOptions(
          baseUrl: AppEnvironment.apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          contentType: Headers.jsonContentType,
        ),
      );

      dio.interceptors.add(
        AuthInterceptor(locator<AuthStateService>()),
      );
      dio.interceptors.add(
        SessionInterceptor(locator<AuthStateService>()),
      );

      if (kDebugMode) {
        dio.interceptors.add(
          LogInterceptor(
            requestBody: true,
            responseBody: true,
          ),
        );
      }

      return dio;
    },
  );

  locator.registerLazySingleton<ApiClient>(
    () => ApiClient(locator<Dio>()),
  );
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(locator<ApiClient>()),
  );

  await _validateExistingSession();

  locator.registerLazySingleton<RegistrationStateService>(
    () => RegistrationStateService(locator<SharedPreferences>()),
  );

  locator.registerLazySingleton<AppRouter>(
    () => AppRouter(
      locator<AuthStateService>(),
      locator<RegistrationStateService>(),
    ),
  );
}

Future<void> _validateExistingSession() async {
  final AuthStateService authStateService = locator<AuthStateService>();
  if (!authStateService.isAuthenticated) {
    return;
  }

  try {
    final AccountRole role = await locator<AuthRepository>().me();
    await authStateService.syncRole(role);
  } on DioException catch (error) {
    if (error.response?.statusCode == 401) {
      await authStateService.signOut();
    }
  } on FormatException {
    await authStateService.signOut();
  }
}
