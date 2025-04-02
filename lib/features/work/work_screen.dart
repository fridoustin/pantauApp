import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/common/widgets/custom_app_bar.dart';
import 'package:pantau_app/common/widgets/layout/app_scaffold.dart';
// ignore: unused_import
import 'package:pantau_app/core/constant/colors.dart';

class WorkScreen extends ConsumerWidget {
  static const String route = '/work';

  const WorkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    
    return const AppScaffold(
      appBar: CustomAppBar(),
      currentIndex: 1,
      child: Center(
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