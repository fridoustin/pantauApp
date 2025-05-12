import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/work/domain/repositories/work_order_repository.dart';
import 'package:pantau_app/features/work/presentation/providers/work_order_provider.dart';

class WorkOrderEditViewModel extends StateNotifier<AsyncValue<void>> {
  final WorkOrderRepository _repository;
  
  WorkOrderEditViewModel(this._repository) : super(const AsyncValue.data(null));
  
  Future<bool> updateWorkOrder(
    String id, 
    Map<String, dynamic> data,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateWorkOrder(id, data);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final workOrderEditViewModelProvider = StateNotifierProvider<WorkOrderEditViewModel, AsyncValue<void>>((ref) {
  return WorkOrderEditViewModel(ref.watch(workOrderRepositoryProvider));
});