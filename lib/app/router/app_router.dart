import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/models/account_role.dart';
import 'package:festum/core/services/auth_state_service.dart';
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
import 'package:festum/features/provider/views/provider_home_view.dart';
import 'package:festum/core/services/registration_state_service.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter(this._authStateService, this._registrationStateService);

  final AuthStateService _authStateService;
  final RegistrationStateService _registrationStateService;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.registrationType,
    refreshListenable: Listenable.merge(<Listenable>[
      _authStateService,
      _registrationStateService,
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
        redirect: (context, state) => _homeRouteForRole(_authStateService.role),
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

          final service = ClientServiceCatalog.findService(
            category: category,
            serviceId: serviceId,
          );
          if (service == null) {
            return ClientServicesByCategoryView(category: category);
          }

          return ClientServiceDetailView(category: category, service: service);
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
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final bool hasCompletedRegistration =
        _registrationStateService.hasCompletedRegistration;
    final bool isAuthenticated = _authStateService.isAuthenticated;
    final bool isRegistrationTypeRoute =
        state.matchedLocation == AppRoutes.registrationType;
    final bool isRegistrationRoute = state.matchedLocation.startsWith(
      '/registro/',
    );
    final bool isOnboardingRoute =
        isRegistrationTypeRoute || isRegistrationRoute;
    final bool isLoginRoute = state.matchedLocation == AppRoutes.login;
    final bool isClientRoute = state.matchedLocation.startsWith('/client/');
    final bool isProviderRoute =
        state.matchedLocation == AppRoutes.providerHome;
    final bool isProtectedRoute = _isProtectedRoute(state.matchedLocation);
    final AccountRole? role = _authStateService.role;
    final String? homeRoute = _homeRouteForRole(role);

    if (isAuthenticated && role == null) {
      return AppRoutes.login;
    }

    if (isAuthenticated &&
        (isOnboardingRoute || isLoginRoute) &&
        homeRoute != null) {
      return homeRoute;
    }

    if (!isAuthenticated &&
        !hasCompletedRegistration &&
        !isOnboardingRoute &&
        !isLoginRoute) {
      return AppRoutes.registrationType;
    }

    if (!isAuthenticated && hasCompletedRegistration && isOnboardingRoute) {
      return AppRoutes.login;
    }

    if (!isAuthenticated && isProtectedRoute) {
      return AppRoutes.login;
    }

    if (isAuthenticated && isClientRoute && role != AccountRole.client) {
      return _homeRouteForRole(role);
    }

    if (isAuthenticated && isProviderRoute && role != AccountRole.provider) {
      return _homeRouteForRole(role);
    }

    return null;
  }

  bool _isProtectedRoute(String location) {
    return location == AppRoutes.home ||
        location.startsWith('/client/') ||
        location == AppRoutes.providerHome;
  }

  String? _homeRouteForRole(AccountRole? role) {
    if (role == null) {
      return null;
    }

    switch (role) {
      case AccountRole.client:
        return AppRoutes.clientServices;
      case AccountRole.provider:
        return AppRoutes.providerHome;
    }
  }
}
