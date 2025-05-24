import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/report/domain/report.dart';
import 'package:pantau_app/features/report/presentation/providers/report_providers.dart';
import 'package:pantau_app/features/report/presentation/screen/report_edit_screen.dart';
import 'package:pantau_app/features/work/domain/models/work_order.dart';

class ReportSection extends ConsumerWidget {
  static const String route = '/workorder/report_screen';
  final WorkOrder workOrder;

  const ReportSection({
    super.key,
    required this.workOrder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(workOrderReportsProvider(workOrder.id));

    return reportsAsync.when(
      data: (reports) {
        if (reports[0].afterPhoto == null && reports[0].note == null) {
          return const SizedBox.shrink();
        } else {
        return _buildReportsList(context, reports);
        }
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      ),
      error: (error, stack) => _buildErrorCard(context, error),
    );
  }

  Widget _buildErrorCard(BuildContext context, Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.errorColor, size: 32),
          const SizedBox(height: 8),
          Text(
            'Failed to load reports',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => {},
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.errorColor,
              side: const BorderSide(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList(BuildContext context, List<Report> reports) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.photo_library_outlined, color: AppColors.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Photos & Notes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: reports.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return _buildReportItem(context, report);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32)
      ],
    );
  }

  Widget _buildReportItem(BuildContext context, Report report) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text(
        'Report on ${report.createdAt != null
          ? DateFormat('dd MMM yyyy').format(report.createdAt!)
          : '-'}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        report.createdAt != null
          ? DateFormat('HH:mm').format(report.createdAt!)
          : '-',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
      children: [
        if (report.beforePhoto != null || report.afterPhoto != null)
          Row(
            children: [
              if (report.beforePhoto != null)
                Expanded(child: _buildPhotoCard(context, report.beforePhoto!, 'Before')),
              const SizedBox(width: 12),
              if (report.afterPhoto != null)
                Expanded(child: _buildPhotoCard(context, report.afterPhoto!, 'After')),
            ],
          ),
        if (report.note != null && report.note!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notes, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Note',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  report.note!,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                EditReportScreen.route,
                arguments: {
                  'workOrderId': workOrder.id,
                  'isTerkendala': workOrder.status == 'terkendala',
                },
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Report'),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade50,
              foregroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(BuildContext context, String imageUrl, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              label == 'Before' ? Icons.photo_camera_outlined : Icons.check_circle_outline,
              size: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () {
            _showFullScreenImage(context, imageUrl, label);
          },
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: AppColors.primaryColor,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade100,
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey.shade400,
                        size: 36,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl, String label) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.cardColor,
        insetPadding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    '$label Photo',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              width: double.infinity,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}