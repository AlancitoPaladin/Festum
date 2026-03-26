import 'dart:async';

import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/features/provider/models/product_reservations_response.dart';
import 'package:festum/features/provider/repositories/provider_reservations_repository.dart';
import 'package:festum/features/provider/usecases/delete_provider_product_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_product_reservations_use_case.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:stacked/stacked.dart';

class ReservationsViewModel extends BaseViewModel {
  ReservationsViewModel(
    this._getProviderProductReservationsUseCase,
    this._deleteProviderProductUseCase,
    this._providerReactivityService,
  ) {
    _lastProductsRevision = _providerReactivityService.productsRevision;
    _providerReactivityService.addListener(_handleReactivityChanged);
  }

  final GetProviderProductReservationsUseCase
  _getProviderProductReservationsUseCase;
  final DeleteProviderProductUseCase _deleteProviderProductUseCase;
  final ProviderReactivityService _providerReactivityService;

  List<ProductReservationSummary> _products = <ProductReservationSummary>[];
  String? _errorMessage;
  int _lastProductsRevision = 0;
  bool _hasInitialized = false;

  List<ProductReservationSummary> get products =>
      List<ProductReservationSummary>.unmodifiable(_products);
  String? get errorMessage => _errorMessage;

  Future<void> initialise() async {
    setBusy(true);
    _errorMessage = null;

    try {
      _products = await _getProviderProductReservationsUseCase();
      _lastProductsRevision = _providerReactivityService.productsRevision;
      _hasInitialized = true;
    } catch (error) {
      _errorMessage = ProviderReservationsRepository.mapApiError(error);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<String?> deleteProduct(String productId) async {
    try {
      await _deleteProviderProductUseCase(productId);
      _products = _products
          .where((ProductReservationSummary item) => item.id != productId)
          .toList();
      await _providerReactivityService.notifyProductsChanged();
      await _providerReactivityService.notifyServicesChanged();
      notifyListeners();
      return null;
    } catch (error) {
      return ProviderReservationsRepository.mapApiError(error);
    }
  }

  void editProduct(
    BuildContext context,
    String productId,
  ) {
    final ProductReservationSummary product = _products.firstWhere(
      (ProductReservationSummary item) => item.id == productId,
    );

    context.push(
      AppRoutes.providerEditProductRoute(product.id),
      extra: <String, String>{'serviceId': product.serviceId},
    );
  }

  void manageAvailability(BuildContext context, String id, String name) {
    context.push(AppRoutes.providerAvailabilityRoute(id, name));
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

    if (isBusy) {
      return;
    }

    unawaited(initialise());
  }
}

