import 'package:festum/features/provider/models/provider_request_error.dart';
import 'package:festum/features/provider/models/provider_service.dart';
import 'package:festum/features/provider/models/provider_service_upsert_request.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/models/service_form_data.dart';
import 'package:festum/features/provider/repositories/provider_services_repository.dart';
import 'package:festum/features/provider/usecases/create_provider_service_use_case.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class CreateServiceViewModel extends BaseViewModel {
  CreateServiceViewModel(
    this._createProviderServiceUseCase,
    this._providerReactivityService,
  );

  final CreateProviderServiceUseCase _createProviderServiceUseCase;
  final ProviderReactivityService _providerReactivityService;

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

  String? _generalErrorMessage;

  ServiceFormData get formData => _formData;
  ServiceCategory? get selectedCategory => _formData.category;
  String? get generalErrorMessage => _generalErrorMessage;
  String? fieldError(String key) => _fieldErrors[key];

  void updateName(String value) {
    _formData.name = value;
    _clearFieldError('name');
  }

  void updateSubtitle(String value) {
    _formData.subtitle = value;
    _clearFieldError('subtitle');
  }

  void setCategory(ServiceCategory? category) {
    _formData.category = category;
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

  Future<ProviderService?> saveService() async {
    _generalErrorMessage = null;
    _fieldErrors.clear();

    if (!_validate()) {
      notifyListeners();
      return null;
    }

    setBusy(true);
    try {
      final ProviderService createdService = await _createProviderServiceUseCase(
        ProviderServiceUpsertRequest.fromForm(_formData),
      );
      await _providerReactivityService.notifyServicesChanged();
      return createdService;
    } catch (error) {
      final ProviderRequestError requestError =
          ProviderServicesRepository.mapRequestError(error);
      _generalErrorMessage = requestError.message;
      _fieldErrors
        ..clear()
        ..addAll(requestError.fieldErrors);
      notifyListeners();
      return null;
    } finally {
      setBusy(false);
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
}
