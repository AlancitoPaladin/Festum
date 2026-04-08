import 'dart:async';

import 'package:festum/core/services/auth_state_service.dart';
import 'package:festum/core/services/provider_branding_service.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/core/services/push_notifications_service.dart';
import 'package:festum/features/provider/models/provider_business_profile.dart';
import 'package:festum/features/provider/models/provider_service.dart';
import 'package:festum/features/provider/repositories/provider_business_repository.dart';
import 'package:festum/features/provider/usecases/get_provider_business_profile_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_services_use_case.dart';
import 'package:stacked/stacked.dart';

class ProviderProfileViewModel extends BaseViewModel {
  ProviderProfileViewModel(
    this._getProviderBusinessProfileUseCase,
    this._getProviderServicesUseCase,
    this._authStateService,
    this._providerBrandingService,
    this._providerReactivityService,
    this._pushNotificationsService,
  ) {
    _lastBusinessRevision = _providerReactivityService.businessRevision;
    _lastServicesRevision = _providerReactivityService.servicesRevision;
    _providerReactivityService.addListener(_handleReactivityChanged);
  }

  final GetProviderBusinessProfileUseCase _getProviderBusinessProfileUseCase;
  final GetProviderServicesUseCase _getProviderServicesUseCase;
  final AuthStateService _authStateService;
  final ProviderBrandingService _providerBrandingService;
  final ProviderReactivityService _providerReactivityService;
  final PushNotificationsService _pushNotificationsService;

  ProviderBusinessProfile? _profile;
  List<ProviderService> _services = <ProviderService>[];
  String? _errorMessage;
  int _lastBusinessRevision = 0;
  int _lastServicesRevision = 0;
  bool _hasInitialized = false;

  ProviderBusinessProfile? get profile => _profile;
  List<String> get serviceNames => _services
      .map((ProviderService item) => item.name.trim())
      .where((String item) => item.isNotEmpty)
      .toList();
  String? get errorMessage => _errorMessage;
  bool get hasContent => _profile != null;

  String get businessName {
    final String name = _profile?.businessName.trim() ?? '';
    if (name.isNotEmpty) {
      return name;
    }
    final String brandingName = _providerBrandingService.businessName.trim();
    return brandingName.isNotEmpty ? brandingName : 'Tu negocio';
  }

  String get logoUrl {
    final String profileLogo = _profile?.logoUrl.trim() ?? '';
    if (profileLogo.isNotEmpty) {
      return profileLogo;
    }
    return _providerBrandingService.logoUrl.trim();
  }

  String get locationLabel {
    final String coverage = _profile?.coverageArea.trim() ?? '';
    if (coverage.isNotEmpty) {
      return coverage;
    }
    final String location = _profile?.location.trim() ?? '';
    if (location.isNotEmpty) {
      return location;
    }
    return 'Cobertura por definir';
  }

  String get memberSinceLabel {
    final DateTime? createdAt = _profile?.createdAt;
    if (createdAt == null) {
      return 'Miembro reciente';
    }
    return 'Miembro desde ${_formatMemberSince(createdAt)}';
  }

  Future<void> initialise() async {
    if (isBusy) {
      return;
    }

    setBusy(true);
    _errorMessage = null;
    try {
      final List<Object> results = await Future.wait<Object>(<Future<Object>>[
        _getProviderBusinessProfileUseCase(),
        _getProviderServicesUseCase(),
      ]);
      _profile = results[0] as ProviderBusinessProfile;
      _services = results[1] as List<ProviderService>;
      _lastBusinessRevision = _providerReactivityService.businessRevision;
      _lastServicesRevision = _providerReactivityService.servicesRevision;
      _hasInitialized = true;
    } catch (error) {
      _errorMessage = ProviderBusinessRepository.mapApiError(error);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _pushNotificationsService.unregisterCurrentDeviceToken();
    await _providerBrandingService.clear();
    await _providerReactivityService.clear();
    await _authStateService.signOut();
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

    final bool businessChanged =
        _lastBusinessRevision != _providerReactivityService.businessRevision;
    final bool servicesChanged =
        _lastServicesRevision != _providerReactivityService.servicesRevision;

    if (!businessChanged && !servicesChanged) {
      return;
    }

    _lastBusinessRevision = _providerReactivityService.businessRevision;
    _lastServicesRevision = _providerReactivityService.servicesRevision;

    if (isBusy) {
      return;
    }

    unawaited(initialise());
  }
}

String _formatMemberSince(DateTime date) {
  const List<String> months = <String>[
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  return '${months[date.month - 1]} de ${date.year}';
}
