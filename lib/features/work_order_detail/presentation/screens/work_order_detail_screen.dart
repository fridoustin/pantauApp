import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pantau_app/common/widgets/custom_app_bar.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/report/presentation/screen/report_edit_screen.dart';
import 'package:pantau_app/features/report/presentation/screen/report_screen.dart';
import 'package:pantau_app/features/report/presentation/widget/report_section_widget.dart';
import 'package:pantau_app/features/work/domain/models/work_order.dart';
import 'package:pantau_app/features/work/presentation/providers/admin_provider.dart';
import 'package:pantau_app/features/work/presentation/viewmodels/work_order_viewmodel.dart';
import 'package:pantau_app/features/work_order_detail/presentation/providers/work_order_detail_provider.dart';

class WorkOrderDetailScreen extends ConsumerWidget {
  static const String route = '/workorder/detail';
  final String workOrderId;

  const WorkOrderDetailScreen({
    super.key,
    required this.workOrderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workOrderAsync = ref.watch(workOrderDetailProvider(workOrderId));
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Work Order Detail",
        showBackButton: true,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: workOrderAsync.when(
        data: (workOrder) => _buildDetailContent(context, ref, workOrder),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryColor),
              SizedBox(height: 16),
              Text('Loading work order details...')
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.errorColor, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to load work order details',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('Error: $error', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.refresh(workOrderDetailProvider(workOrderId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, WidgetRef ref, WorkOrder workOrder) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, workOrder),
          const SizedBox(height: 16),

          _buildAllDetailCard(context, workOrder),
          const SizedBox(height: 24),
          
          // Status options
          _buildStatusSection(context, ref, workOrder),
          const SizedBox(height: 24),

          if (workOrder.status == 'terkendala' || workOrder.status == 'selesai')
            // Report section
            ReportSection(workOrder: workOrder),
          
          // Action buttons
          _buildActionButtons(context, ref, workOrder),          
        ],
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context, WorkOrder workOrder) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        border: Border(bottom: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.2), width: 1)),
        borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  workOrder.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              _buildStatusChip(context, workOrder.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                _getCategoryName(workOrder.categoryId).isEmpty ? '-' : _getCategoryName(workOrder.categoryId),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Created ${_getTimeAgo(workOrder.createdAt)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusChip(BuildContext context, String status) {
    final Map<String, Map<String, dynamic>> statusConfig = {
      'belum_mulai': {
        'color': Colors.grey,
        'label': 'Belum Mulai',
        'icon': Icons.hourglass_empty,
      },
      'dalam_pengerjaan': {
        'color': Colors.blue,
        'label': 'Dalam Pengerjaan',
        'icon': Icons.engineering,
      },
      'terkendala': {
        'color': Colors.red,
        'label': 'Terkendala',
        'icon': Icons.warning_amber_rounded,
      },
      'selesai': {
        'color': AppColors.successColor,
        'label': 'Selesai',
        'icon': Icons.check_circle,
      },
    };
    
    final config = statusConfig[status] ?? statusConfig['belum_mulai']!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: config['color'], width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config['icon'], size: 16, color: config['color']),
          const SizedBox(width: 4),
          Text(
            config['label'],
            style: TextStyle(
              color: config['color'],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllDetailCard(BuildContext context, WorkOrder workOrder) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description card
          _buildDescriptionCard(context, workOrder),
          const SizedBox(height: 16),
          
          // Schedule card
          _buildScheduleCard(context, workOrder),
          const SizedBox(height: 16),
          
          // Information card
          _buildInformationCard(context, workOrder),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildDescriptionCard(BuildContext context, WorkOrder workOrder) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description_outlined, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              workOrder.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScheduleCard(BuildContext context, WorkOrder workOrder) {
    return Card(
      elevation: 0,
      color: AppColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Schedule',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildScheduleItem(
                    context,
                    'Start Date',
                    workOrder.startTime != null
                        ? DateFormat('dd MMM yyyy\nHH:mm').format(workOrder.startTime!)
                        : 'Not scheduled',
                    Icons.play_circle_outline,
                    Colors.blue,
                  ),
                ),
                Container(
                  height: 60,
                  width: 1,
                  color: Colors.grey.shade200,
                ),
                Expanded(
                  child: _buildScheduleItem(
                    context,
                    'Due Date',
                    workOrder.endTime != null
                        ? DateFormat('dd MMM yyyy\nHH:mm').format(workOrder.endTime!)
                        : 'Not scheduled',
                    Icons.event_busy,
                    Colors.red.shade300,
                  ),
                ),
              ],
            ),
            
            // Show deadline indicator if due date exists
            if (workOrder.endTime != null && (workOrder.status != 'selesai' || (workOrder.status == 'selesai' && workOrder.updatedAt != null && workOrder.endTime!.difference(workOrder.updatedAt!).isNegative)))
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: _buildDeadlineIndicator(context, workOrder.endTime!),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScheduleItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4), 
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeadlineIndicator(BuildContext context, DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    final daysLeft = difference.inDays;

    // untuk membandingkan hanya bagian date (year, month, day)
    final todayDate = DateTime(now.year, now.month, now.day);
    final tomorrowDate = todayDate.add(const Duration(days: 1));
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);

    Color indicatorColor;
    String statusText;

    if (difference.isNegative) {
      indicatorColor = AppColors.errorColor;
      statusText = 'Overdue by ${-daysLeft} days';
    }
    else if (difference.inHours < 24) {
      indicatorColor = Colors.orange;
      statusText = 'Due in ${difference.inHours} hours';
    }
    else if (dueDateOnly == tomorrowDate) {
      indicatorColor = Colors.orange;
      statusText = 'Due tomorrow';
    }
    else if (daysLeft <= 3) {
      indicatorColor = AppColors.warningColor;
      statusText = 'Due in $daysLeft days';
    }
    else {
      indicatorColor = AppColors.successColor;
      statusText = 'Due in $daysLeft days';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: indicatorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: indicatorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            difference.isNegative 
                ? Icons.warning_amber_rounded 
                : Icons.schedule,
            size: 16,
            color: indicatorColor,
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: indicatorColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInformationCard(BuildContext context, WorkOrder workOrder) {
    return Card(
      elevation: 0,
      color: AppColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Additional Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context, 
                        'Location',
                        _getCategoryName(workOrder.categoryId),
                        Icons.location_on_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        context, 
                        'Created',
                        DateFormat('dd MMM yyyy').format(workOrder.createdAt),
                        Icons.event_available,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context, 
                        'Last Updated',
                        workOrder.updatedAt != null 
                          ? DateFormat('dd MMM yyyy').format(workOrder.updatedAt!) 
                          : 'Never updated',
                        Icons.update,
                      ),
                    ),
                    if (workOrder.adminId != null && workOrder.adminId!.isNotEmpty)
                      const SizedBox(width: 16),
                    if (workOrder.adminId != null && workOrder.adminId!.isNotEmpty)
                      Expanded(
                        child: _buildAdminInfoItem(context, workOrder.adminId!),
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

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminInfoItem(BuildContext context, String adminId) {
    return Consumer(
      builder: (context, ref, child) {
        final adminAsyncValue = ref.watch(adminByIdProvider(adminId));
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(Icons.admin_panel_settings, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Admin',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              adminAsyncValue.when(
                data: (admin) => Text(
                  admin?.name ?? _formatAdminId(adminId),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                loading: () => const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                ),
                error: (_, __) => Text(
                  'Error loading admin',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatAdminId(String adminId) {
    // Show only first 8 characters of admin ID if it's too long
    if (adminId.length > 10) {
      return '${adminId.substring(0, 8)}...';
    }
    return adminId;
  }
  
  Widget _buildStatusSection(BuildContext context, WidgetRef ref, WorkOrder workOrder) {
    final statuses = ['belum_mulai', 'dalam_pengerjaan', 'terkendala', 'selesai'];
    final statusLabels = ['Belum Mulai', 'Dalam Pengerjaan', 'Terkendala', 'Selesai'];
    final statusIcons = [
      Icons.hourglass_empty,
      Icons.engineering, 
      Icons.warning_amber_rounded, 
      Icons.check_circle
    ];
    final statusColors = [
      Colors.grey,
      Colors.blue,
      Colors.red,
      AppColors.successColor,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Update Status',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: AppColors.cardColor,
              child: Row(
                children: List.generate(statuses.length, (index) {
                  final isSelected = workOrder.status == statuses[index];
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        if (statuses[index] == 'selesai' && workOrder.status != 'selesai' && workOrder.afterPhoto == null && workOrder.note == null) {
                          Navigator.pushNamed(
                            context, 
                            ReportScreen.route,
                            arguments: {
                              'workOrderId': workOrderId,
                              'isTerkendala': false,
                            },
                          );
                        } else if (statuses[index] == 'selesai' && workOrder.status != 'selesai' && (workOrder.afterPhoto != null || workOrder.note != null)) {
                          Navigator.pushNamed(
                            context,
                            EditReportScreen.route,
                            arguments: {
                              'workOrderId': workOrderId,
                              'isTerkendala': false,
                              'status': statuses[index],
                            },
                          );
                        } else if (statuses[index] != 'selesai' && workOrder.status == 'selesai') {
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
                                    _updateStatus(ref, workOrder.id, workOrder.startTime, statuses[index]);
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
                        } else if (statuses[index] == 'terkendala' && workOrder.status != 'terkendala' && workOrder.afterPhoto == null && workOrder.note == null) {
                          Navigator.pushNamed(
                            context, 
                            ReportScreen.route,
                            arguments: {
                              'workOrderId': workOrderId,
                              'isTerkendala': true,
                            },
                          );
                        } else if (statuses[index] == 'terkendala' && workOrder.status != 'terkendala' && (workOrder.afterPhoto != null || workOrder.note != null)) {
                          Navigator.pushNamed(
                            context, 
                            EditReportScreen.route,
                            arguments: {
                              'workOrderId': workOrderId,
                              'isTerkendala': true,
                              'status': statuses[index],
                            },
                          );
                        } else {
                          _updateStatus(ref, workOrder.id, workOrder.startTime, statuses[index]);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        height: 105,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? statusColors[index].withValues(alpha: 0.2) 
                              : Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected 
                                  ? statusColors[index]
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              statusIcons[index],
                              color: isSelected 
                                  ? statusColors[index]
                                  : Colors.grey.shade400,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              statusLabels[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected 
                                    ? statusColors[index]
                                    : Colors.grey.shade700,
                                fontWeight: isSelected 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButtons(BuildContext context, WidgetRef ref, WorkOrder workOrder) {
    return Column(
      children: [
        // Edit button (hanya muncul saat tidak ada admin di database)
        if (workOrder.adminId == null || workOrder.adminId!.isEmpty) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context, 
                  '/workorder/edit',
                  arguments: workOrder,
                );
              },
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
              label: const Text('Edit Work Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.cardColor,
                    title: const Text('Confirm Deletion'),
                    content: const Text(
                      "Are you sure you want to delete this work order?",
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(), 
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _deleteWorkOrder(ref, workOrderId);
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
              label: const Text('Delete Work Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ]
      ],
    );
  }

  void _updateStatus(WidgetRef ref, String workOrderId, DateTime? workOrderStartTime, String newStatus) {
    ref.read(workOrderViewModelProvider.notifier).updateWorkOrderStatus(workOrderId, newStatus);
    if (workOrderStartTime == null && newStatus == 'dalam_pengerjaan') {
      ref.read(workOrderViewModelProvider.notifier).updateStartTime(workOrderId);
    }
  }

  void _deleteWorkOrder(WidgetRef ref, String workOrderId) {
    ref.read(workOrderViewModelProvider.notifier).deleteWorkOrder(workOrderId);
  }

  String _getCategoryName(String? categoryId) {
    final Map<String, String> categories = {
      '81e188a8-e7e4-401b-8a16-300d92e53abe': 'Basement',      
      '3b39fcc9-710c-4dd4-a26a-f5ce854cb038': 'GF',
      '1f0973f6-f92c-4b65-9cd8-8d82e897d1ae': 'Lt. 1',
      '156d317c-d94a-4e3d-9cf5-da90681b3a60': 'Lt. 2',
      'b3955121-15ec-4b75-acc7-20be78921f66': 'Lt. 3',
      '45cc0e22-76b3-42a5-b61f-6ffde101624b': 'Rooftop',
    };
    
    return categories[categoryId] ?? (categoryId != null ? 'Category #$categoryId' : '');
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }
}