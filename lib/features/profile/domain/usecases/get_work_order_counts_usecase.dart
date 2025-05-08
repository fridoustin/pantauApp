import 'package:pantau_app/features/profile/domain/repositories/work_order_repository.dart';

class GetWorkOrderCountsUseCase {
  final WorkOrderRepository repository;

  GetWorkOrderCountsUseCase(this.repository);

  Future<WorkOrderCounts> execute() async {
    // final completedCount = await repository.getCompletedWorkOrderCount();
    // final pendingCount = await repository.getNotCompletedWorkOrderCount();
    final workOrderStatusList = await repository.getWorkOrderStatus();

    final int completedCount = workOrderStatusList.where((item) => item['status'] == 'selesai').length;
    final int notCompletedCount = workOrderStatusList.where((item) => item['status'] != 'selesai').length;
    
    return WorkOrderCounts(
      completed: completedCount,
      notCompleted: notCompletedCount,
    );
  }
}

class WorkOrderCounts {
  final int completed;
  final int notCompleted;

  WorkOrderCounts({
    required this.completed,
    required this.notCompleted,
  });
}