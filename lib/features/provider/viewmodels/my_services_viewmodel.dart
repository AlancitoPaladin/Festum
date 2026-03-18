import 'package:festum/features/provider/viewmodels/add_service_viewmodel.dart';
import 'package:stacked/stacked.dart';

class ProviderService {
  final String id;
  final String name;
  final ServiceCategory category;
  bool isActive;

  ProviderService({
    required this.id,
    required this.name,
    required this.category,
    this.isActive = true,
  });
}

class MyServicesViewModel extends BaseViewModel {
  List<ProviderService> _services = [
    ProviderService(id: '1', name: 'DJ para eventos', category: ServiceCategory.dj),
    ProviderService(id: '2', name: 'Renta de mobiliario', category: ServiceCategory.furniture, isActive: false),
    ProviderService(id: '3', name: 'Banquetes y catering', category: ServiceCategory.banquet),
    ProviderService(id: '4', name: 'Salón de eventos', category: ServiceCategory.venue),
  ];

  List<ProviderService> get services => _services;

  void toggleServiceStatus(int index) {
    _services[index].isActive = !_services[index].isActive;
    notifyListeners();
  }

  void deleteService(int index) {
    _services.removeAt(index);
    notifyListeners();
  }
}
