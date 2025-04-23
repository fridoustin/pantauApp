import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pantau_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient client;

  ProfileRepositoryImpl(this.client);

  @override
  Future<Map<String, dynamic>?> getTechnicianProfile(String email) async {
    final response = await client
        .from('technician')
        .select()
        .eq('email', email)
        .maybeSingle();

    return response;
  }

  @override
  Future<void> updateTechnicianProfile(String email, String name, String photoUrl) async {
    await client.from('technician').update({
      'name': name,
      'photo_url': photoUrl,
    }).eq('email', email);
  }

  @override
  Future<String> uploadProfilePicture(String userId, File image) async {
    try {
      // Pastikan user sudah login
      final user = client.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      
      // Gunakan format nama file yang lebih unik dengan timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'profile_pictures/${userId}_$timestamp.jpg';
      
      // Upload file dengan opsi upsert
      await client.storage.from('profiles').upload(
        filePath,
        image,
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'image/jpeg', // Set content type yang benar
        ),
      );
      
      // Mengambil URL publik
      final imageUrl = client.storage.from('profiles').getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      rethrow;
    }
  }
}