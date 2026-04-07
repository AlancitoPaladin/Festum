import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/features/provider/models/product_form_data.dart';
import 'package:festum/features/provider/models/provider_product.dart';
import 'package:festum/features/provider/models/provider_product_request.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/repositories/provider_products_repository.dart';
import 'package:festum/features/provider/usecases/create_provider_product_use_case.dart';
import 'package:stacked/stacked.dart';

class AddProductViewModel extends BaseViewModel {
  AddProductViewModel({
    required this.serviceId,
    required this.category,
    required CreateProviderProductUseCase createProviderProductUseCase,
    required ProviderReactivityService providerReactivityService,
  }) : _createProviderProductUseCase = createProviderProductUseCase,
       _providerReactivityService = providerReactivityService {
    _initializeCategoryFields();
  }

  final String serviceId;
  final ServiceCategory category;
  final CreateProviderProductUseCase _createProviderProductUseCase;
  final ProviderReactivityService _providerReactivityService;

  final ProductFormData _formData = ProductFormData();
  final Map<String, String> _fieldErrors = <String, String>{};
  String? _generalErrorMessage;

  ProductFormData get formData => _formData;
  String? get generalErrorMessage => _generalErrorMessage;
  String? fieldError(String key) => _fieldErrors[key];

  void updateName(String value) {
    _formData.name = value;
    _clearFieldError('name');
  }

  void updatePrice(String value) {
    _formData.price = ProductFormData.parseDecimalInput(value);
    _clearFieldError('price');
  }

  void updatePricingUnit(String? value) {
    if (value == null) {
      return;
    }
    _formData.pricingUnit = value;
    _clearFieldError('pricing_unit');
    notifyListeners();
  }

  void updateDescription(String value) {
    _formData.description = value;
    _clearFieldError('description');
  }

  void updateStock(String value) => _formData.stock = int.tryParse(value) ?? 1;
  void updateBanquetType(String? value) {
    if (value == null) {
      return;
    }
    _formData.banquetType = value;
    notifyListeners();
  }

  void updateDecorationType(String? value) {
    if (value == null) {
      return;
    }
    _formData.decorationType = value;
    notifyListeners();
  }

  void updateMinGuests(String value) =>
      _formData.minGuests = int.tryParse(value);
  void updateMaxGuests(String value) =>
      _formData.maxGuests = int.tryParse(value);
  void updateMenuIncluded(String value) => _formData.menuIncluded = value;
  void updateDimensions(String value) => _formData.dimensions = value;
  void updateWeight(String value) => _formData.weight = value;
  void updateColorMaterial(String value) => _formData.colorMaterial = value;
  void updateVenueCapacity(String value) => _formData.venueCapacity = value;
  void updateMinDuration(String value) => _formData.minDuration = value;
  void updateApproxPhotos(String value) =>
      _formData.approxPhotos = int.tryParse(value);
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

  void toggleExtraHour(bool value) {
    _formData.extraHourAllowed = value;
    notifyListeners();
  }

  void updateExtraHourPrice(String value) =>
      _formData.extraHourPrice = ProductFormData.parseDecimalInput(value);

  void togglePricePerHour() {
    _formData.isPricePerHour = !_formData.isPricePerHour;
    notifyListeners();
  }

  Future<ProviderProduct?> saveProduct() async {
    _generalErrorMessage = null;
    _fieldErrors.clear();

    if (_formData.name.trim().isEmpty) {
      _fieldErrors['name'] = 'Ingresa un nombre para el producto.';
    }
    if (_formData.price <= 0) {
      _fieldErrors['price'] = 'Ingresa un precio valido.';
    }
    if (_formData.pricingUnit.trim().isEmpty) {
      _fieldErrors['pricing_unit'] = 'Selecciona una unidad de precio.';
    }

    if (_fieldErrors.isNotEmpty) {
      notifyListeners();
      return null;
    }

    setBusy(true);
    try {
      final ProviderProduct product = await _createProviderProductUseCase(
        serviceId: serviceId,
        request: CreateProviderProductRequest.fromForm(
          category: category,
          formData: _formData,
        ),
      );
      await _providerReactivityService.notifyProductsChanged();
      await _providerReactivityService.notifyServicesChanged();
      return product;
    } catch (error) {
      _generalErrorMessage = ProviderProductsRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo crear el producto.',
      );
      notifyListeners();
      return null;
    } finally {
      setBusy(false);
    }
  }

  void _initializeCategoryFields() {
    switch (category) {
      case ServiceCategory.dj:
      case ServiceCategory.entertainment:
        _formData.inclusions = <String, bool>{
          'Bocinas': false,
          'Luces': false,
          'Microfono': false,
          'DJ Booth': false,
        };
        break;
      case ServiceCategory.photography:
        _formData.inclusions = <String, bool>{
          'Dron': false,
          'Album impreso': false,
          'Edicion profesional': false,
          'Galería en línea': false,
        };
        break;
      case ServiceCategory.venue:
        _formData.inclusions = <String, bool>{
          'Mesas': false,
          'Sillas': false,
          'Iluminacion': false,
          'Estacionamiento': false,
        };
        break;
      case ServiceCategory.decoration:
        _formData.inclusions = <String, bool>{
          'Flores': false,
          'Globos': false,
          'Backdrop': false,
          'Mesa principal': false,
        };
        break;
      default:
        _formData.inclusions = <String, bool>{
          'Transporte': false,
          'Montaje': false,
          'Limpieza': false,
        };
    }

    _formData.policies = <String, bool>{
      'Cancelacion flexible': false,
      'Se requiere anticipo': false,
      'IVA incluido': false,
    };
  }

  void _clearFieldError(String key) {
    if (_fieldErrors.remove(key) != null || _generalErrorMessage != null) {
      _generalErrorMessage = null;
      notifyListeners();
    }
  }
}
