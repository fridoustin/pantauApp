import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/common/widgets/navBar/navigation_bar.dart';
import 'package:pantau_app/core/constant/colors.dart';
// import 'package:pantau_app/features/auth/presentation/providers/auth_providers.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';


class HomeScreen extends ConsumerWidget {
  static const String route = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    // final user = Supabase.instance.client.auth.currentUser;
    // final email = user?.email ?? "Unknown";
    
    return const Scaffold(
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: NavigationBarWidget(currentIndex: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "home screen",
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