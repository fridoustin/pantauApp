import 'package:pantau_app/features/create_work_order/data/models/work_order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkOrderRemoteDataSource {
  final SupabaseClient client;

  WorkOrderRemoteDataSource(this.client);

  Future<void> addWorkOrder(WorkOrderModel model) async {
    final result = await client
      .from('workorder')
      .insert(model.toJson())
      .select()
      .single();

    if (result == null) {
      throw Exception('Failed');
    }
  }
}