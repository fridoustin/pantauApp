import 'package:pantau_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthDataSource implements AuthDataSource {
  final SupabaseClient client;

  SupabaseAuthDataSource({required this.client});

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Login failed');
      }

      // Cek role
      final userRole = response.user?.userMetadata?['role'];
      if (userRole != 'technician') {
        await client.auth.signOut();
        throw Exception('Access denied. Only Technician can login');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}