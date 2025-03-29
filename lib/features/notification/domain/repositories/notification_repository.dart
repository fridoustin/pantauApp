import 'package:pantau_app/features/notification/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(String notificationId);
}