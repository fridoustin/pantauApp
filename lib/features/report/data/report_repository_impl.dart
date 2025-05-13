import 'package:pantau_app/features/report/domain/report.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportRepository {
  final SupabaseClient _supabaseClient;
  
  ReportRepository({SupabaseClient? supabaseClient}) 
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<List<Report>> getReportsByWorkOrderId(String workOrderId) async {
    try {
      final List<Map<String, dynamic>> reportData = await _supabaseClient
          .from('report')
          .select('''
            id, 
            before_photo, 
            after_photo, 
            note, 
            created_at,
            wo_id
          ''')
          .eq('wo_id', workOrderId);

      return reportData.map((data) => Report.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load reports: $e');
    }
  }
}