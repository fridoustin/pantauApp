import 'package:flutter/material.dart';
import 'package:pantau_app/core/constant/colors.dart';


class HomePage extends StatelessWidget {
  static const String route = '/home';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) { 
    return const Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Text(
          "home screen",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}