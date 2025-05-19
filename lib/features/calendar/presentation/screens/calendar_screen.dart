// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/common/widgets/custom_app_bar.dart';
import 'package:pantau_app/common/widgets/layout/app_scaffold.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/calendar/presentation/providers/calendar_provider.dart';
import 'package:pantau_app/features/calendar/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:pantau_app/features/work/domain/models/work_order.dart';
import 'package:pantau_app/features/work/presentation/widgets/work_order_card.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});
  static const String route = '/calendar';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final monthWorkOrdersAsync = ref.watch(monthWorkOrdersProvider(DateTime(selectedDate.year, selectedDate.month)));
    final selectedDayWorkOrders = ref.watch(selectedDayWorkOrdersProvider);
    
    return AppScaffold(
      appBar: const CustomAppBar(title: 'Calendar'),
      currentIndex: 2,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Calendar Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Work Schedule',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: monthWorkOrdersAsync.when(
                        data: (workOrders) {
                          // Create a mapping of dates with work orders
                          final events = <DateTime, List<WorkOrder>>{};
                          for (final order in workOrders) {
                            final date = order.createdAt;
                            final normalizedDate = DateTime(date.year, date.month, date.day);
                            events.putIfAbsent(normalizedDate, () => []).add(order);
                          }
                          
                          return TableCalendar(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: selectedDate,
                            calendarFormat: CalendarFormat.month,
                            eventLoader: (day) {
                              final normalizedDay = DateTime(day.year, day.month, day.day);
                              return events[normalizedDay] ?? [];
                            },
                            selectedDayPredicate: (day) {
                              return isSameDay(selectedDate, day);
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              ref.read(calendarViewModelProvider.notifier).selectDate(selectedDay);
                            },
                            headerStyle: const HeaderStyle(
                              titleCentered: true,
                              formatButtonVisible: false,
                              leftChevronIcon: Icon(Icons.chevron_left),
                              rightChevronIcon: Icon(Icons.chevron_right),
                              titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              // //color - header color
                            ),
                            calendarStyle: CalendarStyle(
                              // //color - selected date color
                              selectedDecoration: const BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              markerDecoration: const BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              markerMargin: const EdgeInsets.only(top: 6),
                              // markerSize: 8,
                            ),
                            rowHeight: 56,
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Center(child: Text('Error loading calendar: $err')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Work Orders Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Work Orders',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  selectedDayWorkOrders.isEmpty
                    ? const Center(child: Text('No work orders for this day'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: selectedDayWorkOrders.length,
                        itemBuilder: (context, index) {
                          final workOrder = selectedDayWorkOrders[index];
                          return WorkOrderCard(workOrder: workOrder);
                        },
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}