import 'package:pantau_app/features/create_work_order/data/repositories/work_order_repository_impl.dart';
import 'package:pantau_app/features/create_work_order/domain/entities/work_order.dart';

class AddWorkOrder {
  final WorkOrderRepository repository;

  AddWorkOrder(this.repository);

  Future<void> call(WorkOrder order) async {
    await repository.addWorkOrder(order);
  }
}