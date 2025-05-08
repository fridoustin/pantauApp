abstract class WorkOrderRepository {
  Future<List<Map<String, dynamic>>> getWorkOrderStatus();
  // Future<int> getCompletedWorkOrderCount();
  // Future<int> getNotCompletedWorkOrderCount();
}