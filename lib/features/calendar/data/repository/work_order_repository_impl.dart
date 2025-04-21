import 'package:pantau_app/features/calendar/domain/models/work_order.dart';
import 'package:pantau_app/features/calendar/domain/repositories/work_order_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkOrderRepositoryImpl implements WorkOrderRepository {
  final SupabaseClient _supabaseClient;
  
  WorkOrderRepositoryImpl(this._supabaseClient);
  
  @override
  Future<List<WorkOrder>> getWorkOrdersByDateRange(DateTime start, DateTime end) async {
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();
    
    final response = await _supabaseClient
        .from('workorder')
        .select()
        .or('start_time.is.null,end_time.is.null,and(start_time.lte.$endStr,end_time.gte.$startStr)')
        .order('start_time');

    return response.map<WorkOrder>((json) => WorkOrder.fromJson(json)).toList();
  }
  
  @override
  Future<void> updateWorkOrderStatus(String id, String status) async {
    await _supabaseClient
        .from('workorder')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }
}