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
  static const String providerBusinessInfo = '/provider/business-info';
  static const String providerMyServices = '/provider/my-services';
  static const String providerManageService = '/provider/manage-service/:name/:category';
  static const String providerCreateService = '/provider/create-service';
  static const String providerEditService =
      '/provider/edit-service/:id/:name/:category';
  static const String providerAddProduct = '/provider/add-product/:category';
  static const String providerEditProduct = '/provider/edit-product/:category/:productId';
  static const String providerReservations = '/provider/reservations';
  static const String providerAvailability = '/provider/availability/:id/:name';
  static const String providerBookingDetail = '/provider/booking-detail/:date';
  static const String providerManualBooking = '/provider/manual-booking/:date';

  static String clientServicesCategory(String category) =>
      '/client/services/$category';

  static String clientServiceDetails({
    required String category,
    required String serviceId,
  }) {
    return '/client/services/$category/$serviceId';
  }

  static String providerManageServiceRoute(String name, String category) => 
      '/provider/manage-service/${Uri.encodeComponent(name)}/$category';

  static String providerEditServiceRoute(
    String id,
    String name,
    String category,
  ) =>
      '/provider/edit-service/$id/${Uri.encodeComponent(name)}/$category';

  static String providerAddProductRoute(String category) => 
      '/provider/add-product/$category';

  static String providerEditProductRoute(String category, String productId) => 
      '/provider/edit-product/$category/$productId';

  static String providerAvailabilityRoute(String id, String name) => 
      '/provider/availability/$id/${Uri.encodeComponent(name)}';

  static String providerBookingDetailRoute(String date) => 
      '/provider/booking-detail/$date';

  static String providerManualBookingRoute(String date) => 
      '/provider/manual-booking/$date';
}
