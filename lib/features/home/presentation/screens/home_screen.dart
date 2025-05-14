import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/common/widgets/custom_app_bar.dart';
import 'package:pantau_app/common/widgets/navBar/navigation_bar.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/home/presentation/widgets/category_statistic_card.dart';
import 'package:pantau_app/features/work/domain/models/work_order.dart';
import 'package:pantau_app/features/work/presentation/providers/work_order_provider.dart';
import 'package:pantau_app/features/home/presentation/providers/home_providers.dart';
import 'package:pantau_app/features/home/presentation/widgets/statistic_card.dart';
import 'package:pantau_app/features/home/presentation/widgets/work_status_chart.dart';
import 'package:pantau_app/features/home/presentation/widgets/performance_card.dart';
import 'package:pantau_app/features/work/presentation/widgets/work_order_card.dart';

// Define a provider for the view mode
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.today);

// Enum for view modes
enum ViewMode { today, all }

class HomeScreen extends ConsumerWidget {
  static const String route = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workOrdersAsync = ref.watch(workOrdersProvider);
    final statisticsAsync = ref.watch(homeStatisticsProvider);
    final todayWorkOrdersAsync = ref.watch(todayWorkOrdersProvider);
    final overdueWorkOrdersAsync = ref.watch(overdueWorkOrdersProvider);
    final viewMode = ref.watch(viewModeProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const CustomAppBar(title: "Home"),
      bottomNavigationBar: const NavigationBarWidget(currentIndex: 0),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh data by invalidating the provider
          ref.invalidate(workOrdersProvider);
        },
        child: workOrdersAsync.when(
          data: (_) => statisticsAsync.when(
            data: (stats) => todayWorkOrdersAsync.when(
              data: (todayWorkOrders) => overdueWorkOrdersAsync.when(
                data: (overdueWorkOrders) => _buildContent(
                  context, 
                  ref, 
                  stats, 
                  todayWorkOrders, 
                  overdueWorkOrders,
                  viewMode
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error: ${error.toString()}', 
                    style: const TextStyle(color: AppColors.errorColor)),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: ${error.toString()}', 
                  style: const TextStyle(color: AppColors.errorColor)),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error: ${error.toString()}', 
                style: const TextStyle(color: AppColors.errorColor)),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: ${error.toString()}', 
              style: const TextStyle(color: AppColors.errorColor)),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, 
    WidgetRef ref,
    Map<String, int> stats, 
    List<WorkOrder> todayWorkOrders,
    List<WorkOrder> overdueWorkOrders,
    ViewMode viewMode
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Text(
                _getGreeting(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Berikut ringkasan pekerjaan anda',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),

              // View Toggle Buttons
              _buildViewToggle(context, ref, viewMode),
              const SizedBox(height: 24),

              // Dynamic content based on view mode
              ...viewMode == ViewMode.today 
                  ? _buildTodayView(context, stats)
                  : _buildAllView(context, stats),

              const SizedBox(height: 32),
              
              // Work Orders in horizontal layout
              _buildWorkOrdersSection(context, todayWorkOrders, overdueWorkOrders, stats),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context, WidgetRef ref, ViewMode currentMode) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            context, 
            'TODAY', 
            currentMode == ViewMode.today,
            () => ref.read(viewModeProvider.notifier).state = ViewMode.today,
          ),
          _buildToggleButton(
            context, 
            'ALL', 
            currentMode == ViewMode.all,
            () => ref.read(viewModeProvider.notifier).state = ViewMode.all,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(BuildContext context, String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }

  List<Widget> _buildTodayView(BuildContext context, Map<String, int> stats) {
    return [
      // Statistics cards for Today
      Row(
        children: [
          Expanded(
            child: StatisticCard(
              title: 'Today WO',
              value: stats['today'].toString(),
              iconData: Icons.today_outlined,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatisticCard(
              title: 'Today Completed',
              value: stats['todayCompleted'].toString(),
              iconData: Icons.done,
              color: AppColors.black,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      
      // Floor Statistics Card for Today
      CategoryStatisticsCard(
        title: 'Today Category Distribution',
        floorStats: stats,
        isToday: true,
      ),
      const SizedBox(height: 24),

      // Performance card for Today
      PerformanceCard(
        title: "Today Progress",
        totalTasks: stats['today'] ?? 0,
        completedTasks: stats['todayCompleted'] ?? 0,
        averageCompletionTimeHours: stats['todayAverageCompletionTimeHours'] ?? 0,
      ),

      const SizedBox(height: 24),
      
      // Chart section for Today
      Card(
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
              Text(
                'Today Work Order Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: WorkStatusChart(
                  notStarted: stats['todayNotStarted'] ?? 0,
                  inProgress: stats['todayInProgress'] ?? 0,
                  pending: stats['todayPending'] ?? 0,
                  completed: stats['todayCompleted'] ?? 0,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildAllView(BuildContext context, Map<String, int> stats) {
    return [
      // Statistics cards for All Time
      Row(
        children: [
          Expanded(
            child: StatisticCard(
              title: 'Total WO',
              value: stats['total'].toString(),
              iconData: Icons.calendar_month,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatisticCard(
              title: 'Total Completed',
              value: stats['completed'].toString(),
              iconData: Icons.done_all,
              color: AppColors.black,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      
      // Floor Statistics Card for All Time
      CategoryStatisticsCard(
        title: 'Category Distribution',
        floorStats: stats,
        isToday: false,
      ),
      const SizedBox(height: 24),

      // Performance card for All Time
      PerformanceCard(
        title: "Progress",
        totalTasks: stats['total'] ?? 0,
        completedTasks: stats['completed'] ?? 0,
        averageCompletionTimeHours: stats['averageCompletionTimeHours'] ?? 0,
      ),
      const SizedBox(height: 24),

      // Chart section for All Time
      Card(
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
              Text(
                'Work Order Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: WorkStatusChart(
                  notStarted: stats['notStarted'] ?? 0,
                  inProgress: stats['inProgress'] ?? 0,
                  pending: stats['pending'] ?? 0,
                  completed: stats['completed'] ?? 0,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildWorkOrdersSection(
    BuildContext context, 
    List<WorkOrder> todayWorkOrders, 
    List<WorkOrder> overdueWorkOrders,
    Map<String, int> stats
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Today work orders section
        Text(
          'Today Work Order (${stats['today']! - stats['todayCompleted']!})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        todayWorkOrders.isEmpty
            ? const Card(
                color: AppColors.cardColor,
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No work today',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todayWorkOrders.length,
                itemBuilder: (context, index) {
                  final workOrder = todayWorkOrders[index];
                  return WorkOrderCard(workOrder: workOrder);
                },
              ),
        const SizedBox(height: 24),

        // Overdue work orders section
        Text(
          'Overdue Work Order (${stats['overdue']})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        // Display overdue work orders
        overdueWorkOrders.isEmpty
            ? const Card(
                color: AppColors.cardColor,
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No overdue work orders',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: overdueWorkOrders.length,
                itemBuilder: (context, index) {
                  final workOrder = overdueWorkOrders[index];
                  return WorkOrderCard(
                    workOrder: workOrder,
                  );
                },
              ),
      ],
    );
  }
  
  String _getGreeting() {
    final todayHour = DateTime.now().hour;
    if (todayHour >= 5 && todayHour < 11) {
      return 'Selamat Pagi';
    } else if (todayHour >= 11 && todayHour < 15) {
      return 'Selamat Siang';
    } else if (todayHour >= 15 && todayHour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }
}