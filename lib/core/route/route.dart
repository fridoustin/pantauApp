import 'package:flutter/material.dart';
import 'package:pantau_app/features/auth/presentation/screens/login_screen.dart';
import 'package:pantau_app/features/calendar/calendar_screen.dart';
import 'package:pantau_app/features/home/presentation/screens/home_screen.dart';
import 'package:pantau_app/features/profile/profile_screen.dart';
import 'package:pantau_app/features/work/work_screen.dart';

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