import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/common/widgets/custom_app_bar.dart';
import 'package:pantau_app/common/widgets/navBar/navigation_bar.dart';
import 'package:pantau_app/core/constant/colors.dart';

class CalendarScreen extends ConsumerWidget {
  static const String route = '/calendar';

  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    
    return const Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(),
      bottomNavigationBar: NavigationBarWidget(currentIndex: 2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Calendar screen",
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}