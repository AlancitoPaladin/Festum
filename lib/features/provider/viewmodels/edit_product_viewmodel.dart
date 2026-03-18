import 'package:festum/features/provider/models/product_form_data.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:stacked/stacked.dart';

class EditProductViewModel extends BaseViewModel {
  final ServiceCategory category;
  final String productId;
  final ProductFormData _formData = ProductFormData();

  EditProductViewModel({required this.category, required this.productId}) {
    _initializeInclusions();
    _initializePolicies();
    _loadProductData();
  }

  ProductFormData get formData => _formData;

  void _initializeInclusions() {
    switch (category) {
      case ServiceCategory.dj:
      case ServiceCategory.entertainment:
        _formData.inclusions = {'Bocinas': false, 'Luces': false, 'Micrófono': false, 'DJ Booth': false};
        break;
      case ServiceCategory.photography:
        _formData.inclusions = {'Dron': false, 'Álbum impreso': false, 'Edición profesional': false, 'Galería online': false};
        break;
      case ServiceCategory.venue:
        _formData.inclusions = {'Mesas': false, 'Sillas': false, 'Iluminación': false, 'Estacionamiento': false};
        break;
      case ServiceCategory.decoration:
        _formData.inclusions = {'Flores': false, 'Globos': false, 'Backdrop': false, 'Mesa principal': false};
        break;
      default:
        _formData.inclusions = {'Transporte': false, 'Montaje': false, 'Limpieza': false};
    }
  }

  void _initializePolicies() {
    _formData.policies = {'Cancelación flexible': false, 'Se requiere anticipo': false, 'IVA incluido': false};
  }

  void _loadProductData() {
    // Aquí simulamos la obtención de datos del producto "123"
    // En una app real, esto vendría de un repositorio
    _formData.name = 'Servicio DJ Pro (Cargado)';
    _formData.price = 3500;
    _formData.pricingUnit = 'Por evento';
    _formData.description = 'Este es un servicio de alta calidad cargado para edición.';
    _formData.inclusions['Bocinas'] = true;
    _formData.inclusions['Luces'] = true;
    _formData.policies['Cancelación flexible'] = true;
    
    // Datos específicos según categoría
    if (category == ServiceCategory.dj) {
      _formData.minDuration = '5 horas';
      _formData.extraHourAllowed = true;
      _formData.extraHourPrice = 600;
    }
    
    notifyListeners();
  }

  // --- Reutilización de los mismos Setters de AddProduct ---
  void updateName(String value) => _formData.name = value;
  void updatePrice(String value) { _formData.price = double.tryParse(value) ?? 0; notifyListeners(); }
  void updatePricingUnit(String? value) { if (value != null) { _formData.pricingUnit = value; notifyListeners(); } }
  void updateDescription(String value) => _formData.description = value;
  void updateStock(String value) => _formData.stock = int.tryParse(value) ?? 1;

  void updateBanquetType(String? value) { if (value != null) { _formData.banquetType = value; notifyListeners(); } }
  void updateDecorationType(String? value) { if (value != null) { _formData.decorationType = value; notifyListeners(); } }
  void updateMinGuests(String value) => _formData.minGuests = int.tryParse(value);
  void updateMaxGuests(String value) => _formData.maxGuests = int.tryParse(value);
  void updateMenuIncluded(String value) => _formData.menuIncluded = value;
  
  void updateDimensions(String value) => _formData.dimensions = value;
  void updateWeight(String value) => _formData.weight = value;
  void updateColorMaterial(String value) => _formData.colorMaterial = value;
  
  void updateVenueCapacity(String value) => _formData.venueCapacity = value;
  void updateMinDuration(String value) => _formData.minDuration = value;
  void updateApproxPhotos(String value) => _formData.approxPhotos = int.tryParse(value);
  void updateDeliveryTime(String value) => _formData.deliveryTime = value;
  void updateSetupTime(String value) => _formData.setupTime = value;

  void toggleInclusion(String key) {
    _formData.inclusions[key] = !(_formData.inclusions[key] ?? false);
    notifyListeners();
  }

  void togglePolicy(String key) {
    _formData.policies[key] = !(_formData.policies[key] ?? false);
    notifyListeners();
  }

  void toggleExtraHour(bool value) { _formData.extraHourAllowed = value; notifyListeners(); }
  void updateExtraHourPrice(String value) => _formData.extraHourPrice = double.tryParse(value) ?? 0;
  void togglePricePerHour() { _formData.isPricePerHour = !_formData.isPricePerHour; notifyListeners(); }

  Future<void> saveChanges() async {
    setBusy(true);
    // Simular guardado de edición
    await Future.delayed(const Duration(seconds: 2));
    setBusy(false);
  }
}
