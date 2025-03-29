import 'package:pantau_app/features/notification/data/datasources/dummy_data_source.dart';
import 'package:pantau_app/features/notification/domain/entities/notification_entity.dart';
import 'package:pantau_app/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final DummyDataSource remoteDataSource;
  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    return remoteDataSource.getNotifications();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    return remoteDataSource.markAsRead(notificationId);
  }
}