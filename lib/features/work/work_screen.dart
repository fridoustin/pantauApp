import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/common/widgets/navBar/navigation_bar.dart';
import 'package:pantau_app/core/constant/colors.dart';

class WorkScreen extends ConsumerWidget {
  static const String route = '/work';

  const WorkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    
    return const Scaffold(
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: NavigationBarWidget(currentIndex: 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Work screen",
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