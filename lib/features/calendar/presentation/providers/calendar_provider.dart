import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/work/data/work_order_repository_impl.dart';
import 'package:pantau_app/features/work/domain/models/work_order.dart';
import 'package:pantau_app/features/work/domain/repositories/work_order_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final workOrderRepositoryProvider = Provider<WorkOrderRepository>((ref) {
  final supabase = Supabase.instance.client;
  return WorkOrderRepositoryImpl(supabase);
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final monthWorkOrdersProvider = StreamProvider.autoDispose.family<List<WorkOrder>, DateTime>((ref, month) {
  final repository = ref.watch(workOrderRepositoryProvider);
  
  return repository.watchWorkOrders();
});

final selectedDayWorkOrdersProvider = Provider<List<WorkOrder>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final monthWorkOrdersAsync = ref.watch(monthWorkOrdersProvider(DateTime(selectedDate.year, selectedDate.month)));
  
  return monthWorkOrdersAsync.when(
    data: (workOrders) {
      return workOrders.where((workOrder) {
        final dateToCheck = workOrder.createdAt;
        return dateToCheck.year == selectedDate.year &&
               dateToCheck.month == selectedDate.month &&
               dateToCheck.day == selectedDate.day;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});