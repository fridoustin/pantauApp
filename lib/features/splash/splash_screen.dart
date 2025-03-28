import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pantau_app/features/home/presentation/screens/home_screen.dart';
import 'package:pantau_app/features/auth/presentation/screens/login_screen.dart';
import 'package:pantau_app/core/constant/colors.dart';

final authStreamProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStreamProvider, (previous, next) {
      next.whenData((authState) {
        final session = authState.session;
        if (session != null) {
          Navigator.pushReplacementNamed(context, HomeScreen.route);
        } else {
          Navigator.pushReplacementNamed(context, LoginScreen.route);
        }
      });
    });

    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Pantau',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
