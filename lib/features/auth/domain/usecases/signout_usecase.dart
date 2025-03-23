import 'package:pantau_app/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> execute() async {
    return await repository.signOut();
  }
}
