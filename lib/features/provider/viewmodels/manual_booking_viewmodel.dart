import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/features/provider/models/booking.dart';
import 'package:festum/features/provider/models/manual_booking_request.dart';
import 'package:festum/features/provider/models/update_booking_request.dart';
import 'package:festum/features/provider/repositories/provider_bookings_repository.dart';
import 'package:festum/features/provider/usecases/create_manual_booking_use_case.dart';
import 'package:festum/features/provider/usecases/update_provider_booking_use_case.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ManualBookingViewModel extends BaseViewModel {
  ManualBookingViewModel({
    required this.productId,
    required CreateManualBookingUseCase createManualBookingUseCase,
    required UpdateProviderBookingUseCase updateProviderBookingUseCase,
    required ProviderReactivityService providerReactivityService,
    DateTime? initialDate,
    Booking? initialBooking,
  }) : _createManualBookingUseCase = createManualBookingUseCase,
       _updateProviderBookingUseCase = updateProviderBookingUseCase,
       _providerReactivityService = providerReactivityService,
       _initialBooking = initialBooking,
       selectedDate = _resolveInitialSelectedDate(
         initialBooking: initialBooking,
         initialDate: initialDate,
       ) {
    customerNameController.text = initialBooking?.customerName ?? '';
    eventTypeController.text = initialBooking?.eventType ?? '';
    guestsController.text = initialBooking == null || initialBooking.guests == 0
        ? ''
        : initialBooking.guests.toString();
    contactPhoneController.text = initialBooking?.customerPhone ?? '';
    contactEmailController.text = initialBooking?.contactEmail ?? '';
    eventLocationController.text = initialBooking?.eventLocation ?? '';
    notesController.text = initialBooking?.notes ?? '';
    totalAmountController.text = _initialTextAmount(
      initialBooking?.totalAmount,
    );
    paidAmountController.text = _initialTextAmount(initialBooking?.paidAmount);
    hasSpecificSchedule = _hasSchedule(initialBooking);
    startTime = _readStartTime(initialBooking?.time);
    endTime = _readEndTime(initialBooking?.time);
    totalAmountController.addListener(_handleAmountChanged);
    paidAmountController.addListener(_handleAmountChanged);
  }

  final String productId;
  final CreateManualBookingUseCase _createManualBookingUseCase;
  final UpdateProviderBookingUseCase _updateProviderBookingUseCase;
  final ProviderReactivityService _providerReactivityService;
  final Booking? _initialBooking;

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController eventTypeController = TextEditingController();
  final TextEditingController guestsController = TextEditingController();
  final TextEditingController contactPhoneController = TextEditingController();
  final TextEditingController contactEmailController = TextEditingController();
  final TextEditingController eventLocationController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController paidAmountController = TextEditingController();

  DateTime? selectedDate;
  bool hasSpecificSchedule = false;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? errorMessage;

  bool get isEditMode => _initialBooking != null;

  String get screenTitle => isEditMode ? 'Modificar reserva' : 'Reserva manual';

  String get actionLabel =>
      isEditMode ? 'Guardar cambios' : 'Confirmar reserva';

  String get introText => isEditMode
      ? 'Actualiza la información de la reserva sin cambiar la experiencia visual del flujo actual.'
      : 'Registra una reserva externa para bloquear la fecha en tu calendario.';

  double get totalAmount => _parseAmount(totalAmountController.text);
  double get paidAmount => _parseAmount(paidAmountController.text);
  double get pendingAmount {
    final double pending = totalAmount - paidAmount;
    return pending < 0 ? 0 : pending;
  }

  DateTime get minimumSelectableDate => _today();

  DateTime get pickerInitialDate {
    final DateTime? current = selectedDate;
    if (current == null || _isPastDate(current)) {
      return minimumSelectableDate;
    }
    return _dateOnly(current);
  }

  void setDate(DateTime date) {
    selectedDate = _dateOnly(date);
    _clearError();
    notifyListeners();
  }

  void toggleSpecificSchedule(bool value) {
    hasSpecificSchedule = value;
    if (!value) {
      startTime = null;
      endTime = null;
    }
    _clearError();
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    startTime = time;
    _clearError();
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    endTime = time;
    _clearError();
    notifyListeners();
  }

  Future<Booking?> saveBooking() async {
    final String? validationError = _validate();
    if (validationError != null) {
      errorMessage = validationError;
      notifyListeners();
      return null;
    }

    setBusy(true);
    errorMessage = null;
    try {
      final Booking booking = isEditMode
          ? await _updateProviderBookingUseCase(
              _initialBooking!.id,
              UpdateBookingRequest(
                customerName: customerNameController.text,
                eventDate: selectedDate,
                hasSpecificSchedule: hasSpecificSchedule,
                startTime: hasSpecificSchedule ? _formatTime(startTime) : null,
                endTime: hasSpecificSchedule ? _formatTime(endTime) : null,
                eventType: eventTypeController.text,
                guests: _parsedGuests,
                contactPhone: contactPhoneController.text,
                contactEmail: contactEmailController.text,
                eventLocation: eventLocationController.text,
                paymentDetails: '',
                totalAmount: totalAmount,
                paidAmount: paidAmount,
                notes: notesController.text,
              ),
            )
          : await _createManualBookingUseCase(
              productId: productId,
              request: ManualBookingRequest(
                customerName: customerNameController.text,
                customerImageUrl: '',
                eventDate: selectedDate!,
                hasSpecificSchedule: hasSpecificSchedule,
                startTime: startTime,
                endTime: endTime,
                eventType: eventTypeController.text,
                guests: _parsedGuests,
                contactPhone: contactPhoneController.text,
                contactEmail: contactEmailController.text,
                eventLocation: eventLocationController.text,
                paymentDetails: '',
                totalAmount: totalAmount,
                paidAmount: paidAmount,
                notes: notesController.text,
              ),
            );

      await _providerReactivityService.notifyProductsChanged();
      return booking;
    } catch (error) {
      errorMessage = ProviderBookingsRepository.mapApiError(
        error,
        fallbackMessage: isEditMode
            ? 'No se pudo actualizar la reserva.'
            : 'No se pudo crear la reserva manual.',
      );
      notifyListeners();
      return null;
    } finally {
      setBusy(false);
    }
  }

  String? _validate() {
    if (customerNameController.text.trim().isEmpty) {
      return 'Ingresa el nombre del cliente.';
    }
    if (selectedDate == null) {
      return 'Selecciona una fecha.';
    }
    if (_isPastDate(selectedDate!)) {
      return 'Selecciona una fecha de hoy en adelante.';
    }
    if (eventTypeController.text.trim().isEmpty) {
      return 'Ingresa el tipo de evento.';
    }
    if (totalAmount < 0 || paidAmount < 0) {
      return 'Los montos no pueden ser negativos.';
    }
    if (paidAmount > totalAmount) {
      return 'El monto pagado no puede ser mayor al total.';
    }
    if (hasSpecificSchedule) {
      if (startTime == null || endTime == null) {
        return 'Selecciona hora de inicio y fin.';
      }
      final int startMinutes = startTime!.hour * 60 + startTime!.minute;
      final int endMinutes = endTime!.hour * 60 + endTime!.minute;
      if (endMinutes <= startMinutes) {
        return 'La hora de fin debe ser mayor que la de inicio.';
      }
    }
    return null;
  }

  int get _parsedGuests => int.tryParse(guestsController.text.trim()) ?? 0;

  String formatCurrency(double value) => value.toStringAsFixed(2);

  String _formatTime(TimeOfDay? time) {
    if (time == null) {
      return '';
    }
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  void _clearError() {
    if (errorMessage != null) {
      errorMessage = null;
    }
  }

  void _handleAmountChanged() {
    _clearError();
    notifyListeners();
  }

  bool _isPastDate(DateTime value) {
    return _dateOnly(value).isBefore(_today());
  }

  @override
  void dispose() {
    customerNameController.dispose();
    eventTypeController.dispose();
    guestsController.dispose();
    contactPhoneController.dispose();
    contactEmailController.dispose();
    eventLocationController.dispose();
    notesController.dispose();
    totalAmountController.removeListener(_handleAmountChanged);
    paidAmountController.removeListener(_handleAmountChanged);
    totalAmountController.dispose();
    paidAmountController.dispose();
    super.dispose();
  }
}

DateTime _resolveInitialSelectedDate({
  required Booking? initialBooking,
  required DateTime? initialDate,
}) {
  if (initialBooking != null) {
    return _dateOnly(initialBooking.date);
  }

  if (initialDate == null) {
    return _today();
  }

  final DateTime normalized = _dateOnly(initialDate);
  if (normalized.isBefore(_today())) {
    return _today();
  }
  return normalized;
}

DateTime _today() {
  final DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _initialTextAmount(double? value) {
  if (value == null || value <= 0) {
    return '';
  }
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2);
}

double _parseAmount(String value) {
  final String normalized = value.trim().replaceAll(',', '.');
  return double.tryParse(normalized) ?? 0;
}

bool _hasSchedule(Booking? booking) {
  if (booking == null) {
    return false;
  }
  return booking.time.contains('-');
}

TimeOfDay? _readStartTime(String? label) {
  if (label == null || !label.contains('-')) {
    return null;
  }
  return _parseTime(label.split('-').first.trim());
}

TimeOfDay? _readEndTime(String? label) {
  if (label == null || !label.contains('-')) {
    return null;
  }
  return _parseTime(label.split('-').last.trim());
}

TimeOfDay? _parseTime(String value) {
  final List<String> parts = value.split(':');
  if (parts.length < 2) {
    return null;
  }
  final int? hour = int.tryParse(parts[0].trim());
  final int? minute = int.tryParse(parts[1].trim());
  if (hour == null || minute == null) {
    return null;
  }
  return TimeOfDay(hour: hour, minute: minute);
}
