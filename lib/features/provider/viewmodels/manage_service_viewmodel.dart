import 'dart:async';

import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/features/provider/models/provider_product.dart';
import 'package:festum/features/provider/models/provider_service.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/repositories/provider_products_repository.dart';
import 'package:festum/features/provider/usecases/delete_provider_service_product_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_service_products_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_services_use_case.dart';
import 'package:stacked/stacked.dart';

class ManageServiceViewModel extends BaseViewModel {
  ManageServiceViewModel({
    required this.serviceId,
    required this.serviceName,
    required this.category,
    required GetProviderServicesUseCase getProviderServicesUseCase,
    required GetProviderServiceProductsUseCase getProviderServiceProductsUseCase,
    required DeleteProviderServiceProductUseCase
    deleteProviderServiceProductUseCase,
    required ProviderReactivityService providerReactivityService,
  }) : _getProviderServicesUseCase = getProviderServicesUseCase,
       _getProviderServiceProductsUseCase = getProviderServiceProductsUseCase,
       _deleteProviderServiceProductUseCase = deleteProviderServiceProductUseCase,
       _providerReactivityService = providerReactivityService {
    _lastProductsRevision = _providerReactivityService.productsRevision;
    _providerReactivityService.addListener(_handleReactivityChanged);
  }

  final String serviceId;
  final String serviceName;
  final ServiceCategory category;
  final GetProviderServicesUseCase _getProviderServicesUseCase;
  final GetProviderServiceProductsUseCase _getProviderServiceProductsUseCase;
  final DeleteProviderServiceProductUseCase
  _deleteProviderServiceProductUseCase;
  final ProviderReactivityService _providerReactivityService;

  List<ProviderProduct> _products = <ProviderProduct>[];
  ProviderService? _service;
  final Set<String> _deletingProductIds = <String>{};
  String? _errorMessage;
  int _lastProductsRevision = 0;
  bool _hasInitialized = false;

  List<ProviderProduct> get products =>
      List<ProviderProduct>.unmodifiable(_products);
  ProviderService? get service => _service;
  bool get isPublished => _service?.isPublished ?? false;
  bool get isInactive => _service?.isInactive ?? false;
  String get statusLabel {
    if (_service == null) {
      return 'Cargando estado';
    }
    if (_service!.isPublished) {
      return 'Publicado';
    }
    if (_service!.isInactive) {
      return 'Inactivo';
    }
    return 'Borrador';
  }
  String? get errorMessage => _errorMessage;

  bool isDeleting(String productId) => _deletingProductIds.contains(productId);

  Future<void> initialise() async {
    setBusy(true);
    _errorMessage = null;

    try {
      final List<ProviderService> services = await _getProviderServicesUseCase();
      ProviderService? matchedService;
      for (final ProviderService item in services) {
        if (item.id == serviceId) {
          matchedService = item;
          break;
        }
      }
      _service = matchedService;
      _products = await _getProviderServiceProductsUseCase(serviceId);
      _lastProductsRevision = _providerReactivityService.productsRevision;
      _hasInitialized = true;
    } catch (error) {
      _errorMessage = ProviderProductsRepository.mapApiError(error);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<String?> deleteProduct(int index) async {
    final ProviderProduct product = _products[index];
    _deletingProductIds.add(product.id);
    notifyListeners();

    try {
      await _deleteProviderServiceProductUseCase(product.id);
      _products.removeAt(index);
      await _providerReactivityService.notifyProductsChanged();
      await _providerReactivityService.notifyServicesChanged();
      notifyListeners();
      return null;
    } catch (error) {
      return ProviderProductsRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo eliminar el producto.',
      );
    } finally {
      _deletingProductIds.remove(product.id);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _providerReactivityService.removeListener(_handleReactivityChanged);
    super.dispose();
  }

  void _handleReactivityChanged() {
    if (!_hasInitialized) {
      return;
    }

    final bool productsChanged =
        _lastProductsRevision != _providerReactivityService.productsRevision;
    if (!productsChanged) {
      return;
    }

    _lastProductsRevision = _providerReactivityService.productsRevision;

    if (isBusy || _deletingProductIds.isNotEmpty) {
      return;
    }

    unawaited(initialise());
  }
}
