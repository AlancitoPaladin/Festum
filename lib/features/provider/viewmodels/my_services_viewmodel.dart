import 'dart:async';

import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/features/provider/models/provider_service.dart';
import 'package:festum/features/provider/repositories/provider_services_repository.dart';
import 'package:festum/features/provider/usecases/get_provider_services_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_service_status_use_case.dart';
import 'package:stacked/stacked.dart';

class MyServicesViewModel extends BaseViewModel {
  MyServicesViewModel(
    this._getProviderServicesUseCase,
    this._updateProviderServiceStatusUseCase,
    this._repository,
    this._providerReactivityService,
  ) {
    _lastServicesRevision = _providerReactivityService.servicesRevision;
    _providerReactivityService.addListener(_handleReactivityChanged);
  }

  final GetProviderServicesUseCase _getProviderServicesUseCase;
  final UpdateProviderServiceStatusUseCase _updateProviderServiceStatusUseCase;
  final ProviderServicesRepository _repository;
  final ProviderReactivityService _providerReactivityService;

  List<ProviderService> _services = <ProviderService>[];
  final Set<String> _mutatingServiceIds = <String>{};
  String? _errorMessage;
  int _lastServicesRevision = 0;
  bool _hasInitialized = false;

  List<ProviderService> get services =>
      List<ProviderService>.unmodifiable(_services);
  String? get errorMessage => _errorMessage;

  bool isMutating(String serviceId) => _mutatingServiceIds.contains(serviceId);

  Future<void> initialise() async {
    setBusy(true);
    _errorMessage = null;

    try {
      _services = await _getProviderServicesUseCase();
      _lastServicesRevision = _providerReactivityService.servicesRevision;
      _hasInitialized = true;
    } catch (error) {
      _errorMessage = ProviderServicesRepository.mapApiError(error);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<String?> toggleServiceStatus(int index) async {
    final ProviderService current = _services[index];
    final String newStatus = current.isPublished ? 'inactive' : 'published';

    _mutatingServiceIds.add(current.id);
    notifyListeners();

    try {
      final ProviderService updated = await _updateProviderServiceStatusUseCase(
        serviceId: current.id,
        status: newStatus,
      );
      _services[index] = updated;
      await _providerReactivityService.notifyServicesChanged();
      notifyListeners();
      return null;
    } catch (error) {
      return ProviderServicesRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo actualizar el estado.',
      );
    } finally {
      _mutatingServiceIds.remove(current.id);
      notifyListeners();
    }
  }

  Future<String?> deleteService(int index) async {
    final ProviderService service = _services[index];
    _mutatingServiceIds.add(service.id);
    notifyListeners();

    try {
      await _repository.deleteService(service.id);
      _services.removeAt(index);
      await _providerReactivityService.notifyServicesChanged();
      notifyListeners();
      return null;
    } catch (error) {
      return ProviderServicesRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo eliminar el servicio.',
      );
    } finally {
      _mutatingServiceIds.remove(service.id);
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

    final bool servicesChanged =
        _lastServicesRevision != _providerReactivityService.servicesRevision;
    if (!servicesChanged) {
      return;
    }

    _lastServicesRevision = _providerReactivityService.servicesRevision;

    if (isBusy || _mutatingServiceIds.isNotEmpty) {
      return;
    }

    unawaited(initialise());
  }
}
