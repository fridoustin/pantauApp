import 'package:pantau_app/features/profile/domain/repositories/work_order_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkOrderRepositoryImpl implements WorkOrderRepository {
  final SupabaseClient client;

  WorkOrderRepositoryImpl(this.client);

  @override
  Future<List<Map<String, dynamic>>> getWorkOrderStatus() async {
    try {
      final response = await client
        .from('workorder')
        .select('status');

      return response;
    } catch (e) {
    return [];
    } 
  }

  // @override
  // Future<int> getCompletedWorkOrderCount() async {
  //   final response = await client
  //       .from('workorder')
  //       .select('status')
  //       .eq('status', 'selesai')
  //       .count(CountOption.exact);

  //   return response.count;
  // }

  // @override
  // Future<int> getNotCompletedWorkOrderCount() async {
  //   final response = await client
  //       .from('workorder')
  //       .select('status')
  //       .neq('status', 'selesai')
  //       .count(CountOption.exact);

  //   return response.count;
  // }
}