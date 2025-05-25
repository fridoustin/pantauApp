import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/work/data/admin_repository_impl.dart';
import 'package:pantau_app/features/work/domain/models/admin.dart';
import 'package:pantau_app/features/work/domain/repositories/admin_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final supabase = Supabase.instance.client;
  return AdminRepositoryImpl(supabase);
});

final adminByIdProvider = FutureProvider.family<Admin?, String>((ref, adminId) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getAdminById(adminId);
});