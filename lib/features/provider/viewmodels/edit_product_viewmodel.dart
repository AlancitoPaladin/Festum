import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/features/provider/models/product_form_data.dart';
import 'package:festum/features/provider/models/provider_product.dart';
import 'package:festum/features/provider/models/provider_product_image.dart';
import 'package:festum/features/provider/models/provider_product_image_upload_response.dart';
import 'package:festum/features/provider/models/provider_product_request.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/repositories/provider_products_repository.dart';
import 'package:festum/features/provider/usecases/delete_provider_product_image_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_product_detail_use_case.dart';
import 'package:festum/features/provider/usecases/set_provider_product_main_image_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_product_status_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_product_use_case.dart';
import 'package:festum/features/provider/usecases/upload_provider_product_image_use_case.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';

class EditProductViewModel extends BaseViewModel {
  EditProductViewModel({
    required this.productId,
    required GetProviderProductDetailUseCase getProviderProductDetailUseCase,
    required UpdateProviderProductUseCase updateProviderProductUseCase,
    required UpdateProviderProductStatusUseCase
    updateProviderProductStatusUseCase,
    required UploadProviderProductImageUseCase uploadProviderProductImageUseCase,
    required SetProviderProductMainImageUseCase
    setProviderProductMainImageUseCase,
    required DeleteProviderProductImageUseCase
    deleteProviderProductImageUseCase,
    required ProviderReactivityService providerReactivityService,
    required ImagePicker imagePicker,
  }) : _getProviderProductDetailUseCase = getProviderProductDetailUseCase,
       _updateProviderProductUseCase = updateProviderProductUseCase,
       _updateProviderProductStatusUseCase = updateProviderProductStatusUseCase,
       _uploadProviderProductImageUseCase = uploadProviderProductImageUseCase,
       _setProviderProductMainImageUseCase = setProviderProductMainImageUseCase,
       _deleteProviderProductImageUseCase = deleteProviderProductImageUseCase,
       _providerReactivityService = providerReactivityService,
       _imagePicker = imagePicker;

  final String productId;
  final GetProviderProductDetailUseCase _getProviderProductDetailUseCase;
  final UpdateProviderProductUseCase _updateProviderProductUseCase;
  final UpdateProviderProductStatusUseCase _updateProviderProductStatusUseCase;
  final UploadProviderProductImageUseCase _uploadProviderProductImageUseCase;
  final SetProviderProductMainImageUseCase _setProviderProductMainImageUseCase;
  final DeleteProviderProductImageUseCase _deleteProviderProductImageUseCase;
  final ProviderReactivityService _providerReactivityService;
  final ImagePicker _imagePicker;

  final ProductFormData _formData = ProductFormData();
  final Map<String, String> _fieldErrors = <String, String>{};
  final List<ProviderProductImage> _images = <ProviderProductImage>[];

  ProviderProduct? _product;
  String? _generalErrorMessage;
  bool _hasLoadedInitialData = false;
  bool _isUploadingImage = false;
  String? _mutatingImageKey;

  ProviderProduct? get product => _product;
  ProductFormData get formData => _formData;
  ServiceCategory? get category => _product?.category;
  String? get generalErrorMessage => _generalErrorMessage;
  bool get hasLoadedInitialData => _hasLoadedInitialData;
  List<ProviderProductImage> get images =>
      List<ProviderProductImage>.unmodifiable(_images);
  bool get isUploadingImage => _isUploadingImage;
  String? get mutatingImageKey => _mutatingImageKey;
  String? fieldError(String key) => _fieldErrors[key];

  Future<void> initialise() async {
    if (_hasLoadedInitialData || isBusy) {
      return;
    }

    setBusy(true);
    _generalErrorMessage = null;
    try {
      final ProviderProduct result = await _getProviderProductDetailUseCase(
        productId,
      );
      _applyProduct(result);
      _hasLoadedInitialData = true;
    } catch (error) {
      _generalErrorMessage = ProviderProductsRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo cargar el producto.',
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void updateName(String value) {
    _formData.name = value;
    _clearFieldError('name');
  }

  void updatePrice(String value) {
    _formData.price = double.tryParse(value) ?? 0;
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

  void updateMinGuests(String value) => _formData.minGuests = int.tryParse(value);
  void updateMaxGuests(String value) => _formData.maxGuests = int.tryParse(value);
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
      _formData.extraHourPrice = double.tryParse(value) ?? 0;

  void togglePricePerHour() {
    _formData.isPricePerHour = !_formData.isPricePerHour;
    notifyListeners();
  }

  Future<bool> saveChanges() async {
    final ServiceCategory? currentCategory = category;
    if (currentCategory == null) {
      return false;
    }

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
      return false;
    }

    setBusy(true);
    try {
      final ProviderProduct updated = await _updateProviderProductUseCase(
        productId,
        UpdateProviderProductRequest.fromForm(
          category: currentCategory,
          formData: _formData,
        ),
      );
      _applyProduct(updated);
      await _providerReactivityService.notifyProductsChanged();
      await _providerReactivityService.notifyServicesChanged();
      return true;
    } catch (error) {
      _generalErrorMessage = ProviderProductsRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo guardar el producto.',
      );
      notifyListeners();
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<String?> publish() async {
    return _changeStatus('published');
  }

  Future<String?> inactivate() async {
    return _changeStatus('inactive');
  }

  Future<String?> uploadImage() async {
    if (_product == null || _isUploadingImage) {
      return null;
    }

    String? previewKey;
    try {
      final XFile? selectedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (selectedFile == null) {
        return null;
      }

      previewKey =
          'local:${DateTime.now().microsecondsSinceEpoch}:${selectedFile.path}';
      final bool isFirstImage = _images.isEmpty;
      _mergeUploadedImage(
        ProviderProductImage.fromJson(
          <String, dynamic>{
            'key': previewKey,
            'image_url': selectedFile.path,
            'is_main': isFirstImage,
          },
          fallbackIsMain: isFirstImage,
        ),
      );
      _isUploadingImage = true;
      _generalErrorMessage = null;
      notifyListeners();

      final ProviderProductImageUploadResponse response =
          await _uploadProviderProductImageUseCase(
            productId: productId,
            filePath: selectedFile.path,
            isMain: _images.isEmpty,
          );

      _mergeUploadedImage(
        response.image.copyWith(
          key: response.key,
          isMain: response.isMain || isFirstImage,
        ),
      );
      _images.removeWhere((ProviderProductImage image) => image.key == previewKey);
      _syncProductImages();
      await _providerReactivityService.notifyProductsChanged();
      await _providerReactivityService.notifyServicesChanged();
      return null;
    } catch (error) {
      if (previewKey != null) {
        _images.removeWhere((ProviderProductImage image) => image.key == previewKey);
      }
      _syncProductImages();
      return ProviderProductsRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo subir la imagen.',
      );
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  Future<String?> markImageAsMain(String imageKey) async {
    if (_mutatingImageKey != null || _product == null) {
      return null;
    }

    try {
      _mutatingImageKey = imageKey;
      notifyListeners();

      await _setProviderProductMainImageUseCase(
        productId: productId,
        imageKey: imageKey,
      );
      _setLocalMainImage(imageKey);
      _syncProductImages();
      await _providerReactivityService.notifyProductsChanged();
      await _providerReactivityService.notifyServicesChanged();
      return null;
    } catch (error) {
      return ProviderProductsRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo actualizar la imagen principal.',
      );
    } finally {
      _mutatingImageKey = null;
      notifyListeners();
    }
  }

  Future<String?> deleteImage(String imageKey) async {
    if (_mutatingImageKey != null || _product == null) {
      return null;
    }

    final bool wasMain = _images.any(
      (ProviderProductImage image) => image.key == imageKey && image.isMain,
    );

    try {
      _mutatingImageKey = imageKey;
      notifyListeners();

      await _deleteProviderProductImageUseCase(
        productId: productId,
        imageKey: imageKey,
      );
      _images.removeWhere((ProviderProductImage image) => image.key == imageKey);

      if (wasMain && _images.isNotEmpty) {
        final String replacementKey = _images.first.key;
        await _setProviderProductMainImageUseCase(
          productId: productId,
          imageKey: replacementKey,
        );
        _setLocalMainImage(replacementKey);
      }

      _syncProductImages();
      await _providerReactivityService.notifyProductsChanged();
      await _providerReactivityService.notifyServicesChanged();
      return null;
    } catch (error) {
      return ProviderProductsRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo eliminar la imagen.',
      );
    } finally {
      _mutatingImageKey = null;
      notifyListeners();
    }
  }

  Future<String?> _changeStatus(String status) async {
    if (_product == null) {
      return 'No se encontro el producto.';
    }

    setBusy(true);
    try {
      final ProviderProduct updated = await _updateProviderProductStatusUseCase(
        productId: productId,
        status: status,
      );
      _applyProduct(updated);
      await _providerReactivityService.notifyProductsChanged();
      await _providerReactivityService.notifyServicesChanged();
      return null;
    } catch (error) {
      return ProviderProductsRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo actualizar el estado del producto.',
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void _applyProduct(ProviderProduct product) {
    _product = product;
    _initializeCategoryFields(product.category);

    _formData
      ..name = product.name
      ..price = product.price
      ..pricingUnit = product.pricingUnit.trim().isEmpty
          ? 'Por evento'
          : product.pricingUnit
      ..description = product.description
      ..inclusions = Map<String, bool>.from(product.inclusions)
      ..policies = Map<String, bool>.from(product.policies);

    final Map<String, dynamic> details = product.details;
    _formData.stock = _toInt(details['stock'], fallbackValue: _formData.stock);
    _formData.approxPhotos = _toNullableInt(details['approx_photos']);
    _formData.deliveryTime = _toNullableString(details['delivery_time']);
    _formData.decorationType = _toNullableString(details['decoration_type']) ??
        _formData.decorationType;
    _formData.setupTime = _toNullableString(details['setup_time']);
    _formData.banquetType =
        _toNullableString(details['banquet_type']) ?? _formData.banquetType;
    _formData.minGuests = _toNullableInt(details['min_guests']);
    _formData.maxGuests = _toNullableInt(details['max_guests']);
    _formData.menuIncluded = _toNullableString(details['menu_included']);
    _formData.dimensions = _toNullableString(details['dimensions']);
    _formData.weight = _toNullableString(details['weight']);
    _formData.colorMaterial = _toNullableString(details['color_material']);
    _formData.venueCapacity = _toNullableString(details['venue_capacity']);
    _formData.isPricePerHour = _toBool(details['is_price_per_hour']);
    _formData.minDuration = _toNullableString(details['min_duration']);
    _formData.extraHourAllowed = _toBool(details['extra_hour_allowed']);
    _formData.extraHourPrice = _toDouble(
      details['extra_hour_price'],
      fallbackValue: 0,
    );

    _images
      ..clear()
      ..addAll(product.images);
  }

  void _initializeCategoryFields(ServiceCategory category) {
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
          'Galeria online': false,
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

  void _mergeUploadedImage(ProviderProductImage uploadedImage) {
    final int index = _images.indexWhere(
      (ProviderProductImage image) => image.key == uploadedImage.key,
    );
    if (index >= 0) {
      _images[index] = uploadedImage;
    } else {
      _images.add(uploadedImage);
    }

    if (uploadedImage.isMain) {
      _setLocalMainImage(uploadedImage.key);
    }
    _syncProductImages();
  }

  void _setLocalMainImage(String imageKey) {
    for (int index = 0; index < _images.length; index++) {
      final ProviderProductImage image = _images[index];
      _images[index] = image.copyWith(isMain: image.key == imageKey);
    }
  }

  void _syncProductImages() {
    final ProviderProduct? current = _product;
    if (current == null) {
      return;
    }

    String mainImageUrl = current.mainImageUrl;
    final List<String> imageUrls = <String>[];

    for (final ProviderProductImage image in _images) {
      if (image.resolvedImageUrl.isNotEmpty) {
        imageUrls.add(image.resolvedImageUrl);
      }
      if (image.isMain && image.resolvedImageUrl.isNotEmpty) {
        mainImageUrl = image.resolvedImageUrl;
      }
    }

    _product = current.copyWith(
      mainImageUrl: mainImageUrl,
      imageUrls: imageUrls,
      images: List<ProviderProductImage>.from(_images),
    );
  }
}

int _toInt(dynamic value, {required int fallbackValue}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? fallbackValue;
}

int? _toNullableInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

String? _toNullableString(dynamic value) {
  final String parsed = value?.toString().trim() ?? '';
  return parsed.isEmpty ? null : parsed;
}

double _toDouble(dynamic value, {required double fallbackValue}) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? fallbackValue;
}

bool _toBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  final String normalized = value?.toString().trim().toLowerCase() ?? '';
  return normalized == 'true' || normalized == '1';
}
