import 'package:festum/app/router/app_routes.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';

class Booking {
  final String customerName;
  final String customerImageUrl;
  final DateTime date;
  final String status;

  Booking({
    required this.customerName,
    required this.customerImageUrl,
    required this.date,
    required this.status,
  });
}

class ProductReservationSummary {
  final String id;
  final String productName;
  final ServiceCategory category;
  final String description;
  final String imageUrl;
  final Booking? nextBooking;

  ProductReservationSummary({
    required this.id,
    required this.productName,
    required this.category,
    required this.description,
    this.imageUrl = '',
    this.nextBooking,
  });
}

class ReservationsViewModel extends BaseViewModel {
  final List<ProductReservationSummary> _products = [
    ProductReservationSummary(
      id: '1',
      productName: 'Salón Imperial',
      category: ServiceCategory.venue,
      description: 'Salón de lujo para eventos sociales.',
      nextBooking: Booking(
        customerName: 'Mariana López',
        customerImageUrl: 'https://i.pravatar.cc/150?u=mariana',
        date: DateTime(2025, 8, 20),
        status: 'Confirmada',
      ),
    ),
    ProductReservationSummary(
      id: '2',
      productName: 'Paquete DJ Básico',
      category: ServiceCategory.dj,
      description: 'Música e iluminación para fiestas.',
      nextBooking: Booking(
        customerName: 'Roberto Gómez',
        customerImageUrl: 'https://i.pravatar.cc/150?u=roberto',
        date: DateTime(2025, 8, 22),
        status: 'Pendiente',
      ),
    ),
  ];

  List<ProductReservationSummary> get products => _products;

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void editProduct(BuildContext context, String id, ServiceCategory category) {
    // CORRECCIÓN: Ahora redirige correctamente a la pantalla de edición
    context.push(AppRoutes.providerEditProductRoute(category.name, id));
  }

  void manageAvailability(BuildContext context, String id, String name) {
    context.push(AppRoutes.providerAvailabilityRoute(id, name));
  }
}
