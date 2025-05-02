import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/calendar/domain/models/work_order.dart';
import 'package:pantau_app/features/calendar/domain/repositories/work_order_repository.dart';
import 'package:pantau_app/features/calendar/presentation/providers/calendar_provider.dart';

class CalendarViewModel extends StateNotifier<AsyncValue<void>> {
  final WorkOrderRepository _repository;
  final Ref _ref;
  
  CalendarViewModel(this._repository, this._ref) : super(const AsyncValue.data(null));
  
  void selectDate(DateTime date) {
    _ref.read(selectedDateProvider.notifier).state = date;
  }
  
  Future<void> updateWorkOrderStatus(String id, String status) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateWorkOrderStatus(id, status);
      state = const AsyncValue.data(null);
      
      // Refresh the work orders list
      _ref.invalidate(monthWorkOrdersProvider(
        _ref.read(selectedDateProvider).copyWith(day: 1))
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> syncWithDeviceCalendar(WorkOrder workOrder, String calendarId) async {
    state = const AsyncValue.loading();
    try {
      final deviceCalendarPlugin = _ref.read(deviceCalendarProvider);
      
      // // Create proper TZDateTime objects
      // final start = TZDateTime.from(workOrder.startTime, local);
      // final end = TZDateTime.from(workOrder.endTime, local);
      
      final event = Event(
        calendarId,
        title: workOrder.title,
        description: workOrder.description,
        // start: start,
        // end: end,
      );
      
      await deviceCalendarPlugin.createOrUpdateEvent(event);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Add the missing TZDateTime and local definitions
class TZDateTime extends DateTime {
  final String timeZoneId;
  
  TZDateTime(
    this.timeZoneId,
    int year, [
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
  ]) : super(year, month, day, hour, minute, second, millisecond, microsecond);
  
  static TZDateTime from(DateTime dateTime, Location location) {
    final tz = TZDateTime(
      location.name,
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
      dateTime.millisecond,
      dateTime.microsecond,
    );
    return tz;
  }
}

class Location {
  final String name;
  
  const Location({required this.name});
}

const local = Location(name: 'local');

final calendarViewModelProvider = StateNotifierProvider<CalendarViewModel, AsyncValue<void>>((ref) {
  return CalendarViewModel(ref.watch(workOrderRepositoryProvider), ref);
});