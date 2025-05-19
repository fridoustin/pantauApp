import 'package:pantau_app/features/report/domain/report.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportRepository {
  final SupabaseClient _supabaseClient;
  
  ReportRepository({SupabaseClient? supabaseClient}) 
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<List<Report>> getReportsByWorkOrderId(String workOrderId) async {
    try {
      final List<Map<String, dynamic>> reportData = await _supabaseClient
          .from('workorder')
          .select('''
            id,
            after_url, 
            before_url, 
            note, 
            report_created_at
          ''')
          .eq('id', workOrderId);

      return reportData.map((data) => Report.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load reports: $e');
    }
  }
}