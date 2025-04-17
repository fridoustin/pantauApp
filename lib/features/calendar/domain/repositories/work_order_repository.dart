import 'package:pantau_app/features/calendar/domain/models/work_order.dart';

abstract class WorkOrderRepository {
  Future<List<WorkOrder>> getWorkOrdersByDateRange(DateTime start, DateTime end);
  Future<void> updateWorkOrderStatus(String id, String status);
}