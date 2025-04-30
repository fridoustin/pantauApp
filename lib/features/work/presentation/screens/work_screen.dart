import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/common/widgets/custom_app_bar.dart';
import 'package:pantau_app/common/widgets/layout/app_scaffold.dart';
import 'package:pantau_app/features/work/presentation/providers/work_order_provider.dart';
import 'package:pantau_app/features/work/presentation/widgets/work_order_card.dart';

class WorkScreen extends ConsumerWidget {
  static const String route = '/work';
  const WorkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toDoWorkOrder = ref.watch(toDoWorkOrdersProvider);
    return AppScaffold(
      appBar: const CustomAppBar(title: "Work",),
      currentIndex: 1,
      child: toDoWorkOrder.isEmpty
        ? const Center(child: Text('No Work Orders'))
        : ListView.builder(
            itemCount: toDoWorkOrder.length,
            itemBuilder: (context, index) {
              final workOrder = toDoWorkOrder[index];
              return WorkOrderCard(workOrder: workOrder);
            },
          ),
    );
  }
}