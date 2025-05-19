import 'package:flutter/material.dart';
import 'package:pantau_app/core/constant/colors.dart';

class CategoryStatisticsCard extends StatelessWidget {
  final String title;
  final Map<String, int> floorStats;
  final Map<String, String> floorNames;
  final bool isToday;

  const CategoryStatisticsCard({
    super.key,
    required this.title,
    required this.floorStats,
    this.isToday = false,
    this.floorNames = const {
      'basement': 'Basement',
      'GF': 'GF',
      'lt1': 'Lt.1',
      'lt2': 'Lt.2',
      'lt3': 'Lt.3',
      'rooftop': 'Rooftop',
    },
  });

  @override
  Widget build(BuildContext context) {
    final stats = isToday
        ? {
            'basement': floorStats['todayBasement'] ?? 0,
            'GF': floorStats['todayGF'] ?? 0,
            'lt1': floorStats['todayLt1'] ?? 0,
            'lt2': floorStats['todayLt2'] ?? 0,
            'lt3': floorStats['todayLt3'] ?? 0,
            'rooftop': floorStats['todayRooftop'] ?? 0,
          }
        : {
            'basement': floorStats['basement'] ?? 0,
            'GF': floorStats['GF'] ?? 0,
            'lt1': floorStats['lt1'] ?? 0,
            'lt2': floorStats['lt2'] ?? 0,
            'lt3': floorStats['lt3'] ?? 0,
            'rooftop': floorStats['rooftop'] ?? 0,
          };

    final totalFloors = stats.values.fold(0, (sum, count) => sum + count);

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
                  Icons.location_on,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (totalFloors == 0)
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
            else
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildFloorItem(
                          context,
                          floorNames['basement']!,
                          stats['basement']!,
                          Colors.grey[700]!,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFloorItem(
                          context,
                          floorNames['GF']!,
                          stats['GF']!,
                          Colors.blue[700]!,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFloorItem(
                          context,
                          floorNames['lt1']!,
                          stats['lt1']!,
                          Colors.green[700]!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFloorItem(
                          context,
                          floorNames['lt2']!,
                          stats['lt2']!,
                          Colors.orange[700]!,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFloorItem(
                          context,
                          floorNames['lt3']!,
                          stats['lt3']!,
                          Colors.purple[700]!,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFloorItem(
                          context,
                          floorNames['rooftop']!,
                          stats['rooftop']!,
                          Colors.red[700]!,
                        ),
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

  Widget _buildFloorItem(
    BuildContext context,
    String name,
    int count,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}