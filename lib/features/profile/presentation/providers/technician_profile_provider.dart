import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:pantau_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider untuk repository profil
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final supabaseClient = Supabase.instance.client;
  return ProfileRepositoryImpl(supabaseClient);
});

// Provider untuk data profil teknisi
final technicianProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  final email = Supabase.instance.client.auth.currentUser?.email;
  
  if (email == null) return null;
  
  return await repository.getTechnicianProfile(email);
});
