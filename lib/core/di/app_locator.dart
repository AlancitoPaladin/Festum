import 'package:dio/dio.dart';
import 'package:festum/core/config/app_environment.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  if (locator.isRegistered<Dio>()) {
    await locator.reset();
  }

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
}
