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
  final List<ServiceProduct> _products;

  ManageServiceViewModel({required this.serviceName, required this.category})
    : _products = _buildInitialProducts(category);

  List<ServiceProduct> get products => _products;

  static List<ServiceProduct> _buildInitialProducts(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.dj:
        return <ServiceProduct>[
          ServiceProduct(
            id: '1',
            name: 'Paquete DJ básico',
            price: 250,
            detail: 'Audio e iluminación',
          ),
          ServiceProduct(
            id: '2',
            name: 'DJ + luces',
            price: 400,
            detail: 'Incluye cabina y micrófono',
          ),
          ServiceProduct(
            id: '3',
            name: 'Pista LED',
            price: 800,
            detail: 'Ideal para eventos nocturnos',
          ),
        ];
      case ServiceCategory.banquet:
        return <ServiceProduct>[
          ServiceProduct(
            id: '1',
            name: 'Menú tres tiempos',
            price: 320,
            detail: 'Entrada, plato fuerte y postre',
          ),
          ServiceProduct(
            id: '2',
            name: 'Buffet mexicano',
            price: 280,
            detail: 'Servicio para eventos sociales',
          ),
          ServiceProduct(
            id: '3',
            name: 'Mesa de postres',
            price: 190,
            detail: 'Montaje decorativo incluido',
          ),
        ];
      case ServiceCategory.furniture:
        return <ServiceProduct>[
          ServiceProduct(
            id: '1',
            name: 'Silla Tiffany',
            price: 35,
            detail: 'Color blanco',
          ),
          ServiceProduct(
            id: '2',
            name: 'Mesa redonda',
            price: 120,
            detail: 'Capacidad para 10 personas',
          ),
          ServiceProduct(
            id: '3',
            name: 'Periquera',
            price: 95,
            detail: 'Montaje y desmontaje',
          ),
        ];
      case ServiceCategory.venue:
        return <ServiceProduct>[
          ServiceProduct(
            id: '1',
            name: 'Renta entre semana',
            price: 4500,
            detail: 'Acceso por 6 horas',
          ),
          ServiceProduct(
            id: '2',
            name: 'Paquete fin de semana',
            price: 8900,
            detail: 'Incluye limpieza básica',
          ),
          ServiceProduct(
            id: '3',
            name: 'Hora extra',
            price: 850,
            detail: 'Costo por cada hora adicional',
          ),
        ];
      case ServiceCategory.decoration:
        return <ServiceProduct>[
          ServiceProduct(
            id: '1',
            name: 'Decoración floral',
            price: 2800,
            detail: 'Mesa principal y centros',
          ),
          ServiceProduct(
            id: '2',
            name: 'Backdrop temático',
            price: 1900,
            detail: 'Incluye instalación',
          ),
        ];
      case ServiceCategory.photography:
        return <ServiceProduct>[
          ServiceProduct(
            id: '1',
            name: 'Cobertura básica',
            price: 3500,
            detail: 'Sesión de 4 horas',
          ),
          ServiceProduct(
            id: '2',
            name: 'Foto y video',
            price: 6200,
            detail: 'Entrega digital',
          ),
        ];
      case ServiceCategory.entertainment:
        return <ServiceProduct>[
          ServiceProduct(
            id: '1',
            name: 'Show infantil',
            price: 2400,
            detail: 'Dinámicas y animación',
          ),
          ServiceProduct(
            id: '2',
            name: 'Batucada',
            price: 4100,
            detail: 'Presentación para eventos',
          ),
        ];
      case ServiceCategory.equipment:
        return <ServiceProduct>[
          ServiceProduct(
            id: '1',
            name: 'Bocina amplificada',
            price: 550,
            detail: 'Renta por evento',
          ),
          ServiceProduct(
            id: '2',
            name: 'Micrófono inalámbrico',
            price: 180,
            detail: 'Incluye receptor',
          ),
        ];
    }
  }

  void deleteProduct(int index) {
    _products.removeAt(index);
    notifyListeners();
  }
}
