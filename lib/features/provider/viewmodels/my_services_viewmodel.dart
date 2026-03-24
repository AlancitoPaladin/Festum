import 'package:festum/features/provider/models/provider_service.dart';
import 'package:festum/features/provider/repositories/provider_services_repository.dart';
import 'package:stacked/stacked.dart';

class MyServicesViewModel extends BaseViewModel {
  MyServicesViewModel(this._repository);

  final ProviderServicesRepository _repository;

  List<ProviderService> _services = <ProviderService>[];
  String? _errorMessage;

  List<ProviderService> get services =>
      List<ProviderService>.unmodifiable(_services);
  String? get errorMessage => _errorMessage;

  Future<void> initialise() async {
    setBusy(true);
    _errorMessage = null;

    try {
      _services = await _repository.fetchServices();
    } catch (error) {
      _errorMessage = ProviderServicesRepository.mapApiError(error);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<String?> toggleServiceStatus(int index) async {
    final ProviderService current = _services[index];
    final String newStatus = current.isActive ? 'inactive' : 'active';

    try {
      final ProviderService updated = await _repository.updateStatus(
        current.id,
        newStatus,
      );
      _services[index] = updated;
      notifyListeners();
      return null;
    } catch (error) {
      return ProviderServicesRepository.mapApiError(error);
    }
  }

  Future<String?> deleteService(int index) async {
    final ProviderService service = _services[index];

    try {
      await _repository.deleteService(service.id);
      _services.removeAt(index);
      notifyListeners();
      return null;
    } catch (error) {
      return ProviderServicesRepository.mapApiError(error);
    }
  }
}
