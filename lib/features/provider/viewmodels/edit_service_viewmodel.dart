import 'package:festum/features/provider/models/edit_service_form_data.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:stacked/stacked.dart';

class EditServiceViewModel extends BaseViewModel {
  final String serviceId;
  final String serviceName;
  final ServiceCategory category;
  final EditServiceFormData _formData;

  EditServiceViewModel({
    required this.serviceId,
    required this.serviceName,
    required this.category,
  }) : _formData = EditServiceFormData(
         name: serviceName,
         category: category,
       ) {
    _loadRegisteredService();
  }

  EditServiceFormData get formData => _formData;
  ServiceCategory? get selectedCategory => _formData.category;

  void _loadRegisteredService() {
    switch (serviceId) {
      case '1':
        _formData.description =
            'Servicio de DJ para bodas, XV años y eventos corporativos con audio profesional, iluminación y atención personalizada.';
        _formData.imageUrls = <String>['dj-cover', 'dj-lights'];
        break;
      case '2':
        _formData.description =
            'Renta de mobiliario para eventos con mesas, sillas y montaje según el tipo de celebración.';
        _formData.imageUrls = <String>['furniture-main'];
        break;
      case '3':
        _formData.description =
            'Banquetes para eventos sociales con menús personalizados, montaje y servicio durante el evento.';
        _formData.imageUrls = <String>['banquet-main', 'banquet-dessert'];
        break;
      case '4':
        _formData.description =
            'Salón para eventos con capacidad amplia, área de recepción y opciones de ambientación.';
        _formData.imageUrls = <String>[
          'venue-main',
          'venue-stage',
          'venue-lobby',
        ];
        break;
      default:
        _formData.description =
            'Actualiza aquí la información del servicio que registraste anteriormente.';
        _formData.imageUrls = <String>[];
    }

    notifyListeners();
  }

  void updateName(String value) {
    _formData.name = value;
    notifyListeners();
  }

  void setCategory(ServiceCategory? value) {
    _formData.category = value;
    notifyListeners();
  }

  void updateDescription(String value) {
    _formData.description = value;
    notifyListeners();
  }

  void addPhoto() {
    if (_formData.imageUrls.length >= 3) {
      return;
    }

    _formData.imageUrls = List<String>.from(_formData.imageUrls)
      ..add('mock-image-${_formData.imageUrls.length + 1}');
    notifyListeners();
  }

  Future<void> saveServiceChanges() async {
    setBusy(true);
    await Future.delayed(const Duration(seconds: 2));
    setBusy(false);
  }
}
