import 'package:festum/app/router/app_router.dart';
import 'package:dio/dio.dart';
import 'package:festum/core/config/app_environment.dart';
import 'package:festum/core/models/account_role.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:festum/core/network/auth_interceptor.dart';
import 'package:festum/core/network/session_interceptor.dart';
import 'package:festum/core/services/auth_state_service.dart';
import 'package:festum/core/services/provider_business_info_state_service.dart';
import 'package:festum/core/services/registration_state_service.dart';
import 'package:festum/features/auth/repositories/auth_repository.dart';
import 'package:festum/features/client/repositories/client_cart_repository.dart';
import 'package:festum/features/client/repositories/client_orders_repository.dart';
import 'package:festum/features/client/repositories/client_services_repository.dart';
import 'package:festum/features/client/repositories/mock/mock_client_cart_repository.dart';
import 'package:festum/features/client/repositories/mock/mock_client_orders_repository.dart';
import 'package:festum/features/client/repositories/mock/mock_client_services_repository.dart';
import 'package:festum/features/client/services/client_tab_ui_state_service.dart';
import 'package:festum/features/client/usecases/get_client_cart_items_use_case.dart';
import 'package:festum/features/client/usecases/get_client_home_sections_use_case.dart';
import 'package:festum/features/client/usecases/get_client_orders_use_case.dart';
import 'package:festum/features/client/usecases/get_client_service_by_id_use_case.dart';
import 'package:festum/features/client/usecases/get_services_by_category_use_case.dart';
import 'package:festum/features/client/usecases/remove_client_cart_item_use_case.dart';
import 'package:festum/features/client/usecases/restore_client_cart_item_use_case.dart';
import 'package:festum/features/client/usecases/update_client_cart_quantity_use_case.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  if (locator.isRegistered<Dio>()) {
    await locator.reset();
  }

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  locator.registerLazySingleton<SharedPreferences>(() => prefs);

  locator.registerLazySingleton<AuthStateService>(
    () => AuthStateService(locator<SharedPreferences>()),
  );

  locator.registerLazySingleton<ProviderBusinessInfoStateService>(
    () => ProviderBusinessInfoStateService(locator<SharedPreferences>()),
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

    dio.interceptors.add(AuthInterceptor(locator<AuthStateService>()));
    dio.interceptors.add(SessionInterceptor(locator<AuthStateService>()));

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return dio;
  });

  locator.registerLazySingleton<ApiClient>(() => ApiClient(locator<Dio>()));
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(locator<ApiClient>()),
  );

  locator.registerLazySingleton<ClientServicesRepository>(
    MockClientServicesRepository.new,
  );
  locator.registerLazySingleton<ClientOrdersRepository>(
    MockClientOrdersRepository.new,
  );
  locator.registerLazySingleton<ClientCartRepository>(
    MockClientCartRepository.new,
  );

  locator.registerLazySingleton<GetClientHomeSectionsUseCase>(
    () => GetClientHomeSectionsUseCase(locator<ClientServicesRepository>()),
  );
  locator.registerLazySingleton<GetServicesByCategoryUseCase>(
    () => GetServicesByCategoryUseCase(locator<ClientServicesRepository>()),
  );
  locator.registerLazySingleton<GetClientServiceByIdUseCase>(
    () => GetClientServiceByIdUseCase(locator<ClientServicesRepository>()),
  );
  locator.registerLazySingleton<GetClientOrdersUseCase>(
    () => GetClientOrdersUseCase(locator<ClientOrdersRepository>()),
  );
  locator.registerLazySingleton<GetClientCartItemsUseCase>(
    () => GetClientCartItemsUseCase(locator<ClientCartRepository>()),
  );
  locator.registerLazySingleton<RemoveClientCartItemUseCase>(
    () => RemoveClientCartItemUseCase(locator<ClientCartRepository>()),
  );
  locator.registerLazySingleton<RestoreClientCartItemUseCase>(
    () => RestoreClientCartItemUseCase(locator<ClientCartRepository>()),
  );
  locator.registerLazySingleton<UpdateClientCartQuantityUseCase>(
    () => UpdateClientCartQuantityUseCase(locator<ClientCartRepository>()),
  );

  await _validateExistingSession();

  locator.registerLazySingleton<RegistrationStateService>(
    () => RegistrationStateService(locator<SharedPreferences>()),
  );
  locator.registerLazySingleton<ClientTabUiStateService>(
    ClientTabUiStateService.new,
  );

  locator.registerLazySingleton<AppRouter>(
    () => AppRouter(
      locator<AuthStateService>(),
      locator<RegistrationStateService>(),
      locator<ProviderBusinessInfoStateService>(),
    ),
  );
}

Future<void> _validateExistingSession() async {
  final AuthStateService authStateService = locator<AuthStateService>();
  if (!authStateService.isAuthenticated) {
    return;
  }

  if (_shouldSkipSessionValidation()) {
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

bool _shouldSkipSessionValidation() {
  if (!kDebugMode) {
    return false;
  }
  final String baseUrl = AppEnvironment.apiBaseUrl;
  return baseUrl.contains('127.0.0.1') ||
      baseUrl.contains('10.0.2.2') ||
      baseUrl.contains('localhost');
}
