import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final technicianNameProvider = FutureProvider<String>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    print("❌ User is null");
    return "Unknown";
  }

  if (user.email == null) {
    print("❌ Email is null");
    return "Unknown";
  }

  print("📨 Logged in user email: ${user.email}");

  try {
    final response = await Supabase.instance.client
        .from('technician')
        .select('name')
        .ilike('email', user.email!)
        .limit(1)
        .maybeSingle(); // Ganti dari single() supaya tidak error saat kosong
      print("🔍 Raw response: $response");

    if (response == null) {
      print("⚠️ No data found for email: ${user.email}");
      return "Unknown";
    }

    print("✅ Found technician: ${response['name']}");
    return response['name'] ?? "Unknown";
  } catch (e) {
    print("🔥 Supabase error: $e");
    return "Unknown";
  }
});
