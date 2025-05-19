import 'package:pantau_app/features/notification/domain/notification.dart' as domain;
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRepository {
  final SupabaseClient _supabaseClient;
  
  NotificationRepository({SupabaseClient? supabaseClient}) 
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<List<domain.Notification>> getNotifications() async {
    try {
      final List<Map<String, dynamic>> notificationData = await _supabaseClient
          .from('notification')
          .select('''
            id,
            title, 
            message,
            created_at, 
            is_read, 
            wo_id
          ''');

      return notificationData.map((data) => domain.Notification.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load notification: $e');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabaseClient
          .from('notification')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabaseClient
          .from('notification')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }
}