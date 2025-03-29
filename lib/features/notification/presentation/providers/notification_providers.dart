import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/notification/data/datasources/dummy_data_source.dart';
import 'package:pantau_app/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:pantau_app/features/notification/domain/entities/notification_entity.dart';
import 'package:pantau_app/features/notification/domain/usecases/get_notification_usecase.dart';
import 'package:pantau_app/features/notification/domain/usecases/mark_notification_usecase.dart';

// Provider untuk DummyDataSource
final dummyDataSourceProvider =
    Provider<DummyDataSource>((ref) => DummyDataSource());

// Provider untuk NotificationRepositoryImpl
final notificationRepositoryProvider =
    Provider<NotificationRepositoryImpl>((ref) {
  final dummyRemote = ref.watch(dummyDataSourceProvider);
  return NotificationRepositoryImpl(dummyRemote);
});

// Provider untuk use case GetNotifications
final getNotificationsUseCaseProvider =
    Provider<GetNotificationsUseCase>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return GetNotificationsUseCase(repo);
});

// Provider untuk use case MarkNotificationRead
final markNotificationReadUseCaseProvider =
    Provider<MarkNotificationReadUseCase>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return MarkNotificationReadUseCase(repo);
});

// Provider untuk NotificationNotifier
final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final getNotifications = ref.watch(getNotificationsUseCaseProvider);
  final markRead = ref.watch(markNotificationReadUseCaseProvider);
  return NotificationNotifier(
    getNotificationsUseCase: getNotifications,
    markNotificationReadUseCase: markRead,
  );
});


// Notifiction State
class NotificationState {
  final bool isLoading;
  final List<NotificationEntity> notifications;
  final String? errorMessage;

  const NotificationState({
    this.isLoading = false,
    this.notifications = const [],
    this.errorMessage,
  });

  NotificationState copyWith({
    bool? isLoading,
    List<NotificationEntity>? notifications,
    String? errorMessage,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
    );
  }
}


// Notification Notifier
class NotificationNotifier extends StateNotifier<NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;

  NotificationNotifier({
    required this.getNotificationsUseCase,
    required this.markNotificationReadUseCase,
  }) : super(const NotificationState());

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final notifications = await getNotificationsUseCase();
      state = state.copyWith(isLoading: false, notifications: notifications);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await markNotificationReadUseCase(id);
      final updated = state.notifications.map((notif) {
        if (notif.id == id) {
          return NotificationEntity(
            id: notif.id,
            title: notif.title,
            message: notif.message,
            createdAt: notif.createdAt,
            isRead: true,
          );
        }
        return notif;
      }).toList();
      state = state.copyWith(notifications: updated);
    } catch (e) {
      // Tangani error jika perlu
    }
  }
}