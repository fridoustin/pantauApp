import 'dart:io';

abstract class ProfileRepository {
  Future<Map<String, dynamic>?> getTechnicianProfile(String email);
  Future<void> updateTechnicianProfile(String email, String name, String photoUrl);
  Future<String> uploadProfilePicture(String userId, File image);
}
