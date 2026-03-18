import 'package:festum/features/provider/models/service_category.dart';
import 'package:stacked/stacked.dart';

class ServiceProduct {
  final String id;
  final String name;
  final double price;
  final String? detail;
  final String imageUrl;

  ServiceProduct({
    required this.id,
    required this.name,
    required this.price,
    this.detail,
    this.imageUrl = '',
  });
}

class ManageServiceViewModel extends BaseViewModel {
  final String serviceName;
  final ServiceCategory category;

  ManageServiceViewModel({required this.serviceName, required this.category});

  final List<ServiceProduct> _products = [
    ServiceProduct(
      id: '1',
      name: 'Paquete DJ básico',
      price: 250,
      detail: 'NAME',
    ),
    ServiceProduct(
      id: '2',
      name: 'DJ + luces',
      price: 400,
      detail: 'NAME',
    ),
    ServiceProduct(
      id: '3',
      name: 'Pista LED',
      price: 800,
      detail: 'Micrófono',
    ),
  ];

  List<ServiceProduct> get products => _products;

  void deleteProduct(int index) {
    _products.removeAt(index);
    notifyListeners();
  }

  void editProduct(int index) {
    // Lógica para navegar a la pantalla de edición
  }

  void addProduct() {
    // Lógica para navegar a AddProductView
  }
}
