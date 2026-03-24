import 'package:festum/app/router/app_routes.dart';
import 'package:festum/features/provider/models/product_reservations_response.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/repositories/provider_reservations_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:stacked/stacked.dart';

class ReservationsViewModel extends BaseViewModel {
  ReservationsViewModel(this._repository);

  final ProviderReservationsRepository _repository;

  List<ProductReservationSummary> _products = <ProductReservationSummary>[];
  String? _errorMessage;

  List<ProductReservationSummary> get products =>
      List<ProductReservationSummary>.unmodifiable(_products);
  String? get errorMessage => _errorMessage;

  Future<void> initialise() async {
    setBusy(true);
    _errorMessage = null;

    try {
      _products = await _repository.fetchProducts();
    } catch (error) {
      _errorMessage = ProviderReservationsRepository.mapApiError(error);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<String?> deleteProduct(String productId) async {
    try {
      await _repository.deleteProduct(productId);
      _products = _products
          .where((ProductReservationSummary item) => item.id != productId)
          .toList();
      notifyListeners();
      return null;
    } catch (error) {
      return ProviderReservationsRepository.mapApiError(error);
    }
  }

  void editProduct(
    BuildContext context,
    String productId,
    ServiceCategory category,
  ) {
    final ProductReservationSummary product = _products.firstWhere(
      (ProductReservationSummary item) => item.id == productId,
    );

    context.push(
      AppRoutes.providerEditProductRoute(category.name, product.id),
      extra: <String, String>{'serviceId': product.serviceId},
    );
  }

  void manageAvailability(BuildContext context, String id, String name) {
    context.push(AppRoutes.providerAvailabilityRoute(id, name));
  }
}
