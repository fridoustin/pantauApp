import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class HomeScreen extends ConsumerWidget {
  static const String route = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? "Unknown";
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "home screen",
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            Text(
              "Email: $email",
            ),
            OutlinedButton(
              onPressed: () async {
                final authNotifier = ref.read(authStateProvider.notifier);
                await authNotifier.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              }, 
              child: const Icon(Icons.logout)
            )
          ],
        ),
      ),
    );
  }
}