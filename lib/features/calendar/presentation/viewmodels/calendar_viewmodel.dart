import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/calendar/presentation/providers/calendar_provider.dart';
import 'package:pantau_app/features/work/domain/repositories/work_order_repository.dart';

class CalendarViewModel extends StateNotifier<AsyncValue<void>> {
  final WorkOrderRepository _repository;
  final Ref _ref;
  
  CalendarViewModel(this._repository, this._ref) : super(const AsyncValue.data(null));
  
  void selectDate(DateTime date) {
    _ref.read(selectedDateProvider.notifier).state = date;
  }
  
  Future<void> updateWorkOrderStatus(String id, String status) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateWorkOrderStatus(id, status);
      state = const AsyncValue.data(null); // Hapus invalidate
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final calendarViewModelProvider = StateNotifierProvider<CalendarViewModel, AsyncValue<void>>((ref) {
  return CalendarViewModel(ref.watch(workOrderRepositoryProvider), ref);
});