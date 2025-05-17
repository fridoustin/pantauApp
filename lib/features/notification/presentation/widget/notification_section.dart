import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/notification/domain/notification.dart' as domain;
import 'package:pantau_app/common/widgets/notification_tile.dart';
import 'package:pantau_app/features/notification/presentation/providers/notification_providers.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationSection extends ConsumerWidget {
  final String sectionTitle;
  final List<domain.Notification> notifications;

  const NotificationSection({
    super.key,
    required this.sectionTitle,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            sectionTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...notifications.map((notif) {
          final relativeTime = timeago.format(notif.createdAt, locale: 'id');

          return NotificationTile(
            title: notif.title,
            message: notif.message,
            timeAgo: relativeTime,
            isUnread: !notif.isRead,
            onTap: () {
              // Mark notification as read when tapped
              ref.read(notificationControllerProvider.notifier).markNotificationAsRead(notif.id);
            },
          );
        }),
      ],
    );
  }
}