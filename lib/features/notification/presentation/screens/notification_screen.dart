import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/common/widgets/notification_tile.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/notification/domain/entities/notification_entity.dart';
import 'package:pantau_app/features/notification/presentation/providers/notification_providers.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Using ConsumerStatefulWidget to perform initial data fetch in initState
class NotificationScreen extends ConsumerStatefulWidget {
  static const String route = '/notification';
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications only once when the screen is initialized.
    Future.microtask(() {
      ref.read(notificationNotifierProvider.notifier).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: _buildBody(notificationState),
    );
  }

  Widget _buildBody(notificationState) {
    if (notificationState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (notificationState.errorMessage != null) {
      return Center(child: Text('Error: ${notificationState.errorMessage}'));
    }
    final notifications = notificationState.notifications;
    if (notifications.isEmpty) {
      return const Center(child: Text('No notifications'));
    }

    // Create a copy and sort notifications by createdAt (newest first)
    final sortedNotifications = List<NotificationEntity>.from(notifications)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Group notifications based on their createdAt date.
    final grouped = _groupNotifications(sortedNotifications);

    return ListView(
      children: [
        if (grouped['Today']!.isNotEmpty)
          NotificationSection(
            sectionTitle: 'Today',
            notifications: grouped['Today']!,
          ),
        if (grouped['Yesterday']!.isNotEmpty)
          NotificationSection(
            sectionTitle: 'Yesterday',
            notifications: grouped['Yesterday']!,
          ),
        if (grouped['This Week']!.isNotEmpty)
          NotificationSection(
            sectionTitle: 'This Week',
            notifications: grouped['This Week']!,
          ),
        if (grouped['Older']!.isNotEmpty)
          NotificationSection(
            sectionTitle: 'Older',
            notifications: grouped['Older']!,
          ),
      ],
    );
  }

  /// Group notifications based on the date they were created.
  Map<String, List<NotificationEntity>> _groupNotifications(
      List<NotificationEntity> notifications) {
    final today = <NotificationEntity>[];
    final yesterday = <NotificationEntity>[];
    final thisWeek = <NotificationEntity>[];
    final older = <NotificationEntity>[];

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfYesterday = startOfToday.subtract(const Duration(days: 1));
    final startOfThisWeek = startOfToday.subtract(const Duration(days: 7));

    for (var notif in notifications) {
      final created = notif.createdAt;
      if (created.isAfter(startOfToday)) {
        today.add(notif);
      } else if (created.isAfter(startOfYesterday)) {
        yesterday.add(notif);
      } else if (created.isAfter(startOfThisWeek)) {
        thisWeek.add(notif);
      } else {
        older.add(notif);
      }
    }

    return {
      'Today': today,
      'Yesterday': yesterday,
      'This Week': thisWeek,
      'Older': older,
    };
  }
}

class NotificationSection extends ConsumerWidget {
  final String sectionTitle;
  final List<NotificationEntity> notifications;

  const NotificationSection({
    super.key,
    required this.sectionTitle,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Using ref.read because we only need to trigger an action without rebuild.
    final notifier = ref.read(notificationNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            sectionTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // List notifications within this section.
        ...notifications.map((notif) {
          // Format the createdAt date to relative time string.
          final relativeTime = timeago.format(notif.createdAt, locale: 'id');

          return NotificationTile(
            title: notif.title,
            message: notif.message,
            timeAgo: relativeTime,
            isUnread: !notif.isRead,
            // On tap, mark the notification as read
            onTap: () {
              notifier.markAsRead(notif.id);
            },
          );
        }),
      ],
    );
  }
}
