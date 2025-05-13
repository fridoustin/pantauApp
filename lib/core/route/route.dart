import 'package:flutter/material.dart';
import 'package:pantau_app/features/auth/presentation/screens/login_screen.dart';
import 'package:pantau_app/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:pantau_app/features/create_work_order/presentation/screens/create_work_order_screen.dart';
import 'package:pantau_app/features/home/presentation/screens/home_screen.dart';
import 'package:pantau_app/features/notification/presentation/screens/notification_screen.dart';
import 'package:pantau_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:pantau_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:pantau_app/features/report/presentation/screen/report_screen.dart';
import 'package:pantau_app/features/report/presentation/screen/report_edit_screen.dart';
import 'package:pantau_app/features/work/domain/models/work_order.dart';
import 'package:pantau_app/features/work/presentation/screens/work_screen.dart';
import 'package:pantau_app/features/work_order_detail/presentation/screens/work_order_detail_screen.dart';
import 'package:pantau_app/features/work_order_edit/presentation/screens/work_order_edit_screen.dart';

Route<dynamic> routeGenerators(RouteSettings settings) {
  switch (settings.name) {
    case HomeScreen.route :
      return _buildPageRoute(const HomeScreen());
    case LoginScreen.route :
      return _buildPageRoute(const LoginScreen());   
    case WorkScreen.route :
      return _buildPageRoute(const WorkScreen());
    case CalendarScreen.route :
      return _buildPageRoute(const CalendarScreen());
    case ProfileScreen.route :
      return _buildPageRoute(const ProfileScreen());  
    case NotificationScreen.route :
      return _buildPageRoute(const NotificationScreen());  
    case EditProfileScreen.route :
      return _buildPageRoute(const EditProfileScreen());
    case CreateWorkOrderScreen.route :
      return _buildPageRoute(const CreateWorkOrderScreen());  
    case WorkOrderDetailScreen.route :
      final workOrderId = settings.arguments as String;
      return _buildPageRoute(WorkOrderDetailScreen(workOrderId: workOrderId));
    case WorkOrderEditScreen.route :
      final workOrder = settings.arguments as WorkOrder;
      return _buildPageRoute(WorkOrderEditScreen(workOrder: workOrder));
    case ReportScreen.route :
      final workOrderId = settings.arguments as String;
      return _buildPageRoute(ReportScreen(workOrderId: workOrderId));
    case EditReportScreen.route:
      final args = settings.arguments as Map<String, String>;
      final workOrderId = args['workOrderId']!;
      final reportId = args['reportId']!;
      return _buildPageRoute(
        EditReportScreen(
          workOrderId: workOrderId,
          reportId: reportId,
        ),
      );
    default:
      throw ('Route not found');
  }  
}

PageRoute _buildPageRoute(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}