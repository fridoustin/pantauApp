import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/common/widgets/custom_app_bar.dart';
import 'package:pantau_app/common/widgets/layout/app_scaffold.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/work/presentation/providers/work_order_provider.dart';
import 'package:pantau_app/features/work/presentation/widgets/work_order_card.dart';

class WorkScreen extends ConsumerWidget {
  static const String route = '/work';
  const WorkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(workModeProvider);
    final asyncWorkOrders = mode == WorkMode.todo
        ? ref.watch(toDoWorkOrdersProvider)
        : ref.watch(historyWorkOrdersProvider);
    
    return AppScaffold(
      appBar: const CustomAppBar(title: "Work",),
      currentIndex: 1,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/createworkorder'),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
      child: Column(
        children: [
          // Dua tombol To Do & History
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tombol To Do
                ElevatedButton(
                  onPressed: () {
                    ref.read(workModeProvider.notifier).state = WorkMode.todo;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mode == WorkMode.todo
                        ? AppColors.primaryColor
                        : null,
                  ),
                  child: const Text(
                    "To Do",
                    style: TextStyle(
                      color: AppColors.black
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Tombol History
                ElevatedButton(
                  onPressed: () {
                    ref.read(workModeProvider.notifier).state = WorkMode.history;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mode == WorkMode.history
                        ? AppColors.primaryColor
                        : null,
                  ),
                  child: const Text(
                    "History",
                    style: TextStyle(
                      color: AppColors.black
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: asyncWorkOrders.when(
              data: (workOrderList) => workOrderList.isEmpty
                  ? const Center(child: Text("No Work Orders"))
                  : ListView.builder(
                      itemCount: workOrderList.length,
                      itemBuilder: (context, index) {
                        final workOrder = workOrderList[index];
                        return WorkOrderCard(workOrder: workOrder);
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}