import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/work/domain/models/work_order.dart';
import 'package:pantau_app/features/work/presentation/providers/work_order_provider.dart';

// Provider to get a single work order by ID from the existing stream
final workOrderDetailProvider = Provider.family<AsyncValue<WorkOrder>, String>((ref, workOrderId) {
  final workOrdersAsyncValue = ref.watch(workOrdersProvider);

  return workOrdersAsyncValue.when(
    data: (workOrders) {
      final workOrder = workOrders.firstWhere(
        (wo) => wo.id == workOrderId,
        orElse: () => throw Exception('Work order not found: $workOrderId'),
      );
      return AsyncValue.data(workOrder);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});