import 'dart:io';
import 'package:pantau_app/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<void> execute({
    required String email,
    required String name,
    required File image,
    required String userId,
  }) async {
    final imageUrl = await repository.uploadProfilePicture(userId, image);
    await repository.updateTechnicianProfile(email, name, imageUrl);
  }
}
