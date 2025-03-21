import 'package:flutter/material.dart';
import 'package:pantau_app/features/auth/presentation/screens/login_screen.dart';
import 'package:pantau_app/features/home/home.dart';

Route<dynamic> routeGenerators(RouteSettings settings) {
  switch (settings.name) {
    case HomePage.route :
      return _buildPageRoute(const HomePage());
    case LoginScreen.route :
      return _buildPageRoute(const LoginScreen());   
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