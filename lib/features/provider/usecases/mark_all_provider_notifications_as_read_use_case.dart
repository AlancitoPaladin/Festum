import 'package:festum/features/provider/repositories/provider_home_repository.dart';

class MarkAllProviderNotificationsAsReadUseCase {
  const MarkAllProviderNotificationsAsReadUseCase(this._repository);

  final ProviderHomeRepository _repository;

  Future<void> call() {
    return _repository.markAllAsRead();
  }
}
