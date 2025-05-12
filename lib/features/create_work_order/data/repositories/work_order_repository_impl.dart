import 'package:pantau_app/features/create_work_order/data/datasources/work_order_remote_data_source.dart';
import 'package:pantau_app/features/create_work_order/data/models/work_order_model.dart';
import 'package:pantau_app/features/create_work_order/domain/entities/work_order.dart';

abstract class WorkOrderRepository {
  Future<void> addWorkOrder(WorkOrder order);
}

class WorkOrderRepositoryImpl implements WorkOrderRepository {
  final WorkOrderRemoteDataSource remote;

  WorkOrderRepositoryImpl(this.remote);

  @override
  Future<void> addWorkOrder(WorkOrder order) async {
    final model = WorkOrderModel(
      title: order.title,
      description: order.description,
      endTime: order.endTime,
      createdAt: order.createdAt,
      status: order.status,
      technicianId: order.technicianId,
      categoryId: order.categoryId,
    );
    await remote.addWorkOrder(model);
  }
}