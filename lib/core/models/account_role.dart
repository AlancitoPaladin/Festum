enum AccountRole {
  provider,
  client;

  String get storageValue {
    switch (this) {
      case AccountRole.provider:
        return 'provider';
      case AccountRole.client:
        return 'client';
    }
  }

  String get routeValue {
    switch (this) {
      case AccountRole.provider:
        return 'proveedor';
      case AccountRole.client:
        return 'cliente';
    }
  }

  String get title {
    switch (this) {
      case AccountRole.provider:
        return 'Regístrate como Proveedor de servicios';
      case AccountRole.client:
        return 'Regístrate como Cliente';
    }
  }

  String get shortLabel {
    switch (this) {
      case AccountRole.provider:
        return 'Proveedor';
      case AccountRole.client:
        return 'Cliente';
    }
  }

  static AccountRole? fromStorage(String? value) {
    switch (value) {
      case 'provider':
        return AccountRole.provider;
      case 'client':
        return AccountRole.client;
      default:
        return null;
    }
  }

  static AccountRole? fromRoute(String? value) {
    switch (value) {
      case 'proveedor':
        return AccountRole.provider;
      case 'cliente':
        return AccountRole.client;
      default:
        return null;
    }
  }
}
