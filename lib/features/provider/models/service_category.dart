enum ServiceCategory {
  dj('Música / DJ'),
  banquet('Banquetes / Catering'),
  furniture('Alquiler de mobiliario'),
  venue('Salones / Espacios'),
  decoration('Decoración'),
  photography('Fotografía y video'),
  entertainment('Entretenimiento'),
  equipment('Alquiler de equipo');

  const ServiceCategory(this.label);

  final String label;

  String get providerApiValue {
    switch (this) {
      case ServiceCategory.venue:
        return 'salones-sociales';
      case ServiceCategory.furniture:
        return 'mobiliario';
      case ServiceCategory.equipment:
        return 'mobiliario';
      case ServiceCategory.banquet:
        return 'banquetes';
      case ServiceCategory.dj:
        return 'dj';
      case ServiceCategory.decoration:
        return 'decoration';
      case ServiceCategory.photography:
        return 'photography';
      case ServiceCategory.entertainment:
        return 'entertainment';
    }
  }

  static ServiceCategory? tryFromProviderApiValue(String value) {
    switch (value.trim().toLowerCase()) {
      case 'salones-sociales':
      case 'venue':
        return ServiceCategory.venue;
      case 'mobiliario':
      case 'furniture':
        return ServiceCategory.furniture;
      case 'banquetes':
      case 'banquet':
        return ServiceCategory.banquet;
      case 'equipment':
        return ServiceCategory.equipment;
      case 'decoracion':
      case 'decoration':
        return ServiceCategory.decoration;
      case 'fotografia':
      case 'photography':
        return ServiceCategory.photography;
      case 'entretenimiento':
      case 'entertainment':
        return ServiceCategory.entertainment;
      case 'dj':
        return ServiceCategory.dj;
      default:
        return null;
    }
  }

  static ServiceCategory fromProviderApiValue(String value) {
    return tryFromProviderApiValue(value) ?? ServiceCategory.dj;
  }

  static const List<ServiceCategory> providerServiceOptions = <ServiceCategory>[
    ServiceCategory.dj,
    ServiceCategory.banquet,
    ServiceCategory.furniture,
    ServiceCategory.venue,
    ServiceCategory.decoration,
    ServiceCategory.photography,
    ServiceCategory.entertainment,
  ];
}
