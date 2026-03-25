import 'dart:async';

import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/features/provider/models/booking.dart';
import 'package:festum/features/provider/repositories/provider_bookings_repository.dart';
import 'package:festum/features/provider/usecases/get_provider_booking_detail_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_booking_status_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_booking_use_case.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetailViewModel extends BaseViewModel {
  BookingDetailViewModel(
    Booking booking, {
    GetProviderBookingDetailUseCase? getProviderBookingDetailUseCase,
    UpdateProviderBookingUseCase? updateProviderBookingUseCase,
    UpdateProviderBookingStatusUseCase? updateProviderBookingStatusUseCase,
    ProviderReactivityService? providerReactivityService,
  }) : _bookingDetail = booking,
       _getProviderBookingDetailUseCase =
           getProviderBookingDetailUseCase ??
           locator<GetProviderBookingDetailUseCase>(),
       _updateProviderBookingUseCase =
           updateProviderBookingUseCase ??
           locator<UpdateProviderBookingUseCase>(),
       _updateProviderBookingStatusUseCase =
           updateProviderBookingStatusUseCase ??
           locator<UpdateProviderBookingStatusUseCase>(),
       _providerReactivityService =
           providerReactivityService ?? locator<ProviderReactivityService>() {
    unawaited(initialise());
  }

  Booking _bookingDetail;
  final GetProviderBookingDetailUseCase _getProviderBookingDetailUseCase;
  final UpdateProviderBookingUseCase _updateProviderBookingUseCase;
  final UpdateProviderBookingStatusUseCase _updateProviderBookingStatusUseCase;
  final ProviderReactivityService _providerReactivityService;

  String? errorMessage;

  Booking get bookingDetail => _bookingDetail;

  Future<void> initialise() async {
    setBusy(true);
    errorMessage = null;
    try {
      _bookingDetail = await _getProviderBookingDetailUseCase(_bookingDetail.id);
    } catch (error) {
      errorMessage = ProviderBookingsRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo cargar el detalle de la reserva.',
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void contactCustomer() {
    unawaited(_contactCustomer());
  }

  Future<void> _contactCustomer() async {
    final String phone = _bookingDetail.customerPhone.trim();
    if (phone.isEmpty) {
      errorMessage = 'Esta reserva no tiene un numero telefonico disponible.';
      notifyListeners();
      return;
    }

    final Uri uri = Uri(scheme: 'tel', path: phone);
    final bool launched = await launchUrl(uri);
    if (!launched) {
      errorMessage = 'No se pudo abrir el marcador del sistema.';
      notifyListeners();
    }
  }

  Future<void> cancelBooking() async {
    setBusy(true);
    errorMessage = null;
    try {
      _bookingDetail = await _updateProviderBookingStatusUseCase(
        bookingId: _bookingDetail.id,
        status: 'cancelled',
      );
      await _providerReactivityService.notifyProductsChanged();
    } catch (error) {
      errorMessage = ProviderBookingsRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo cancelar la reserva.',
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void modifyBooking() {
    // El caso de uso ya esta conectado; la navegacion/edicion queda lista para el siguiente paso.
    _updateProviderBookingUseCase;
  }
}
