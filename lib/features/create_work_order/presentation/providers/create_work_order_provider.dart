import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/create_work_order/data/datasources/category_remote_data_source.dart';
import 'package:pantau_app/features/create_work_order/data/datasources/work_order_remote_data_source.dart';
import 'package:pantau_app/features/create_work_order/data/repositories/category_repository_impl.dart';
import 'package:pantau_app/features/create_work_order/data/repositories/work_order_repository_impl.dart';
import 'package:pantau_app/features/create_work_order/domain/entities/category.dart';
import 'package:pantau_app/features/create_work_order/domain/entities/work_order.dart';
import 'package:pantau_app/features/create_work_order/domain/usecases/add_work_order.dart';
import 'package:pantau_app/features/create_work_order/domain/usecases/get_categories.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final workOrderRepoProvider = Provider<WorkOrderRepository>((ref) {
  final client = ref.read(supabaseProvider);
  return WorkOrderRepositoryImpl(WorkOrderRemoteDataSource(client));
});

final addWorkOrderUseCaseProvider = Provider((ref) => AddWorkOrder(ref.read(workOrderRepoProvider)));

final createWorkOrderProvider = StateNotifierProvider<CreateWorkOrderNotifier, AsyncValue<void>>(
  (ref) => CreateWorkOrderNotifier(ref.read(addWorkOrderUseCaseProvider)),
);

final categoryListProvider = FutureProvider<List<Category>>((ref) {
  final client = ref.read(supabaseProvider);
  final ds = CategoryRemoteDataSource(client);
  final repo = CategoryRepositoryImpl(ds);
  return GetCategories(repo)();
});

class CreateWorkOrderNotifier extends StateNotifier<AsyncValue<void>> {
  final AddWorkOrder _addWorkOrder;

  CreateWorkOrderNotifier(this._addWorkOrder) : super(const AsyncData(null));

  Future<void> create({
    required String title,
    required String description,
    DateTime? startTime,
    DateTime? endTime,
    String status = 'belum_mulai',
    String? adminId,
    String? categoryId,
  }) async {
    state = const AsyncLoading();
    try {
      final now = DateTime.now();
      final user = Supabase.instance.client.auth.currentUser;
      final order = WorkOrder(
        id: const Uuid().v4(),
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        createdAt: now,
        updatedAt: null,
        status: status,
        technicianId: user!.id,
        adminId: null,
        categoryId: categoryId,
      );
      await _addWorkOrder(order);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}