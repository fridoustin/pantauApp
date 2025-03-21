import 'package:pantau_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:pantau_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<void> signIn({required String email, required String password}) async {
    await dataSource.signIn(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await dataSource.signOut();
  }
}