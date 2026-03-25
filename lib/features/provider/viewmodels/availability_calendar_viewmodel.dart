import 'dart:async';

import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/features/provider/models/booking.dart';
import 'package:festum/features/provider/models/provider_product_availability.dart';
import 'package:festum/features/provider/repositories/provider_availability_repository.dart';
import 'package:festum/features/provider/usecases/block_provider_product_date_use_case.dart';
import 'package:festum/features/provider/usecases/get_provider_product_availability_use_case.dart';
import 'package:festum/features/provider/usecases/unblock_provider_product_date_use_case.dart';
import 'package:stacked/stacked.dart';

enum DayStatus { available, reserved, blocked }

class AvailabilityCalendarViewModel extends BaseViewModel {
  AvailabilityCalendarViewModel({
    required this.productId,
    required this.productName,
    GetProviderProductAvailabilityUseCase? getProviderProductAvailabilityUseCase,
    BlockProviderProductDateUseCase? blockProviderProductDateUseCase,
    UnblockProviderProductDateUseCase? unblockProviderProductDateUseCase,
    ProviderReactivityService? providerReactivityService,
  }) : _getProviderProductAvailabilityUseCase =
           getProviderProductAvailabilityUseCase ??
           locator<GetProviderProductAvailabilityUseCase>(),
       _blockProviderProductDateUseCase =
           blockProviderProductDateUseCase ??
           locator<BlockProviderProductDateUseCase>(),
       _unblockProviderProductDateUseCase =
           unblockProviderProductDateUseCase ??
           locator<UnblockProviderProductDateUseCase>(),
       _providerReactivityService =
           providerReactivityService ?? locator<ProviderReactivityService>() {
    _lastProductsRevision = _providerReactivityService.productsRevision;
    _providerReactivityService.addListener(_handleReactivityChanged);
    unawaited(initialise());
  }

  final String productId;
  final String productName;
  final GetProviderProductAvailabilityUseCase _getProviderProductAvailabilityUseCase;
  final BlockProviderProductDateUseCase _blockProviderProductDateUseCase;
  final UnblockProviderProductDateUseCase _unblockProviderProductDateUseCase;
  final ProviderReactivityService _providerReactivityService;

  DateTime _focusedDay = DateTime.now();
  String? _errorMessage;
  bool _hasInitialized = false;
  int _lastProductsRevision = 0;

  final Map<DateTime, DayStatus> _calendarData = <DateTime, DayStatus>{};
  final Map<DateTime, Booking> _bookings = <DateTime, Booking>{};

  DateTime get focusedDay => _focusedDay;
  String? get errorMessage => _errorMessage;

  Future<void> initialise() async {
    await _loadMonth(_focusedDay);
  }

  DayStatus getStatus(DateTime date) {
    final DateTime cleanDate = _normalizeDate(date);
    return _calendarData[cleanDate] ?? DayStatus.available;
  }

  Booking? getBooking(DateTime date) {
    final DateTime cleanDate = _normalizeDate(date);
    return _bookings[cleanDate];
  }

  void nextMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    notifyListeners();
    unawaited(_loadMonth(_focusedDay));
  }

  void previousMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    notifyListeners();
    unawaited(_loadMonth(_focusedDay));
  }

  Future<void> blockDate(DateTime date) async {
    final DateTime cleanDate = _normalizeDate(date);
    if (getStatus(cleanDate) == DayStatus.reserved) {
      return;
    }

    try {
      await _blockProviderProductDateUseCase(productId: productId, date: cleanDate);
      _calendarData[cleanDate] = DayStatus.blocked;
      _bookings.remove(cleanDate);
      await _providerReactivityService.notifyProductsChanged();
      notifyListeners();
    } catch (error) {
      _errorMessage = ProviderAvailabilityRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo bloquear la fecha.',
      );
      notifyListeners();
    }
  }

  Future<void> unblockDate(DateTime date) async {
    final DateTime cleanDate = _normalizeDate(date);
    if (getStatus(cleanDate) != DayStatus.blocked) {
      return;
    }

    try {
      await _unblockProviderProductDateUseCase(
        productId: productId,
        date: cleanDate,
      );
      _calendarData.remove(cleanDate);
      _bookings.remove(cleanDate);
      await _providerReactivityService.notifyProductsChanged();
      notifyListeners();
    } catch (error) {
      _errorMessage = ProviderAvailabilityRepository.mapApiError(
        error,
        fallbackMessage: 'No se pudo desbloquear la fecha.',
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _providerReactivityService.removeListener(_handleReactivityChanged);
    super.dispose();
  }

  Future<void> _loadMonth(DateTime month) async {
    setBusy(true);
    _errorMessage = null;
    try {
      final ProviderProductAvailabilityMonthResponse response =
          await _getProviderProductAvailabilityUseCase(
            productId: productId,
            year: month.year,
            month: month.month,
          );
      _calendarData.clear();
      _bookings.clear();

      for (final ProviderAvailabilityDay day in response.days) {
        final DateTime cleanDate = _normalizeDate(day.date);
        _calendarData[cleanDate] = _mapStatus(day.status);
        if (day.booking != null) {
          _bookings[cleanDate] = day.booking!;
        }
      }

      _focusedDay = DateTime(response.year, response.month, 1);
      _lastProductsRevision = _providerReactivityService.productsRevision;
      _hasInitialized = true;
    } catch (error) {
      _errorMessage = ProviderAvailabilityRepository.mapApiError(error);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void _handleReactivityChanged() {
    if (!_hasInitialized || isBusy) {
      return;
    }

    final bool productsChanged =
        _lastProductsRevision != _providerReactivityService.productsRevision;
    if (!productsChanged) {
      return;
    }

    _lastProductsRevision = _providerReactivityService.productsRevision;
    unawaited(_loadMonth(_focusedDay));
  }

  DayStatus _mapStatus(ProductAvailabilityStatus status) {
    switch (status) {
      case ProductAvailabilityStatus.reserved:
        return DayStatus.reserved;
      case ProductAvailabilityStatus.blocked:
        return DayStatus.blocked;
      case ProductAvailabilityStatus.available:
        return DayStatus.available;
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
