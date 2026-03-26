import 'package:image_picker/image_picker.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/features/provider/models/provider_request_error.dart';
import 'package:festum/features/provider/models/provider_service_image.dart';
import 'package:festum/features/provider/models/provider_service_image_upload_response.dart';
import 'package:festum/features/provider/models/provider_service.dart';
import 'package:festum/features/provider/models/provider_service_upsert_request.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/models/service_form_data.dart';
import 'package:festum/features/provider/repositories/provider_services_repository.dart';
import 'package:festum/features/provider/usecases/delete_provider_service_image_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_services_use_case.dart';
import 'package:festum/features/provider/usecases/set_provider_service_main_image_use_case.dart';
import 'package:festum/features/provider/usecases/upload_provider_service_image_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_service_use_case.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class EditServiceViewModel extends BaseViewModel {
  EditServiceViewModel({
    required this.serviceId,
    required this.serviceName,
    required this.category,
    required GetProviderServicesUseCase getProviderServicesUseCase,
    required UpdateProviderServiceUseCase updateProviderServiceUseCase,
    required UploadProviderServiceImageUseCase uploadProviderServiceImageUseCase,
    required SetProviderServiceMainImageUseCase setProviderServiceMainImageUseCase,
    required DeleteProviderServiceImageUseCase deleteProviderServiceImageUseCase,
    required ProviderReactivityService providerReactivityService,
    required ImagePicker imagePicker,
  }) : _getProviderServicesUseCase = getProviderServicesUseCase,
       _updateProviderServiceUseCase = updateProviderServiceUseCase,
       _uploadProviderServiceImageUseCase = uploadProviderServiceImageUseCase,
       _setProviderServiceMainImageUseCase = setProviderServiceMainImageUseCase,
       _deleteProviderServiceImageUseCase = deleteProviderServiceImageUseCase,
       _providerReactivityService = providerReactivityService,
       _imagePicker = imagePicker {
    _formData
      ..name = serviceName
      ..category = category;

    nameController.text = serviceName;
  }

  final String serviceId;
  final String serviceName;
  final ServiceCategory category;
  final GetProviderServicesUseCase _getProviderServicesUseCase;
  final UpdateProviderServiceUseCase _updateProviderServiceUseCase;
  final UploadProviderServiceImageUseCase _uploadProviderServiceImageUseCase;
  final SetProviderServiceMainImageUseCase _setProviderServiceMainImageUseCase;
  final DeleteProviderServiceImageUseCase _deleteProviderServiceImageUseCase;
  final ProviderReactivityService _providerReactivityService;
  final ImagePicker _imagePicker;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController subtitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController priceLabelController = TextEditingController();
  final TextEditingController badgeController = TextEditingController();
  final TextEditingController mainImageKeyController = TextEditingController();
  final TextEditingController imageKeysController = TextEditingController();

  final ServiceFormData _formData = ServiceFormData();
  final Map<String, String> _fieldErrors = <String, String>{};
  final List<ProviderServiceImage> _images = <ProviderServiceImage>[];

  String? _generalErrorMessage;
  bool _hasLoadedInitialData = false;
  bool _isUploadingImage = false;
  String? _mutatingImageKey;

  ServiceFormData get formData => _formData;
  ServiceCategory? get selectedCategory => _formData.category;
  String? get generalErrorMessage => _generalErrorMessage;
  bool get hasLoadedInitialData => _hasLoadedInitialData;
  List<ProviderServiceImage> get images => List<ProviderServiceImage>.unmodifiable(_images);
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
      final List<ProviderService> services = await _getProviderServicesUseCase();
      final ProviderService? service = _findService(services);
      if (service != null) {
        _applyService(service);
      }
      _hasLoadedInitialData = true;
    } catch (error) {
      _generalErrorMessage = ProviderServicesRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo cargar el servicio.',
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

  void updateSubtitle(String value) {
    _formData.subtitle = value;
    _clearFieldError('subtitle');
  }

  void setCategory(ServiceCategory? value) {
    _formData.category = value;
    _clearFieldError('category');
    notifyListeners();
  }

  void updateDescription(String value) {
    _formData.description = value;
    _clearFieldError('description');
  }

  void updateUnitPrice(String value) {
    _formData.unitPriceInput = value;
    _clearFieldError('unit_price_cents');
  }

  void updatePriceLabel(String value) {
    _formData.priceLabel = value;
    _clearFieldError('price_label');
  }

  void updateBadge(String value) {
    _formData.badge = value;
    _clearFieldError('badge');
  }

  void updateMainImageKey(String value) {
    _formData.mainImageKey = value;
    _clearFieldError('main_image_key');
  }

  void updateImageKeys(String value) {
    _formData.imageKeys = ServiceFormData.parseImageKeys(value);
    _clearFieldError('image_keys');
  }

  Future<bool> saveServiceChanges() async {
    _generalErrorMessage = null;
    _fieldErrors.clear();

    if (!_validate()) {
      notifyListeners();
      return false;
    }

    setBusy(true);
    try {
      await _updateProviderServiceUseCase(
        serviceId: serviceId,
        request: ProviderServiceUpsertRequest.fromForm(_formData),
      );
      await _providerReactivityService.notifyServicesChanged();
      return true;
    } catch (error) {
      final ProviderRequestError requestError =
          ProviderServicesRepository.mapRequestError(error);
      _generalErrorMessage = requestError.message;
      _fieldErrors
        ..clear()
        ..addAll(requestError.fieldErrors);
      notifyListeners();
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<String?> uploadImage() async {
    if (_isUploadingImage) {
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
        ProviderServiceImage.fromJson(
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

      final ProviderServiceImageUploadResponse response =
          await _uploadProviderServiceImageUseCase(
            serviceId: serviceId,
            filePath: selectedFile.path,
            isMain: _images.isEmpty,
          );

      _mergeUploadedImage(
        response.image.copyWith(
          key: response.key,
          isMain: response.isMain || isFirstImage,
        ),
      );
      _images.removeWhere((ProviderServiceImage image) => image.key == previewKey);
      _syncFormDataImages();
      await _providerReactivityService.notifyServicesChanged();
      return null;
    } catch (error) {
      if (previewKey != null) {
        _images.removeWhere((ProviderServiceImage image) => image.key == previewKey);
      }
      _syncFormDataImages();
      return ProviderServicesRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo subir la imagen.',
      );
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  Future<String?> markImageAsMain(String imageKey) async {
    if (_mutatingImageKey != null) {
      return null;
    }

    try {
      _mutatingImageKey = imageKey;
      notifyListeners();

      await _setProviderServiceMainImageUseCase(
        serviceId: serviceId,
        imageKey: imageKey,
      );
      _setLocalMainImage(imageKey);
      _syncFormDataImages();
      await _providerReactivityService.notifyServicesChanged();
      return null;
    } catch (error) {
      return ProviderServicesRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo actualizar la imagen principal.',
      );
    } finally {
      _mutatingImageKey = null;
      notifyListeners();
    }
  }

  Future<String?> deleteImage(String imageKey) async {
    if (_mutatingImageKey != null) {
      return null;
    }

    final bool wasMain = _images.any(
      (ProviderServiceImage image) => image.key == imageKey && image.isMain,
    );

    try {
      _mutatingImageKey = imageKey;
      notifyListeners();

      await _deleteProviderServiceImageUseCase(
        serviceId: serviceId,
        imageKey: imageKey,
      );
      _images.removeWhere((ProviderServiceImage image) => image.key == imageKey);

      if (wasMain && _images.isNotEmpty) {
        final String replacementKey = _images.first.key;
        await _setProviderServiceMainImageUseCase(
          serviceId: serviceId,
          imageKey: replacementKey,
        );
        _setLocalMainImage(replacementKey);
      }

      _syncFormDataImages();
      await _providerReactivityService.notifyServicesChanged();
      return null;
    } catch (error) {
      return ProviderServicesRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo eliminar la imagen.',
      );
    } finally {
      _mutatingImageKey = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    subtitleController.dispose();
    descriptionController.dispose();
    unitPriceController.dispose();
    priceLabelController.dispose();
    badgeController.dispose();
    mainImageKeyController.dispose();
    imageKeysController.dispose();
    super.dispose();
  }

  void _applyService(ProviderService service) {
    _formData
      ..name = service.name
      ..subtitle = service.subtitle
      ..description = service.description
      ..category = service.category
      ..unitPriceInput = ServiceFormData.formatCentsToCurrencyInput(
        service.unitPriceCents,
      )
      ..priceLabel = service.priceLabel
      ..badge = service.badge
      ..mainImageKey = service.mainImageKey
      ..imageKeys = List<String>.from(service.imageKeys);

    _images
      ..clear()
      ..addAll(service.images);

    nameController.text = service.name;
    subtitleController.text = service.subtitle;
    descriptionController.text = service.description;
    unitPriceController.text = ServiceFormData.formatCentsToCurrencyInput(
      service.unitPriceCents,
    );
    priceLabelController.text = service.priceLabel;
    badgeController.text = service.badge;
    mainImageKeyController.text = service.mainImageKey;
    imageKeysController.text = ServiceFormData.stringifyImageKeys(
      service.imageKeys,
    );
    _syncFormDataImages();
  }

  ProviderService? _findService(List<ProviderService> services) {
    for (final ProviderService service in services) {
      if (service.id == serviceId) {
        return service;
      }
    }
    return null;
  }

  bool _validate() {
    if (_formData.category == null) {
      _fieldErrors['category'] = 'Selecciona una categoria.';
    }
    if (_formData.name.trim().isEmpty) {
      _fieldErrors['name'] = 'El nombre es obligatorio.';
    }
    if (_formData.subtitle.trim().isEmpty) {
      _fieldErrors['subtitle'] = 'El subtitulo es obligatorio.';
    }
    return _fieldErrors.isEmpty;
  }

  void _clearFieldError(String key) {
    if (_fieldErrors.remove(key) != null || _generalErrorMessage != null) {
      _generalErrorMessage = null;
      notifyListeners();
    }
  }

  void _mergeUploadedImage(ProviderServiceImage uploadedImage) {
    final int index = _images.indexWhere(
      (ProviderServiceImage image) => image.key == uploadedImage.key,
    );
    if (index >= 0) {
      _images[index] = uploadedImage;
    } else {
      _images.add(uploadedImage);
    }

    if (uploadedImage.isMain) {
      _setLocalMainImage(uploadedImage.key);
    }
    _syncFormDataImages();
  }

  void _setLocalMainImage(String imageKey) {
    for (int index = 0; index < _images.length; index++) {
      final ProviderServiceImage image = _images[index];
      _images[index] = image.copyWith(isMain: image.key == imageKey);
    }
  }

  void _syncFormDataImages() {
    String mainImageKey = '';
    final List<String> imageKeys = <String>[];

    for (final ProviderServiceImage image in _images) {
      if (image.key.trim().isEmpty) {
        continue;
      }
      imageKeys.add(image.key);
      if (image.isMain) {
        mainImageKey = image.key;
      }
    }

    if (mainImageKey.isEmpty && imageKeys.isNotEmpty) {
      mainImageKey = imageKeys.first;
      _setLocalMainImage(mainImageKey);
    }

    _formData
      ..mainImageKey = mainImageKey
      ..imageKeys = imageKeys;

    mainImageKeyController.text = mainImageKey;
    imageKeysController.text = ServiceFormData.stringifyImageKeys(imageKeys);
  }
}
