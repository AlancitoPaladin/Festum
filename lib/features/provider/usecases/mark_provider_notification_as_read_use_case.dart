import 'package:festum/features/provider/repositories/provider_home_repository.dart';

class MarkProviderNotificationAsReadUseCase {
  const MarkProviderNotificationAsReadUseCase(this._repository);

  final ProviderHomeRepository _repository;

  Future<void> call(String notificationId) {
    return _repository.markAsRead(notificationId);
  }
}
