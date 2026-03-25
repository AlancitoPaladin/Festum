import 'package:festum/features/provider/models/provider_notifications_response.dart';
import 'package:festum/features/provider/repositories/provider_home_repository.dart';

class GetProviderNotificationsUseCase {
  const GetProviderNotificationsUseCase(this._repository);

  final ProviderHomeRepository _repository;

  Future<ProviderNotificationsResponse> call() {
    return _repository.fetchNotifications();
  }
}
