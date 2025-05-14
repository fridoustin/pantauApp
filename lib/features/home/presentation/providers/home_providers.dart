import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/work/domain/models/work_order.dart';
import 'package:pantau_app/features/work/presentation/providers/work_order_provider.dart';

final homeStatisticsProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  final workOrdersAsync = ref.watch(workOrdersProvider);

  return workOrdersAsync.whenData((orders) {
    final now = DateTime.now();
    final todayYear = now.year;
    final todayMonth = now.month;
    final todayDay = now.day;

    final counters = <String, int>{
      'total': 0,
      'today': 0,
      'pending': 0,
      'todayPending': 0,
      'inProgress': 0,
      'todayInProgress': 0,
      'notStarted': 0,
      'todayNotStarted': 0,
      'completed': 0,
      'todayCompleted': 0,
      'basement': 0,
      'todayBasement': 0,
      'GF': 0,
      'todayGF': 0,
      'lt1': 0,
      'todayLt1': 0,
      'lt2': 0,
      'todayLt2': 0,
      'lt3': 0,
      'todayLt3': 0,
      'rooftop': 0,
      'todayRooftop': 0,
      'overdue': 0,
    };
    var totalDurations = 0;
    var todayDurations = 0;

    for (final wo in orders) {
      counters['total'] = counters['total']! + 1;

      if (wo.status != 'selesai' && wo.endTime!= null && wo.endTime!.difference(now).isNegative) counters['overdue'] = counters['overdue']! + 1;

      final isToday = wo.createdAt.year == todayYear &&
          wo.createdAt.month == todayMonth &&
          wo.createdAt.day == todayDay;
      if (isToday) counters['today'] = counters['today']! + 1;
      // Status
      switch (wo.status) {
        case 'terkendala':
          counters['pending'] = counters['pending']! + 1;
          if (isToday) counters['todayPending'] = counters['todayPending']! + 1;
          break;
        case 'dalam_pengerjaan':
          counters['inProgress'] = counters['inProgress']! + 1;
          if (isToday) counters['todayInProgress'] = counters['todayInProgress']! + 1;
          break;
        case 'belum_mulai':
          counters['notStarted'] = counters['notStarted']! + 1;
          if (isToday) counters['todayNotStarted'] = counters['todayNotStarted']! + 1;
          break;
        case 'selesai':
          counters['completed'] = counters['completed']! + 1;
          if (isToday) counters['todayCompleted'] = counters['todayCompleted']! + 1;

          if (wo.updatedAt != null) {
            if (wo.startTime != null) {
              final duration = wo.updatedAt!.difference(wo.startTime!).inHours;
              totalDurations += duration;
              if (isToday) todayDurations += duration;
            } else {
              final duration = wo.updatedAt!.difference(wo.createdAt).inHours;
              totalDurations += duration;
              if (isToday) todayDurations += duration;
            }
          }
          break;
        default:
          break;
      }
      // Category/Floor
      switch (wo.categoryId) {
        case '81e188a8-e7e4-401b-8a16-300d92e53abe':
          counters['basement'] = counters['basement']! + 1;
          if (isToday) counters['todayBasement'] = counters['todayBasement']! + 1;
          break;
        case '3b39fcc9-710c-4dd4-a26a-f5ce854cb038':
          counters['GF'] = counters['GF']! + 1;
          if (isToday) counters['todayGF'] = counters['todayGF']! + 1;
          break;
        case '1f0973f6-f92c-4b65-9cd8-8d82e897d1ae':
          counters['lt1'] = counters['lt1']! + 1;
          if (isToday) counters['todayLt1'] = counters['todayLt1']! + 1;
          break;
        case '156d317c-d94a-4e3d-9cf5-da90681b3a60':
          counters['lt2'] = counters['lt2']! + 1;
          if (isToday) counters['todayLt2'] = counters['todayLt2']! + 1;
          break;
        case 'b3955121-15ec-4b75-acc7-20be78921f66':
          counters['lt3'] = counters['lt3']! + 1;
          if (isToday) counters['todayLt3'] = counters['todayLt3']! + 1;
          break;
        case '45cc0e22-76b3-42a5-b61f-6ffde101624b':
          counters['rooftop'] = counters['rooftop']! + 1;
          if (isToday) counters['todayRooftop'] = counters['todayRooftop']! + 1;
          break;
        default:
          break;
      }
    }

    final avgAll = counters['completed']! > 0
        ? (totalDurations / counters['completed']!).round()
        : 0;
    final avgToday = counters['todayCompleted']! > 0
        ? (todayDurations / counters['todayCompleted']!).round()
        : 0;

    return {
      ...counters,
      'averageCompletionTimeHours': avgAll,
      'todayAverageCompletionTimeHours': avgToday,
    };
  });
});

final todayWorkOrdersProvider = Provider<AsyncValue<List<WorkOrder>>>((ref) {
  final workOrdersAsync = ref.watch(workOrdersProvider);

  return workOrdersAsync.whenData((orders) {
    final now = DateTime.now();
    final recent = orders
        .where((wo) => wo.status != 'selesai' && wo.createdAt.year == now.year && wo.createdAt.month == now.month && wo.createdAt.day == now.day)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return recent.toList();
  });
});

final overdueWorkOrdersProvider = Provider<AsyncValue<List<WorkOrder>>>((ref) {
  final workOrdersAsync = ref.watch(workOrdersProvider);

  return workOrdersAsync.whenData((orders) {
    final now = DateTime.now();
    final recent = orders
        .where((wo) => wo.status != 'selesai' && wo.endTime!= null && wo.endTime!.difference(now).isNegative)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return recent.toList();
  });
});