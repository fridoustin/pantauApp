import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pantau_app/core/constant/colors.dart';

class WorkStatusChart extends StatelessWidget {
  final int notStarted;
  final int inProgress;
  final int pending;
  final int completed;

  const WorkStatusChart({
    super.key,
    required this.notStarted,
    required this.inProgress,
    required this.pending,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final total = notStarted + inProgress + pending + completed;
    
    // Avoid division by zero
    if (total == 0) {
      return Center(
        child: Text(
          'No data to display',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  value: notStarted.toDouble(),
                  title: '${(notStarted / total * 100).toStringAsFixed(0)}%',
                  color: Colors.grey,
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: inProgress.toDouble(),
                  title: '${(inProgress / total * 100).toStringAsFixed(0)}%',
                  color: Colors.blue,
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: pending.toDouble(),
                  title: '${(pending / total * 100).toStringAsFixed(0)}%',
                  color: Colors.red,
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: completed.toDouble(),
                  title: '${(completed / total * 100).toStringAsFixed(0)}%',
                  color: AppColors.successColor,
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem('Belum mulai', Colors.grey, notStarted),
              const SizedBox(height: 12),
              _buildLegendItem('Dalam pengerjaan', Colors.blue, inProgress),
              const SizedBox(height: 12),
              _buildLegendItem('Terkendala', Colors.red, pending),
              const SizedBox(height: 12),
              _buildLegendItem('Selesai', AppColors.successColor, completed),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($value)',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}