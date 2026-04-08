import 'package:festum/app/router/app_router.dart';
import 'package:dio/dio.dart';
import 'package:festum/core/config/app_environment.dart';
import 'package:festum/core/models/account_role.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:festum/core/network/auth_interceptor.dart';
import 'package:festum/core/network/session_interceptor.dart';
import 'package:festum/core/services/auth_state_service.dart';
import 'package:festum/core/services/provider_branding_service.dart';
import 'package:festum/core/services/provider_business_info_state_service.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/core/services/push_notifications_service.dart';
import 'package:festum/core/services/registration_state_service.dart';
import 'package:festum/features/auth/repositories/auth_repository.dart';
import 'package:festum/features/client/repositories/client_cart_repository.dart';
import 'package:festum/features/client/repositories/client_availability_repository.dart';
import 'package:festum/features/client/repositories/client_orders_repository.dart';
import 'package:festum/features/client/repositories/client_services_repository.dart';
import 'package:festum/features/client/repositories/api/api_client_availability_repository.dart';
import 'package:festum/features/client/repositories/api/api_client_cart_repository.dart';
import 'package:festum/features/client/repositories/api/api_client_orders_repository.dart';
import 'package:festum/features/client/repositories/api/api_client_services_repository.dart';
import 'package:festum/features/client/services/client_query_cache_service.dart';
import 'package:festum/features/client/services/client_tab_ui_state_service.dart';
import 'package:festum/features/client/usecases/add_service_to_cart_use_case.dart';
import 'package:festum/features/client/usecases/checkout_cart_use_case.dart';
import 'package:festum/features/client/usecases/get_client_cart_items_use_case.dart';
import 'package:festum/features/client/usecases/get_client_home_sections_use_case.dart';
import 'package:festum/features/client/usecases/get_client_order_by_id_use_case.dart';
import 'package:festum/features/client/usecases/get_client_active_order_service_ids_use_case.dart';
import 'package:festum/features/client/usecases/get_client_orders_use_case.dart';
import 'package:festum/features/client/usecases/get_client_home_bootstrap_use_case.dart';
import 'package:festum/features/client/usecases/get_client_product_availability_use_case.dart';
import 'package:festum/features/client/usecases/get_client_service_by_id_use_case.dart';
import 'package:festum/features/client/usecases/get_services_by_category_use_case.dart';
import 'package:festum/features/client/usecases/is_service_in_cart_use_case.dart';
import 'package:festum/features/client/usecases/remove_client_cart_item_use_case.dart';
import 'package:festum/features/client/usecases/restore_client_cart_item_use_case.dart';
import 'package:festum/features/client/usecases/update_client_order_status_use_case.dart';
import 'package:festum/features/provider/repositories/provider_business_repository.dart';
import 'package:festum/features/provider/repositories/provider_availability_repository.dart';
import 'package:festum/features/provider/repositories/provider_bookings_repository.dart';
import 'package:festum/features/provider/repositories/provider_home_repository.dart';
import 'package:festum/features/provider/repositories/provider_products_repository.dart';
import 'package:festum/features/provider/repositories/provider_reservations_repository.dart';
import 'package:festum/features/provider/repositories/provider_services_repository.dart';
import 'package:festum/features/provider/usecases/block_provider_product_date_use_case.dart';
import 'package:festum/features/provider/usecases/clear_provider_notifications_use_case.dart';
import 'package:festum/features/provider/usecases/create_provider_product_use_case.dart';
import 'package:festum/features/provider/usecases/create_provider_service_use_case.dart';
import 'package:festum/features/provider/usecases/create_manual_booking_use_case.dart';
import 'package:festum/features/provider/usecases/delete_provider_product_image_use_case.dart';
import 'package:festum/features/provider/usecases/delete_provider_service_image_use_case.dart';
import 'package:festum/features/provider/usecases/delete_provider_product_use_case.dart';
import 'package:festum/features/provider/usecases/delete_provider_service_product_use_case.dart';
import 'package:festum/features/provider/usecases/decide_provider_order_request_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_business_profile_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_booking_detail_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_home_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_notifications_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_order_requests_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_product_availability_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_product_detail_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_product_reservations_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_service_products_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_services_use_case.dart';
import 'package:festum/features/provider/usecases/mark_all_provider_notifications_as_read_use_case.dart';
import 'package:festum/features/provider/usecases/mark_provider_notification_as_read_use_case.dart';
import 'package:festum/features/provider/usecases/save_provider_business_profile_use_case.dart';
import 'package:festum/features/provider/usecases/set_provider_product_main_image_use_case.dart';
import 'package:festum/features/provider/usecases/set_provider_service_main_image_use_case.dart';
import 'package:festum/features/provider/usecases/upload_provider_business_logo_use_case.dart';
import 'package:festum/features/provider/usecases/upload_provider_business_photo_use_case.dart';
import 'package:festum/features/provider/usecases/upload_provider_product_image_use_case.dart';
import 'package:festum/features/provider/usecases/upload_provider_service_image_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_booking_status_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_booking_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_product_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_product_status_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_service_status_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_service_use_case.dart';
import 'package:festum/features/provider/usecases/unblock_provider_product_date_use_case.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
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
  locator.registerLazySingleton<ProviderBrandingService>(
    ProviderBrandingService.new,
  );
  locator.registerLazySingleton<ProviderReactivityService>(
    ProviderReactivityService.new,
  );

  locator.registerLazySingleton<Dio>(() {
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
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }

    return dio;
  });

  locator.registerLazySingleton<ApiClient>(() => ApiClient(locator<Dio>()));
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(locator<ApiClient>()),
  );
  locator.registerLazySingleton<ProviderHomeRepository>(
    () => ProviderHomeRepository(locator<ApiClient>()),
  );
  locator.registerLazySingleton<GetProviderHomeUseCase>(
    () => GetProviderHomeUseCase(locator<ProviderHomeRepository>()),
  );
  locator.registerLazySingleton<GetProviderNotificationsUseCase>(
    () => GetProviderNotificationsUseCase(locator<ProviderHomeRepository>()),
  );
  locator.registerLazySingleton<MarkProviderNotificationAsReadUseCase>(
    () => MarkProviderNotificationAsReadUseCase(
      locator<ProviderHomeRepository>(),
    ),
  );
  locator.registerLazySingleton<MarkAllProviderNotificationsAsReadUseCase>(
    () => MarkAllProviderNotificationsAsReadUseCase(
      locator<ProviderHomeRepository>(),
    ),
  );
  locator.registerLazySingleton<ClearProviderNotificationsUseCase>(
    () => ClearProviderNotificationsUseCase(locator<ProviderHomeRepository>()),
  );
  locator.registerLazySingleton<ProviderBusinessRepository>(
    () => ProviderBusinessRepository(locator<ApiClient>()),
  );
  locator.registerLazySingleton<GetProviderBusinessProfileUseCase>(
    () => GetProviderBusinessProfileUseCase(
      locator<ProviderBusinessRepository>(),
    ),
  );
  locator.registerLazySingleton<SaveProviderBusinessProfileUseCase>(
    () => SaveProviderBusinessProfileUseCase(
      locator<ProviderBusinessRepository>(),
    ),
  );
  locator.registerLazySingleton<UploadProviderBusinessLogoUseCase>(
    () => UploadProviderBusinessLogoUseCase(
      locator<ProviderBusinessRepository>(),
    ),
  );
  locator.registerLazySingleton<UploadProviderBusinessPhotoUseCase>(
    () => UploadProviderBusinessPhotoUseCase(
      locator<ProviderBusinessRepository>(),
    ),
  );
  locator.registerLazySingleton<ProviderReservationsRepository>(
    () => ProviderReservationsRepository(locator<ApiClient>()),
  );
  locator.registerLazySingleton<GetProviderProductReservationsUseCase>(
    () => GetProviderProductReservationsUseCase(
      locator<ProviderReservationsRepository>(),
    ),
  );
  locator.registerLazySingleton<GetProviderOrderRequestsUseCase>(
    () => GetProviderOrderRequestsUseCase(
      locator<ProviderReservationsRepository>(),
    ),
  );
  locator.registerLazySingleton<DecideProviderOrderRequestUseCase>(
    () => DecideProviderOrderRequestUseCase(
      locator<ProviderReservationsRepository>(),
    ),
  );
  locator.registerLazySingleton<DeleteProviderProductUseCase>(
    () =>
        DeleteProviderProductUseCase(locator<ProviderReservationsRepository>()),
  );
  locator.registerLazySingleton<ProviderBookingsRepository>(
    () => ProviderBookingsRepository(locator<ApiClient>()),
  );
  locator.registerLazySingleton<CreateManualBookingUseCase>(
    () => CreateManualBookingUseCase(locator<ProviderBookingsRepository>()),
  );
  locator.registerLazySingleton<GetProviderBookingDetailUseCase>(
    () =>
        GetProviderBookingDetailUseCase(locator<ProviderBookingsRepository>()),
  );
  locator.registerLazySingleton<UpdateProviderBookingUseCase>(
    () => UpdateProviderBookingUseCase(locator<ProviderBookingsRepository>()),
  );
  locator.registerLazySingleton<UpdateProviderBookingStatusUseCase>(
    () => UpdateProviderBookingStatusUseCase(
      locator<ProviderBookingsRepository>(),
    ),
  );
  locator.registerLazySingleton<ProviderAvailabilityRepository>(
    () => ProviderAvailabilityRepository(locator<ApiClient>()),
  );
  locator.registerLazySingleton<GetProviderProductAvailabilityUseCase>(
    () => GetProviderProductAvailabilityUseCase(
      locator<ProviderAvailabilityRepository>(),
    ),
  );
  locator.registerLazySingleton<BlockProviderProductDateUseCase>(
    () => BlockProviderProductDateUseCase(
      locator<ProviderAvailabilityRepository>(),
    ),
  );
  locator.registerLazySingleton<UnblockProviderProductDateUseCase>(
    () => UnblockProviderProductDateUseCase(
      locator<ProviderAvailabilityRepository>(),
    ),
  );
  locator.registerLazySingleton<ProviderProductsRepository>(
    () => ProviderProductsRepository(locator<ApiClient>()),
  );
  locator.registerLazySingleton<CreateProviderProductUseCase>(
    () => CreateProviderProductUseCase(locator<ProviderProductsRepository>()),
  );
  locator.registerLazySingleton<GetProviderServiceProductsUseCase>(
    () => GetProviderServiceProductsUseCase(
      locator<ProviderProductsRepository>(),
    ),
  );
  locator.registerLazySingleton<DeleteProviderServiceProductUseCase>(
    () => DeleteProviderServiceProductUseCase(
      locator<ProviderProductsRepository>(),
    ),
  );
  locator.registerLazySingleton<GetProviderProductDetailUseCase>(
    () =>
        GetProviderProductDetailUseCase(locator<ProviderProductsRepository>()),
  );
  locator.registerLazySingleton<UpdateProviderProductUseCase>(
    () => UpdateProviderProductUseCase(locator<ProviderProductsRepository>()),
  );
  locator.registerLazySingleton<UpdateProviderProductStatusUseCase>(
    () => UpdateProviderProductStatusUseCase(
      locator<ProviderProductsRepository>(),
    ),
  );
  locator.registerLazySingleton<UploadProviderProductImageUseCase>(
    () => UploadProviderProductImageUseCase(
      locator<ProviderProductsRepository>(),
    ),
  );
  locator.registerLazySingleton<SetProviderProductMainImageUseCase>(
    () => SetProviderProductMainImageUseCase(
      locator<ProviderProductsRepository>(),
    ),
  );
  locator.registerLazySingleton<DeleteProviderProductImageUseCase>(
    () => DeleteProviderProductImageUseCase(
      locator<ProviderProductsRepository>(),
    ),
  );
  locator.registerLazySingleton<ProviderServicesRepository>(
    () => ProviderServicesRepository(locator<ApiClient>()),
  );
  locator.registerLazySingleton<CreateProviderServiceUseCase>(
    () => CreateProviderServiceUseCase(locator<ProviderServicesRepository>()),
  );
  locator.registerLazySingleton<GetProviderServicesUseCase>(
    () => GetProviderServicesUseCase(locator<ProviderServicesRepository>()),
  );
  locator.registerLazySingleton<UpdateProviderServiceUseCase>(
    () => UpdateProviderServiceUseCase(locator<ProviderServicesRepository>()),
  );
  locator.registerLazySingleton<UpdateProviderServiceStatusUseCase>(
    () => UpdateProviderServiceStatusUseCase(
      locator<ProviderServicesRepository>(),
    ),
  );
  locator.registerLazySingleton<UploadProviderServiceImageUseCase>(
    () => UploadProviderServiceImageUseCase(
      locator<ProviderServicesRepository>(),
    ),
  );
  locator.registerLazySingleton<SetProviderServiceMainImageUseCase>(
    () => SetProviderServiceMainImageUseCase(
      locator<ProviderServicesRepository>(),
    ),
  );
  locator.registerLazySingleton<DeleteProviderServiceImageUseCase>(
    () => DeleteProviderServiceImageUseCase(
      locator<ProviderServicesRepository>(),
    ),
  );
  locator.registerLazySingleton<ImagePicker>(ImagePicker.new);
  locator.registerLazySingleton<ClientQueryCacheService>(
    ClientQueryCacheService.new,
  );

  locator.registerLazySingleton<ClientAvailabilityRepository>(
    () => ApiClientAvailabilityRepository(locator<ApiClient>()),
  );
  locator.registerLazySingleton<ClientServicesRepository>(
    () => ApiClientServicesRepository(
      locator<ApiClient>(),
      locator<ClientQueryCacheService>(),
    ),
  );
  locator.registerLazySingleton<ClientOrdersRepository>(
    () => ApiClientOrdersRepository(
      locator<ApiClient>(),
      locator<ClientQueryCacheService>(),
    ),
  );
  locator.registerLazySingleton<ClientCartRepository>(
    () => ApiClientCartRepository(
      locator<ApiClient>(),
      locator<ClientQueryCacheService>(),
    ),
  );

  locator.registerLazySingleton<GetClientHomeSectionsUseCase>(
    () => GetClientHomeSectionsUseCase(locator<ClientServicesRepository>()),
  );
  locator.registerLazySingleton<GetClientHomeBootstrapUseCase>(
    () => GetClientHomeBootstrapUseCase(locator<ClientServicesRepository>()),
  );
  locator.registerLazySingleton<GetServicesByCategoryUseCase>(
    () => GetServicesByCategoryUseCase(locator<ClientServicesRepository>()),
  );
  locator.registerLazySingleton<GetClientServiceByIdUseCase>(
    () => GetClientServiceByIdUseCase(locator<ClientServicesRepository>()),
  );
  locator.registerLazySingleton<GetClientProductAvailabilityUseCase>(
    () => GetClientProductAvailabilityUseCase(
      locator<ClientAvailabilityRepository>(),
    ),
  );
  locator.registerLazySingleton<GetClientOrdersUseCase>(
    () => GetClientOrdersUseCase(locator<ClientOrdersRepository>()),
  );
  locator.registerLazySingleton<GetClientOrderByIdUseCase>(
    () => GetClientOrderByIdUseCase(locator<ClientOrdersRepository>()),
  );
  locator.registerLazySingleton<GetClientActiveOrderServiceIdsUseCase>(
    () => GetClientActiveOrderServiceIdsUseCase(
      locator<ClientOrdersRepository>(),
    ),
  );
  locator.registerLazySingleton<UpdateClientOrderStatusUseCase>(
    () => UpdateClientOrderStatusUseCase(locator<ClientOrdersRepository>()),
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
  locator.registerLazySingleton<AddServiceToCartUseCase>(
    () => AddServiceToCartUseCase(locator<ClientCartRepository>()),
  );
  locator.registerLazySingleton<IsServiceInCartUseCase>(
    () => IsServiceInCartUseCase(locator<ClientCartRepository>()),
  );
  locator.registerLazySingleton<CheckoutCartUseCase>(
    () => CheckoutCartUseCase(
      locator<ClientCartRepository>(),
      locator<ClientOrdersRepository>(),
    ),
  );

  await _validateExistingSession();
  await _syncProviderBusinessInfoProgress();

  locator.registerLazySingleton<RegistrationStateService>(
    () => RegistrationStateService(locator<SharedPreferences>()),
  );
  locator.registerLazySingleton<ClientTabUiStateService>(
    () => ClientTabUiStateService(locator<SharedPreferences>()),
  );

  locator.registerLazySingleton<AppRouter>(
    () => AppRouter(
      locator<AuthStateService>(),
      locator<RegistrationStateService>(),
      locator<ProviderBusinessInfoStateService>(),
    ),
  );
  locator.registerLazySingleton<PushNotificationsService>(
    () => PushNotificationsService(
      locator<ApiClient>(),
      locator<AuthStateService>(),
      locator<AppRouter>(),
      locator<ClientTabUiStateService>(),
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

Future<void> _syncProviderBusinessInfoProgress() async {
  final AuthStateService authStateService = locator<AuthStateService>();
  if (!authStateService.isAuthenticated ||
      authStateService.role != AccountRole.provider) {
    await locator<ProviderBrandingService>().clear();
    await locator<ProviderReactivityService>().clear();
    return;
  }

  try {
    final profile = await locator<ProviderBusinessRepository>().fetchProfile();
    final bool hasCompletedBusinessInfo =
        profile.businessName.trim().isNotEmpty ||
        profile.location.trim().isNotEmpty ||
        profile.coverageArea.trim().isNotEmpty ||
        profile.contactNumber.trim().isNotEmpty ||
        profile.logoUrl.trim().isNotEmpty ||
        profile.photoUrls.isNotEmpty;

    await locator<ProviderBusinessInfoStateService>().syncBusinessInfoProgress(
      hasCompletedBusinessInfo,
    );
    await locator<ProviderBrandingService>().sync(
      businessName: profile.businessName,
      logoUrl: profile.logoUrl,
    );
  } on DioException catch (error) {
    if (error.response?.statusCode == 404) {
      await locator<ProviderBusinessInfoStateService>()
          .syncBusinessInfoProgress(false);
      await locator<ProviderBrandingService>().clear();
    }
  }
}
