import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/auth/login.dart';
import 'package:pantau_app/route.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jmwzmwbcoawasvxtiwav.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imptd3ptd2Jjb2F3YXN2eHRpd2F2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE3Njg4NTgsImV4cCI6MjA1NzM0NDg1OH0.8EajRgpvhO3Bgbvs63Og5_k-v3QacUQDLXl0FudxeH8',
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      onGenerateRoute: routeGenerators,
    );
  }
}