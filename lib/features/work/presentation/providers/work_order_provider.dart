import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/work/data/work_order_repository_impl.dart';
import 'package:pantau_app/features/work/domain/models/work_order.dart';
import 'package:pantau_app/features/work/domain/repositories/work_order_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final workOrderRepositoryProvider = Provider<WorkOrderRepository>((ref) {
  final supabase = Supabase.instance.client;
  return WorkOrderRepositoryImpl(supabase);
});

final workOrdersProvider = StreamProvider.autoDispose<List<WorkOrder>>((ref) {
  final repository = ref.watch(workOrderRepositoryProvider);
  
  return repository.watchWorkOrders();
});