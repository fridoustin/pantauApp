import 'package:pantau_app/features/work/domain/models/work_order.dart';
import 'package:pantau_app/features/work/domain/repositories/work_order_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkOrderRepositoryImpl implements WorkOrderRepository {
  final SupabaseClient _supabaseClient;
  
  WorkOrderRepositoryImpl(this._supabaseClient);

  @override
  Stream<List<WorkOrder>> watchWorkOrders() {
    return _supabaseClient
        .from('workorder')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((events) => events
            .map<WorkOrder>((json) => WorkOrder.fromJson(json))
            .toList());
  }
  
  @override
  Future<void> updateWorkOrderStatus(String id, String status) async {
    await _supabaseClient
        .from('workorder')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  @override
  Future<void> updateStartTime(String id) async {
    await _supabaseClient
        .from('workorder')
        .update({'start_time': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  @override
  Future<void> updateWorkOrder(String id, Map<String, dynamic> data) async {
    data['updated_at'] = DateTime.now().toIso8601String();
    
    await _supabaseClient
        .from('workorder')
        .update(data)
        .eq('id', id);
  }
}