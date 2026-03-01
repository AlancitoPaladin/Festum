import 'package:dio/dio.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  locator.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
      ),
    ),
  );

  locator.registerLazySingleton<ApiClient>(
    () => ApiClient(locator<Dio>()),
  );
}
