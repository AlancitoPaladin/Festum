import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/models/account_role.dart';
import 'package:festum/core/services/auth_state_service.dart';
import 'package:festum/features/auth/views/login_view.dart';
import 'package:festum/features/auth/views/registration_view.dart';
import 'package:festum/features/home/views/home_view.dart';
import 'package:festum/features/onboarding/views/registration_type_view.dart';
import 'package:festum/core/services/registration_state_service.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter(
    this._authStateService,
    this._registrationStateService,
  );

  final AuthStateService _authStateService;
  final RegistrationStateService _registrationStateService;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.registrationType,
    refreshListenable: Listenable.merge(
      <Listenable>[_authStateService, _registrationStateService],
    ),
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
        builder: (context, state) => const HomeView(),
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final bool hasCompletedRegistration =
        _registrationStateService.hasCompletedRegistration;
    final bool isAuthenticated = _authStateService.isAuthenticated;
    final bool isRegistrationTypeRoute =
        state.matchedLocation == AppRoutes.registrationType;
    final bool isRegistrationRoute =
        state.matchedLocation.startsWith('/registro/');
    final bool isOnboardingRoute = isRegistrationTypeRoute || isRegistrationRoute;
    final bool isLoginRoute = state.matchedLocation == AppRoutes.login;
    final bool isProtectedRoute = _isProtectedRoute(state.matchedLocation);

    if (!hasCompletedRegistration && !isOnboardingRoute) {
      return AppRoutes.registrationType;
    }

    if (hasCompletedRegistration && isOnboardingRoute) {
      return isAuthenticated ? AppRoutes.home : AppRoutes.login;
    }

    if (!isAuthenticated && isProtectedRoute) {
      return AppRoutes.login;
    }

    if (isAuthenticated && isLoginRoute) {
      return AppRoutes.home;
    }

    return null;
  }

  bool _isProtectedRoute(String location) {
    return location == AppRoutes.home;
  }
}
