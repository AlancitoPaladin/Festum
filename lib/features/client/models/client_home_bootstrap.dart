import 'package:festum/features/client/models/client_service_catalog.dart';

class ClientHomeBootstrap {
  const ClientHomeBootstrap({
    required this.sections,
    required this.cartCount,
    required this.cartServiceIds,
    required this.ordersCount,
    required this.activeServiceIds,
  });

  final Map<ClientServiceCategory, List<ClientServiceItem>> sections;
  final int cartCount;
  final Set<String> cartServiceIds;
  final int ordersCount;
  final Set<String> activeServiceIds;
}
