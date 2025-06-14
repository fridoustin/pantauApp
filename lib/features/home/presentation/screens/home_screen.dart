import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/common/widgets/custom_app_bar.dart';
import 'package:pantau_app/common/widgets/navBar/navigation_bar.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/calendar/presentation/providers/calendar_provider.dart';
import 'package:pantau_app/features/home/presentation/widgets/category_statistic_card.dart';
import 'package:pantau_app/features/work/domain/models/work_order.dart';
import 'package:pantau_app/features/work/presentation/providers/work_order_provider.dart';
import 'package:pantau_app/features/home/presentation/providers/home_providers.dart';
import 'package:pantau_app/features/home/presentation/widgets/statistic_card.dart';
import 'package:pantau_app/features/home/presentation/widgets/work_status_chart.dart';
import 'package:pantau_app/features/home/presentation/widgets/performance_card.dart';
import 'package:pantau_app/features/work/presentation/widgets/work_order_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final supabase = Supabase.instance.client;

// Define a provider for the view mode
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.today);

// Enum for view modes
enum ViewMode { today, all }

class HomeScreen extends ConsumerStatefulWidget {
  static const String route = '/home';

  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    supabase.auth.onAuthStateChange.listen((event) async {
      await FirebaseMessaging.instance.requestPermission();

      await FirebaseMessaging.instance.getAPNSToken();
      final fcmToken =
          await FirebaseMessaging.instance.getToken();
      if(fcmToken != null) {
        await _setFcmToken(fcmToken);
      }
    });
    FirebaseMessaging.instance.onTokenRefresh
        .listen((fcmToken) async {
      _setFcmToken(fcmToken);
    });

    FirebaseMessaging.onMessage.listen((payload) {
      final notification = payload.notification;
      if (notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            '${notification.title} ${notification.body}'
          )));
      }
    });
  }

  Future <void> _setFcmToken(String fcmToken) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      await supabase
        .from('technician')
        .update({'fcm_token': fcmToken})
        .eq('technician_id', userId);
    }
  }
  
  @override
  Widget build(BuildContext context) {
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
          ref.invalidate(workOrdersProvider);
        },
        child: workOrdersAsync.when(
          data: (_) => statisticsAsync.when(
            data: (stats) => todayWorkOrdersAsync.when(
              data: (todayWorkOrders) => overdueWorkOrdersAsync.when(
                data: (overdueWorkOrders) => _buildContent(
                  context,
                  stats,
                  todayWorkOrders,
                  overdueWorkOrders,
                  viewMode,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildError(error),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildError(error),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildError(error),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildError(error),
        ),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi kesalahan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            // const SizedBox(height: 8),
            // Text(
            //   'Error: ${error.toString()}',
            //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            //     color: Colors.grey[600],
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Refresh all providers
                ref.invalidate(workOrdersProvider);
                ref.invalidate(monthWorkOrdersProvider);
                // ref.invalidate(homeStatisticsProvider);
                // ref.invalidate(todayWorkOrdersProvider);
                // ref.invalidate(overdueWorkOrdersProvider);
              },
              icon: const Icon(
                Icons.refresh,
                color: Colors.white
              ),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Map<String, int> stats,
    List<WorkOrder> todayWorkOrders,
    List<WorkOrder> overdueWorkOrders,
    ViewMode viewMode,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              _buildViewToggle(context, viewMode),
              const SizedBox(height: 24),
              if (viewMode == ViewMode.today) ..._buildTodayView(context, stats),
              if (viewMode == ViewMode.all) ..._buildAllView(context, stats),
              const SizedBox(height: 32),
              _buildWorkOrdersSection(
                context,
                todayWorkOrders,
                overdueWorkOrders,
                stats,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context, ViewMode currentMode) {
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

  Widget _buildToggleButton(
    BuildContext context,
    String title,
    bool isActive,
    VoidCallback onTap,
  ) {
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

  List<Widget> _buildTodayView(BuildContext context, Map<String, int> stats) => [
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
        CategoryStatisticsCard(
          title: 'Today Floor Distribution',
          floorStats: stats,
          isToday: true,
        ),
        const SizedBox(height: 24),
        PerformanceCard(
          title: "Today Progress",
          totalTasks: stats['today'] ?? 0,
          completedTasks: stats['todayCompleted'] ?? 0,
          averageCompletionTimeHours: stats['todayAverageCompletionTimeHours'] ?? 0,
        ),
        const SizedBox(height: 24),
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

  List<Widget> _buildAllView(BuildContext context, Map<String, int> stats) => [
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
        CategoryStatisticsCard(
          title: 'Floor Distribution',
          floorStats: stats,
          isToday: false,
        ),
        const SizedBox(height: 24),
        PerformanceCard(
          title: "Progress",
          totalTasks: stats['total'] ?? 0,
          completedTasks: stats['completed'] ?? 0,
          averageCompletionTimeHours: stats['averageCompletionTimeHours'] ?? 0,
        ),
        const SizedBox(height: 24),
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

  Widget _buildWorkOrdersSection(
    BuildContext context,
    List<WorkOrder> todayWorkOrders,
    List<WorkOrder> overdueWorkOrders,
    Map<String, int> stats,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                itemBuilder: (context, index) => WorkOrderCard(workOrder: todayWorkOrders[index]),
              ),
        const SizedBox(height: 24),
        Text(
          'Overdue Work Order (${stats['overdue']})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
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
                itemBuilder: (context, index) => WorkOrderCard(workOrder: overdueWorkOrders[index]),
              ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }
}