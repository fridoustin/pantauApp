import 'package:pantau_app/features/work/domain/models/admin.dart';
import 'package:pantau_app/features/work/domain/repositories/admin_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRepositoryImpl implements AdminRepository {
  final SupabaseClient _supabaseClient;
  
  AdminRepositoryImpl(this._supabaseClient);

  @override
  Future<Admin?> getAdminById(String id) async {
    try {
      final response = await _supabaseClient
          .from('admin')
          .select('admin_id, name, email')
          .eq('admin_id', id)
          .single();
      
      return Admin.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}