abstract class AuthDataSource {
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
}