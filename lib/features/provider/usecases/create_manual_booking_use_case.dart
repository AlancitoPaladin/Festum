import 'package:festum/features/provider/models/booking.dart';
import 'package:festum/features/provider/models/manual_booking_request.dart';
import 'package:festum/features/provider/repositories/provider_bookings_repository.dart';

class CreateManualBookingUseCase {
  const CreateManualBookingUseCase(this._repository);

  final ProviderBookingsRepository _repository;

  Future<Booking> call({
    required String productId,
    required ManualBookingRequest request,
  }) {
    return _repository.createManualBooking(
      productId: productId,
      request: request,
    );
  }
}
