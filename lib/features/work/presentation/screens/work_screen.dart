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
    final workOrderAsync = ref.watch(workOrdersProvider);
    return AppScaffold(
      appBar: const CustomAppBar(title: "Work",),
      currentIndex: 1,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Work Orders"),
                  const SizedBox(height: 16,),
                  Expanded(
                    child: workOrderAsync.when(
                      data: (workOrders) {
                        if (workOrders.isEmpty) {
                          return const Center(child: Text("No"),);
                        }
                        return ListView.builder(
                          itemCount: workOrders.length,
                          itemBuilder: (context, index) {
                            final workOrder = workOrders[index];
                            return WorkOrderCard(workOrder: workOrder);
                          }
                        );
                      }, 
                      error: (e, _) => const Center(child: Text("Error"),), 
                      loading: () => const Center(child: CircularProgressIndicator(),),
                    ),
                  )
                ],
              ),
            )
          )
        ],
      )
    );
  }
}