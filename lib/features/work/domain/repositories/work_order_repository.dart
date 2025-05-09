import 'package:pantau_app/features/work/domain/models/work_order.dart';

abstract class WorkOrderRepository {
  Stream<List<WorkOrder>> watchWorkOrders();
  Future<void> updateWorkOrderStatus(String id, String status);
}