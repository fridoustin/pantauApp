import 'package:pantau_app/features/notification/domain/entities/notification_entity.dart';
import 'package:pantau_app/features/notification/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<NotificationEntity>> call() async {
    return repository.getNotifications();
  }
}