import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/profile/data/repositories/work_order_repository_impl.dart';
import 'package:pantau_app/features/profile/domain/repositories/work_order_repository.dart';
import 'package:pantau_app/features/profile/domain/usecases/get_work_order_counts_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider untuk repository work order
final workOrderRepositoryProvider = Provider<WorkOrderRepository>((ref) {
  final supabaseClient = Supabase.instance.client;
  return WorkOrderRepositoryImpl(supabaseClient);
});

// Provider untuk use case
final getWorkOrderCountsUseCaseProvider = Provider<GetWorkOrderCountsUseCase>((ref) {
  final repository = ref.watch(workOrderRepositoryProvider);
  return GetWorkOrderCountsUseCase(repository);
});

// Provider untuk data jumlah work order
final workOrderCountsProvider = FutureProvider.autoDispose<WorkOrderCounts>((ref) async {
  final useCase = ref.watch(getWorkOrderCountsUseCaseProvider);
  return await useCase.execute();
});