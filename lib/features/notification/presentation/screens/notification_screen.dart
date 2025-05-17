import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/notification/domain/notification.dart' as domain;
import 'package:pantau_app/features/notification/presentation/providers/notification_providers.dart';
import 'package:pantau_app/features/notification/presentation/widget/notification_section.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends ConsumerStatefulWidget {
  static const String route = '/notification';
  
  const NotificationScreen({
    super.key,
  });

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize timeago locale for Indonesian
    timeago.setLocaleMessages('id', timeago.IdMessages());
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(workOrderNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: _buildBody(notificationsAsync),
    );
  }

  Widget _buildBody(AsyncValue<List<domain.Notification>> notificationsAsync) {
    return notificationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (notifications) {
        if (notifications.isEmpty) {
          return const Center(child: Text('No notifications'));
        }

        final sortedNotifications = List<domain.Notification>.from(notifications)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
      },
    );
  }

  Map<String, List<domain.Notification>> _groupNotifications(
      List<domain.Notification> notifications) {
    final today = <domain.Notification>[];
    final yesterday = <domain.Notification>[];
    final thisWeek = <domain.Notification>[];
    final older = <domain.Notification>[];

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