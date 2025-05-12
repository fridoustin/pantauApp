import 'package:pantau_app/features/work/domain/models/work_order.dart';

abstract class WorkOrderRepository {
  Stream<List<WorkOrder>> watchWorkOrders();
  Future<void> updateWorkOrderStatus(String id, String status);
  Future<void> updateWorkOrder(String id, Map<String, dynamic> data);
  Future<void> updateStartTime(String id);
}