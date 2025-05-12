// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/calendar/domain/models/work_order.dart';
import 'package:pantau_app/features/calendar/presentation/providers/calendar_provider.dart';
import 'package:pantau_app/features/calendar/presentation/viewmodels/calendar_viewmodel.dart';

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

    // Function to get category icon
    IconData getCategoryIcon(String? categoryId) {
      // This is a placeholder. You should replace with your actual category logic
      switch (categoryId) {
        case '1': // Assuming 1 is HVAC
          return Icons.ac_unit; // //icon - HVAC icon
        case '2': // Assuming 2 is Plumbing
          return Icons.water_drop; // //icon - Plumbing icon
        default:
          return Icons.handyman; // //icon - Default maintenance icon
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
                      color: Colors.blue[100], // //color - time background color
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      workOrder.startTime != null
                        ? DateFormat('h:mm a').format(workOrder.startTime!)
                        : '-',
                      style: TextStyle(
                        color: Colors.blue[800], // //color - time text color
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
                        icon: const Icon(Icons.edit), // //icon - edit icon
                        onPressed: () {
                          _showStatusUpdateDialog(context, ref, workOrder);
                        },
                      ),
                      // Sync with device calendar button
                      // IconButton(
                      //   icon: const Icon(Icons.calendar_today), // //icon - calendar icon
                      //   onPressed: () {
                      //     _showCalendarSyncDialog(context, ref, workOrder);
                      //   },
                      // ),
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
                  ref.read(calendarViewModelProvider.notifier).updateWorkOrderStatus(workOrder.id, 'selesai');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Dalam Pengerjaan'),
                onTap: () {
                  ref.read(calendarViewModelProvider.notifier).updateWorkOrderStatus(workOrder.id, 'dalam_pengerjaan');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Terkendala'),
                onTap: () {
                  ref.read(calendarViewModelProvider.notifier).updateWorkOrderStatus(workOrder.id, 'terkendala');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Belum Mulai'),
                onTap: () {
                  ref.read(calendarViewModelProvider.notifier).updateWorkOrderStatus(workOrder.id, 'belum_mulai');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // void _showCalendarSyncDialog(BuildContext context, WidgetRef ref, WorkOrder workOrder) {
  //   final calendarsAsync = ref.watch(deviceCalendarsProvider);
    
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Sync with Calendar'),
  //         content: SizedBox(
  //           width: double.maxFinite,
  //           child: calendarsAsync.when(
  //             data: (calendars) {
  //               return ListView.builder(
  //                 shrinkWrap: true,
  //                 itemCount: calendars.length,
  //                 itemBuilder: (context, index) {
  //                   final calendar = calendars[index];
  //                   return ListTile(
  //                     title: Text(calendar.name ?? 'Unnamed Calendar'),
  //                     onTap: () {
  //                       ref.read(calendarViewModelProvider.notifier)
  //                         .syncWithDeviceCalendar(workOrder, calendar.id ?? '');
  //                       Navigator.pop(context);
  //                       ScaffoldMessenger.of(context).showSnackBar(
  //                         const SnackBar(content: Text('Work order synced with calendar')),
  //                       );
  //                     },
  //                   );
  //                 },
  //               );
  //             },
  //             loading: () => const Center(child: CircularProgressIndicator()),
  //             error: (_, __) => const Text('Failed to load calendars'),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('Cancel'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}