import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/notification/data/notification_repository_impl.dart';
import 'package:pantau_app/features/notification/domain/notification.dart' as domain;

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

// Provider to get notifications for a technician
final workOrderNotificationsProvider = FutureProvider<List<domain.Notification>>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotifications();
});

// Controller for notification state and actions
class NotificationController extends StateNotifier<AsyncValue<List<domain.Notification>>> {
  final NotificationRepository _repository;
  final Ref _ref;
  
  NotificationController({
    required NotificationRepository repository,
    required Ref ref,
  }) : _repository = repository,
       _ref = ref,
       super(const AsyncValue.loading()) {
    // Load notifications on creation
    loadNotifications();
  }
  
  Future<void> loadNotifications() async {
    try {
      state = const AsyncValue.loading();
      final notifications = await _repository.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  // Method to mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      // Update notification as read in database
      await _repository.markNotificationAsRead(notificationId);
      
      // Update local state
      state.whenData((notifications) {
        final updatedList = notifications.map((notification) {
          if (notification.id == notificationId) {
            // Create a new notification object with isRead set to true
            return domain.Notification(
              id: notification.id,
              title: notification.title,
              message: notification.message,
              createdAt: notification.createdAt,
              isRead: true,
              workOrderId: notification.workOrderId,
            );
          }
          return notification;
        }).toList();
        
        state = AsyncValue.data(updatedList);
      });
      
      // Refresh the provider
      // This will cause UI to update
      _ref.invalidate(workOrderNotificationsProvider);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
  
  // Method to delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      // Delete notification from database
      await _repository.deleteNotification(notificationId);
      
      // Update local state
      state.whenData((notifications) {
        final updatedList = notifications.where(
          (notification) => notification.id != notificationId
        ).toList();
        
        state = AsyncValue.data(updatedList);
      });
      
      // Refresh the provider
      // This will cause UI to update
      _ref.invalidate(workOrderNotificationsProvider);
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
}

// Provider for the notification controller
final notificationControllerProvider = StateNotifierProvider<NotificationController, AsyncValue<List<domain.Notification>>>(
  (ref) {
    final repository = ref.watch(notificationRepositoryProvider);
    return NotificationController(
      repository: repository, 
      ref: ref,
    );
  }
);