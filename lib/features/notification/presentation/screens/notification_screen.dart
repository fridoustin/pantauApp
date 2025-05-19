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

class _NotificationScreenState extends ConsumerState<NotificationScreen> with WidgetsBindingObserver {
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    // Initialize timeago locale for Indonesian
    timeago.setLocaleMessages('id', timeago.IdMessages());
    
    // Register as observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Hanya refresh pada load pertama atau saat kembali ke screen
    if (_isFirstLoad) {
      _isFirstLoad = false;
      // Delay untuk memastikan widget sudah ter-mount
      Future.microtask(() => _refreshNotifications());
    }
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _refreshNotifications();
    }
  }
  
  @override
  void dispose() {
    // Unregister the observer when the screen is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  void _refreshNotifications() {
    // Only call this if the widget is still mounted
    if (!mounted) return;
    
    // Invalidate the provider to force a refresh
    ref.invalidate(workOrderNotificationsProvider);
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
    return RefreshIndicator(
      onRefresh: () async {
        // Pull-to-refresh functionality
        _refreshNotifications();
      },
      child: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (notifications) {
          if (notifications.isEmpty) {
            // Return a scrollable container for empty state so pull-to-refresh works
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 150),
                Center(child: Text('No notifications')),
              ],
            );
          }

          final sortedNotifications = List<domain.Notification>.from(notifications)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          final grouped = _groupNotifications(sortedNotifications);

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
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
      ),
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