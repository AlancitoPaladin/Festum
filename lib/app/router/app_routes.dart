class AppRoutes {
  const AppRoutes._();

  static const String registrationType = '/registro';
  static const String registration = '/registro/:role';
  static const String login = '/login';
  static const String home = '/home';
  static const String clientHome = '/client/home';
  static const String clientServices = '/client/services';
  static const String clientServicesByCategory = '/client/services/:category';
  static const String clientServiceDetail =
      '/client/services/:category/:serviceId';
  static const String clientCart = '/client/cart';
  static const String clientOrders = '/client/orders';
  static const String providerHome = '/provider/home';

  static String clientServicesCategory(String category) =>
      '/client/services/$category';

  static String clientServiceDetails({
    required String category,
    required String serviceId,
  }) {
    return '/client/services/$category/$serviceId';
  }
}
