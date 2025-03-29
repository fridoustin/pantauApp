import 'package:pantau_app/features/notification/domain/repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository repository;

  MarkNotificationReadUseCase(this.repository);

  Future<void> call(String notificationId) async {
    return repository.markAsRead(notificationId);
  }
}