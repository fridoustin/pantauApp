import 'package:pantau_app/features/profile/domain/repositories/profile_repository.dart';

class ChangePasswordUseCase {
  final ProfileRepository _repo;
  ChangePasswordUseCase(this._repo);

  Future<void> execute({
    required String currentPassword,
    required String newPassword,
  }) {
    return _repo.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
