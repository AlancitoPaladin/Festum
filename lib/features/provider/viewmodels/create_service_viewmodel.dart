import 'package:festum/features/provider/models/provider_request_error.dart';
import 'package:festum/features/provider/models/provider_service.dart';
import 'package:festum/features/provider/models/provider_service_upsert_request.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/models/service_form_data.dart';
import 'package:festum/features/provider/repositories/provider_services_repository.dart';
import 'package:festum/features/provider/usecases/create_provider_service_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_service_status_use_case.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class CreateServiceViewModel extends BaseViewModel {
  CreateServiceViewModel(
    this._createProviderServiceUseCase,
    this._updateProviderServiceStatusUseCase,
    this._providerReactivityService,
  );

  final CreateProviderServiceUseCase _createProviderServiceUseCase;
  final UpdateProviderServiceStatusUseCase _updateProviderServiceStatusUseCase;
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
  String? get firstErrorField {
    const List<String> order = <String>[
      'category',
      'name',
      'subtitle',
      'unit_price_cents',
      'description',
    ];
    for (final String field in order) {
      if (_fieldErrors.containsKey(field)) {
        return field;
      }
    }
    return null;
  }

  bool get canSubmit =>
      _formData.category != null &&
      _formData.name.trim().isNotEmpty &&
      _formData.subtitle.trim().isNotEmpty &&
      _formData.unitPriceCents > 0;
  bool get hasPendingChanges =>
      _formData.category != null ||
      _formData.name.trim().isNotEmpty ||
      _formData.subtitle.trim().isNotEmpty ||
      _formData.description.trim().isNotEmpty ||
      _formData.unitPriceInput.trim().isNotEmpty ||
      _formData.mainImageKey.trim().isNotEmpty ||
      _formData.imageKeys.isNotEmpty;

  String get previewName {
    final String value = _formData.name.trim();
    return value.isEmpty ? 'Servicio sin nombre' : value;
  }

  String get previewSubtitle {
    final String value = _formData.subtitle.trim();
    return value.isEmpty ? 'Sin descripcion breve' : value;
  }

  String get previewBadge {
    final String manual = _formData.badge.trim();
    if (manual.isNotEmpty) {
      return manual;
    }
    final ServiceCategory? category = _formData.category;
    if (category == null) {
      return '';
    }
    switch (category) {
      case ServiceCategory.venue:
        return 'Espacio';
      case ServiceCategory.furniture:
      case ServiceCategory.equipment:
        return 'Renta';
      case ServiceCategory.banquet:
        return 'Catering';
      case ServiceCategory.dj:
        return 'Musica';
      case ServiceCategory.decoration:
        return 'Decoracion';
      case ServiceCategory.photography:
        return 'Foto y video';
      case ServiceCategory.entertainment:
        return 'Show';
    }
  }

  String get previewPriceLabel {
    final int cents = _formData.unitPriceCents;
    if (cents <= 0) {
      return 'Precio por definir';
    }
    final double amount = cents / 100;
    final String fixed = amount.toStringAsFixed(
      amount.truncateToDouble() == amount ? 0 : 2,
    );
    final List<String> parts = fixed.split('.');
    final String whole = parts.first;
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final int reverseIndex = whole.length - i;
      buffer.write(whole[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    final String decimal = parts.length > 1 && parts[1] != '00'
        ? '.${parts[1]}'
        : '';
    return 'Desde \$$buffer$decimal MXN';
  }

  void updateName(String value) {
    _formData.name = value;
    final bool notified = _clearFieldError('name');
    if (!notified) {
      notifyListeners();
    }
  }

  void updateSubtitle(String value) {
    _formData.subtitle = value;
    final bool notified = _clearFieldError('subtitle');
    if (!notified) {
      notifyListeners();
    }
  }

  void setCategory(ServiceCategory? category) {
    _formData.category = category;
    final bool notified = _clearFieldError('category');
    if (!notified) {
      notifyListeners();
    }
  }

  void updateDescription(String value) {
    _formData.description = value;
    final bool notified = _clearFieldError('description');
    if (!notified) {
      notifyListeners();
    }
  }

  void updateUnitPrice(String value) {
    final bool hadInlineError = _fieldErrors.containsKey('unit_price_cents');
    final bool hadGeneralError = _generalErrorMessage != null;
    _formData.unitPriceInput = value;
    final bool notified = _clearFieldError('unit_price_cents');
    if (!notified && !hadInlineError && !hadGeneralError) {
      notifyListeners();
    }
  }

  void updatePriceLabel(String value) {
    _formData.priceLabel = value;
    final bool notified = _clearFieldError('price_label');
    if (!notified) {
      notifyListeners();
    }
  }

  void updateBadge(String value) {
    _formData.badge = value;
    final bool notified = _clearFieldError('badge');
    if (!notified) {
      notifyListeners();
    }
  }

  void updateMainImageKey(String value) {
    _formData.mainImageKey = value;
    final bool notified = _clearFieldError('main_image_key');
    if (!notified) {
      notifyListeners();
    }
  }

  void updateImageKeys(String value) {
    _formData.imageKeys = ServiceFormData.parseImageKeys(value);
    final bool notified = _clearFieldError('image_keys');
    if (!notified) {
      notifyListeners();
    }
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
      final ProviderService createdService =
          await _createProviderServiceUseCase(
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

  Future<String?> publishService(String serviceId) async {
    try {
      await _updateProviderServiceStatusUseCase(
        serviceId: serviceId,
        status: 'published',
      );
      await _providerReactivityService.notifyServicesChanged();
      return null;
    } catch (error) {
      return ProviderServicesRepository.mapApiError(
        error,
        fallbackMessage: 'El servicio se guardo, pero no se pudo publicar.',
      );
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
    if (_formData.unitPriceCents <= 0) {
      _fieldErrors['unit_price_cents'] =
          'Ingresa un precio de referencia mayor a 0.';
    }
    return _fieldErrors.isEmpty;
  }

  bool _clearFieldError(String key) {
    if (_fieldErrors.remove(key) != null || _generalErrorMessage != null) {
      _generalErrorMessage = null;
      notifyListeners();
      return true;
    }
    return false;
  }
}
