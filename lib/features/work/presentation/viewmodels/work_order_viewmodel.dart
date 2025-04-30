import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/work/domain/repositories/work_order_repository.dart';
import 'package:pantau_app/features/work/presentation/providers/work_order_provider.dart';

class WorkOrderViewModel extends StateNotifier<AsyncValue<void>> {
  final WorkOrderRepository _repository;
  final Ref _ref;
  
  WorkOrderViewModel(this._repository, this._ref) : super(const AsyncValue.data(null));
  
  Future<void> updateWorkOrderStatus(String id, String status) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateWorkOrderStatus(id, status);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final workOrderViewModelProvider = StateNotifierProvider<WorkOrderViewModel, AsyncValue<void>>((ref) {
  return WorkOrderViewModel(ref.watch(workOrderRepositoryProvider), ref);
});