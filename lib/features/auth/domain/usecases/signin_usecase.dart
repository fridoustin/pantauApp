import 'package:pantau_app/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<void> execute({required String email, required String password}) async {
    return await repository.signIn(email: email, password: password);
  }
}