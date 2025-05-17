import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/core/constant/colors.dart';
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
          return AppColors.successColor; // //color - selesai status color
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

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context, 
          '/workorder/detail',
          arguments: workOrder.id,
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: AppColors.cardColor,
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
                      color: getStatusColor(workOrder.status).withValues(alpha: 0.2),
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
                    ],
                  ),
                ],
              ),
            ],
          ),
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

  void _showConfirmDialog(BuildContext context, WidgetRef ref, String workOrderStatus) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        title: const Text('Confirm Status Change'),
        content: const Text(
          "Are you sure you want to revert this work order from “Selesai”?",
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), 
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(workOrderViewModelProvider.notifier).updateWorkOrderStatus(workOrder.id, workOrderStatus);
              if (workOrder.startTime == null && workOrderStatus == 'dalam_pengerjaan') {
                ref.read(workOrderViewModelProvider.notifier).updateStartTime(workOrder.id);
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Yes, Revert'),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, WidgetRef ref, WorkOrder workOrder) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Status'),
          backgroundColor: AppColors.cardColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Selesai'),
                onTap: () {
                  Navigator.pop(context);
                  if (workOrder.status != 'selesai') {
                    Navigator.pushNamed(
                      context, 
                      '/workorder/report',
                      arguments: workOrder.id,
                    );
                  } else if (workOrder.status != 'selesai' && workOrder.afterPhoto == null) {
                    ref.read(workOrderViewModelProvider.notifier).updateWorkOrderStatus(workOrder.id, 'selesai');
                  }
                },
              ),
              ListTile(
                title: const Text('Terkendala'),
                onTap: () {
                  if (workOrder.status == 'selesai') {
                    Navigator.pop(context);
                    _showConfirmDialog(context, ref, 'terkendala');
                  } else {
                    ref.read(workOrderViewModelProvider.notifier).updateWorkOrderStatus(workOrder.id, 'terkendala');
                    Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                title: const Text('Dalam Pengerjaan'),
                onTap: () {
                  if (workOrder.status == 'selesai') {
                    Navigator.pop(context);
                    _showConfirmDialog(context, ref, 'dalam_pengerjaan');
                  } else {
                    ref.read(workOrderViewModelProvider.notifier).updateWorkOrderStatus(workOrder.id, 'dalam_pengerjaan');
                    if (workOrder.startTime == null) {
                      ref.read(workOrderViewModelProvider.notifier).updateStartTime(workOrder.id);
                    }
                    Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                title: const Text('Belum Mulai'),
                onTap: () {
                  if (workOrder.status == 'selesai') {
                    Navigator.pop(context);
                    _showConfirmDialog(context, ref, 'belum_mulai');
                  } else {
                    ref.read(workOrderViewModelProvider.notifier).updateWorkOrderStatus(workOrder.id, 'belum_mulai');
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}