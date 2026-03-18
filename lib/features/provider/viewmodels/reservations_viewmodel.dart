import 'package:festum/features/provider/models/service_category.dart';
import 'package:stacked/stacked.dart';

class ProductReservationSummary {
  final String id;
  final String productName;
  final ServiceCategory category;
  final String description;
  final String imageUrl;
  final int totalReservations;

  ProductReservationSummary({
    required this.id,
    required this.productName,
    required this.category,
    required this.description,
    this.imageUrl = '',
    this.totalReservations = 0,
  });
}

class ReservationsViewModel extends BaseViewModel {
  final List<ProductReservationSummary> _products = [
    ProductReservationSummary(
      id: '1',
      productName: 'Salón Imperial',
      category: ServiceCategory.venue,
      description: 'Salón de lujo para eventos sociales con capacidad de 200 personas.',
      totalReservations: 5,
    ),
    ProductReservationSummary(
      id: '2',
      productName: 'Paquete DJ Básico',
      category: ServiceCategory.dj,
      description: 'Música para todo tipo de eventos con iluminación básica.',
      totalReservations: 12,
    ),
  ];

  List<ProductReservationSummary> get products => _products;

  void addService() {
    // Navegar a crear servicio
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void editProduct(String id) {
    // Navegar a editar producto
  }

  void manageReservations(String id) {
    // Navegar a la pantalla de detalle de reservas y disponibilidad por fecha
  }
}
