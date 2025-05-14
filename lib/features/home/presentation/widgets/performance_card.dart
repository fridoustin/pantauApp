import 'package:flutter/material.dart';
import 'package:pantau_app/core/constant/colors.dart';

class PerformanceCard extends StatelessWidget {
  final String title;
  final int totalTasks;
  final int completedTasks;
  final int averageCompletionTimeHours;

  const PerformanceCard({
    super.key,
    required this.title,
    required this.totalTasks,
    required this.completedTasks,
    required this.averageCompletionTimeHours,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate completion rate as percentage
    final completionRate = totalTasks > 0 
        ? (completedTasks / totalTasks * 100).round() 
        : 0;

    return Card(
      color: AppColors.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Icon(
                  Icons.insights,
                  color: AppColors.primaryColor,
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (totalTasks == 0)
              // Container dengan tinggi tetap agar card tidak collapse
              Container(
                height: 80,
                alignment: Alignment.center,
                child: Text(
                  'No data to display',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                ),
              )
            else ...[
              // Baris performance items
              Row(
                children: [
                  Expanded(
                    child: _buildPerformanceItem(
                      context,
                      'Completion Rate',
                      '$completionRate%',
                      Icons.task_alt,
                      AppColors.successColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPerformanceItem(
                      context,
                      'Average Time',
                      '$averageCompletionTimeHours hour',
                      Icons.timer,
                      Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress bar
              LinearProgressIndicator(
                value: completedTasks / totalTasks,
                backgroundColor: Colors.grey[200],
                color: AppColors.primaryColor,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}