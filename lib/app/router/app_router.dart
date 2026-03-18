import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/models/account_role.dart';
import 'package:festum/core/services/auth_state_service.dart';
import 'package:festum/core/services/provider_business_info_state_service.dart';
import 'package:festum/features/auth/views/login_view.dart';
import 'package:festum/features/auth/views/registration_view.dart';
import 'package:festum/features/client/models/client_service_catalog.dart';
import 'package:festum/features/client/models/client_tab.dart';
import 'package:festum/features/client/views/client_cart_view.dart';
import 'package:festum/features/client/views/client_home_view.dart';
import 'package:festum/features/client/views/client_orders_view.dart';
import 'package:festum/features/client/views/client_service_detail_view.dart';
import 'package:festum/features/client/views/client_services_by_category_view.dart';
import 'package:festum/features/onboarding/views/registration_type_view.dart';
import 'package:festum/features/provider/models/booking.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/views/add_product_view.dart';
import 'package:festum/features/provider/views/edit_product_view.dart';
import 'package:festum/features/provider/views/edit_service_view.dart';
import 'package:festum/features/provider/views/availability_calendar_view.dart';
import 'package:festum/features/provider/views/booking_detail_view.dart';
import 'package:festum/features/provider/views/create_service_view.dart';
import 'package:festum/features/provider/views/manage_service_view.dart';
import 'package:festum/features/provider/views/my_services_view.dart';
import 'package:festum/features/provider/views/manual_booking_view.dart';
import 'package:festum/features/provider/views/provider_business_info_view.dart';
import 'package:festum/features/provider/views/provider_home_view.dart';
import 'package:festum/features/provider/views/reservations_view.dart';
import 'package:festum/core/services/registration_state_service.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter(
    this._authStateService,
    this._registrationStateService,
    this._providerBusinessInfoStateService,
  );

  final AuthStateService _authStateService;
  final RegistrationStateService _registrationStateService;
  final ProviderBusinessInfoStateService _providerBusinessInfoStateService;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.providerHome,
    refreshListenable: Listenable.merge(<Listenable>[
      _authStateService,
      _registrationStateService,
      _providerBusinessInfoStateService,
    ]),
    redirect: _redirect,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.registrationType,
        builder: (context, state) => const RegistrationTypeView(),
      ),
      GoRoute(
        path: AppRoutes.registration,
        builder: (context, state) {
          final AccountRole? role = AccountRole.fromRoute(
            state.pathParameters['role'],
          );
          if (role == null) {
            return const RegistrationTypeView();
          }
          return RegistrationView(role: role);
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.home,
        redirect: (context, state) => _defaultRouteForRole(_authStateService.role),
      ),
      GoRoute(
        path: AppRoutes.clientHome,
        redirect: (context, state) => AppRoutes.clientServices,
      ),
      GoRoute(
        path: AppRoutes.clientServices,
        builder: (context, state) =>
            const ClientHomeView(tab: ClientTab.services),
      ),
      GoRoute(
        path: AppRoutes.clientServicesByCategory,
        builder: (context, state) {
          final String categorySlug = state.pathParameters['category'] ?? '';
          final ClientServiceCategory? category =
              ClientServiceCategory.fromSlug(categorySlug);

          if (category == null) {
            return const ClientHomeView(tab: ClientTab.services);
          }

          return ClientServicesByCategoryView(category: category);
        },
      ),
      GoRoute(
        path: AppRoutes.clientServiceDetail,
        builder: (context, state) {
          final String categorySlug = state.pathParameters['category'] ?? '';
          final String serviceId = state.pathParameters['serviceId'] ?? '';
          final ClientServiceCategory? category =
              ClientServiceCategory.fromSlug(categorySlug);

          if (category == null) {
            return const ClientHomeView(tab: ClientTab.services);
          }

          return ClientServiceDetailView(
            category: category,
            serviceId: serviceId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.clientCart,
        builder: (context, state) => const ClientCartView(),
      ),
      GoRoute(
        path: AppRoutes.clientOrders,
        builder: (context, state) => const ClientOrdersView(),
      ),
      GoRoute(
        path: AppRoutes.providerHome,
        builder: (context, state) => const ProviderHomeView(),
      ),
      GoRoute(
        path: AppRoutes.providerBusinessInfo,
        builder: (context, state) => const ProviderBusinessInfoView(),
      ),
      GoRoute(
        path: AppRoutes.providerMyServices,
        builder: (context, state) => const MyServicesView(),
      ),
      GoRoute(
        path: AppRoutes.providerCreateService,
        builder: (context, state) => const CreateServiceView(),
      ),
      GoRoute(
        path: AppRoutes.providerEditService,
        builder: (context, state) {
          final serviceId = state.pathParameters['id'] ?? '';
          final serviceName = state.pathParameters['name'] ?? '';
          final categorySlug = state.pathParameters['category'] ?? '';
          final category = ServiceCategory.values.where(
            (value) => value.name == categorySlug,
          );

          if (serviceId.isEmpty || serviceName.isEmpty || category.isEmpty) {
            return const MyServicesView();
          }

          return EditServiceView(
            serviceId: serviceId,
            serviceName: serviceName,
            category: category.first,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.providerManageService,
        builder: (context, state) {
          final serviceName = state.pathParameters['name'] ?? '';
          final categorySlug = state.pathParameters['category'] ?? '';
          final category = ServiceCategory.values.where(
            (value) => value.name == categorySlug,
          );

          if (serviceName.isEmpty || category.isEmpty) {
            return const MyServicesView();
          }

          return ManageServiceView(
            serviceName: serviceName,
            category: category.first,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.providerReservations,
        builder: (context, state) => const ReservationsView(),
      ),
      GoRoute(
        path: AppRoutes.providerManualBooking,
        builder: (context, state) => const ManualBookingView(),
      ),
      GoRoute(
        path: AppRoutes.providerBookingDetail,
        builder: (context, state) {
          final mockBooking = Booking(
            id: '1',
            customerName: 'Mariana López',
            customerImageUrl: 'https://i.pravatar.cc/150?u=mariana',
            customerPhone: '2221234567',
            date: DateTime(2025, 8, 20),
            time: '18:00',
            eventType: 'Boda',
            guests: 180,
            totalAmount: 15000,
            paidAmount: 5000,
            status: 'Confirmada',
          );
          return BookingDetailView(booking: mockBooking);
        },
      ),
      GoRoute(
        path: AppRoutes.providerAddProduct,
        builder: (context, state) {
          final categorySlug = state.pathParameters['category']!;
          final category = ServiceCategory.values.firstWhere((e) => e.name == categorySlug);
          return AddProductView(category: category);
        },
      ),
      GoRoute(
        path: AppRoutes.providerEditProduct,
        builder: (context, state) {
          final categorySlug = state.pathParameters['category']!;
          final productId = state.pathParameters['productId']!;
          final category = ServiceCategory.values.firstWhere((e) => e.name == categorySlug);
          return EditProductView(category: category, productId: productId);
        },
      ),
      GoRoute(
        path: AppRoutes.providerAvailability,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final name = state.pathParameters['name']!;
          return AvailabilityCalendarView(productId: id, productName: name);
        },
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final bool isAuthenticated = _authStateService.isAuthenticated;
    final AccountRole? role = _authStateService.role;
    final String location = state.matchedLocation;
    final bool isAuthRoute = location == AppRoutes.login ||
        location == AppRoutes.registrationType ||
        location.startsWith('/registro/');
    final bool isProviderRoute = location.startsWith('/provider/');
    final bool isClientRoute = location.startsWith('/client/');
    if (!isAuthenticated) {
      return null;
    }

    if (isAuthRoute) {
      return _defaultRouteForRole(role);
    }

    if (role == AccountRole.client && isProviderRoute) {
      return AppRoutes.clientServices;
    }

    if (role == AccountRole.provider && isClientRoute) {
      return _defaultRouteForRole(role);
    }

    return null;
  }

  String? _defaultRouteForRole(AccountRole? role) {
    if (role == null) return null;
    switch (role) {
      case AccountRole.client: return AppRoutes.clientServices;
      case AccountRole.provider: return AppRoutes.providerHome;
    }
  }
}
