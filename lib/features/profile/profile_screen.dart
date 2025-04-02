import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/common/widgets/custom_app_bar.dart';
import 'package:pantau_app/common/widgets/layout/app_scaffold.dart';
// ignore: unused_import
import 'package:pantau_app/core/constant/colors.dart';

class ProfileScreen extends ConsumerWidget {
  static const String route = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    
    return const AppScaffold(
      appBar: CustomAppBar(),
      currentIndex: 3,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Profile screen",
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