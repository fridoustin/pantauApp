import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/work/domain/models/work_order.dart';
import 'package:pantau_app/features/work/presentation/viewmodels/work_order_viewmodel.dart';

class WorkOrderCard extends ConsumerWidget {
  final WorkOrder workOrder;

  const WorkOrderCard({super.key, required this.workOrder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Function to get status color
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'selesai':
          return Colors.green; // //color - selesai status color
        case 'dalam_pengerjaan':
          return Colors.blue; // //color - dalam pengerjaan status color
        case 'terkendala':
          return Colors.red; // //color - terkendala status color
        case 'belum_mulai':
        default:
          return Colors.grey; // //color - belum mulai status color
      }
    }

    // // Function to get category icon
    IconData getCategoryIcon(String? categoryId) {
      switch (categoryId) {
        case '1':
          return Icons.ac_unit;
        case '2':
          return Icons.water_drop;
        default:
          return Icons.handyman;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(getCategoryIcon(workOrder.categoryId)), // Category icon
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    workOrder.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    workOrder.startTime != null
                      ? DateFormat('h:mm a').format(workOrder.startTime!)
                      : '-',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              workOrder.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor(workOrder.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _formatStatus(workOrder.status),
                    style: TextStyle(
                      color: getStatusColor(workOrder.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    // Update status button
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showStatusUpdateDialog(context, ref, workOrder);
                      },
                    ),
                    // Calendar Synch
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () {

                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    return status
        .split('_')
        .map((word) =>
            word.substring(0, 1).toUpperCase() +
            word.substring(1).toLowerCase())
        .join(' ');
  }

  void _showStatusUpdateDialog(BuildContext context, WidgetRef ref, WorkOrder workOrder) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Selesai'),
                onTap: () {
                  ref.read(workOrderViewModelProvider.notifier).updateWorkOrderStatus(workOrder.id, 'selesai');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Dalam Pengerjaan'),
                onTap: () {
                  ref.read(workOrderViewModelProvider.notifier).updateWorkOrderStatus(workOrder.id, 'dalam_pengerjaan');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Terkendala'),
                onTap: () {
                  ref.read(workOrderViewModelProvider.notifier).updateWorkOrderStatus(workOrder.id, 'terkendala');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Belum Mulai'),
                onTap: () {
                  ref.read(workOrderViewModelProvider.notifier).updateWorkOrderStatus(workOrder.id, 'belum_mulai');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}