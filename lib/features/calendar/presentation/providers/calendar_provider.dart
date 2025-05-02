import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:pantau_app/features/calendar/data/repository/work_order_repository_impl.dart';
import 'package:pantau_app/features/calendar/domain/models/work_order.dart';
import 'package:pantau_app/features/calendar/domain/repositories/work_order_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final workOrderRepositoryProvider = Provider<WorkOrderRepository>((ref) {
  final supabase = Supabase.instance.client;
  return WorkOrderRepositoryImpl(supabase);
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final monthWorkOrdersProvider = FutureProvider.family<List<WorkOrder>, DateTime>((ref, month) {
  final repository = ref.watch(workOrderRepositoryProvider);
  final firstDay = DateTime(month.year, month.month, 1);
  final lastDay = DateTime(month.year, month.month + 1, 0);
  
  return repository.getWorkOrdersByDateRange(firstDay, lastDay);
});

final selectedDayWorkOrdersProvider = Provider<List<WorkOrder>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final monthWorkOrdersAsync = ref.watch(monthWorkOrdersProvider(DateTime(selectedDate.year, selectedDate.month)));
  
  return monthWorkOrdersAsync.when(
    data: (workOrders) {
      return workOrders.where((workOrder) {
        return workOrder.startTime.year == selectedDate.year &&
                workOrder.startTime.month == selectedDate.month &&
                workOrder.startTime.day == selectedDate.day;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final deviceCalendarProvider = Provider<DeviceCalendarPlugin>((ref) {
  return DeviceCalendarPlugin();
});

final calendarPermissionProvider = FutureProvider<bool>((ref) async {
  final deviceCalendarPlugin = ref.watch(deviceCalendarProvider);
  var permissionsGranted = await deviceCalendarPlugin.hasPermissions();
  if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
    permissionsGranted = await deviceCalendarPlugin.requestPermissions();
  }
  return permissionsGranted.isSuccess && permissionsGranted.data!;
});

final deviceCalendarsProvider = FutureProvider<List<Calendar>>((ref) async {
  final hasPermission = await ref.watch(calendarPermissionProvider.future);
  if (!hasPermission) return [];
  
  final deviceCalendarPlugin = ref.watch(deviceCalendarProvider);
  final calendarsResult = await deviceCalendarPlugin.retrieveCalendars();
  return calendarsResult.isSuccess ? calendarsResult.data ?? [] : [];
});