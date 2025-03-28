// DataSource Provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:pantau_app/features/auth/data/datasources/supabase_auth_data_source.dart';
import 'package:pantau_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pantau_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:pantau_app/features/auth/domain/usecases/signin_usecase.dart';
import 'package:pantau_app/features/auth/domain/usecases/signout_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return SupabaseAuthDataSource(client: Supabase.instance.client);
});

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

// UseCase Provider for signin
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInUseCase(repository);
});

// UseCase Provider for signout
final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final signInUseCase = ref.watch(signInUseCaseProvider);
  final signOutUseCase = ref.watch(signOutUseCaseProvider);
  return AuthNotifier(signInUseCase, signOutUseCase);
});

// Auth State
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  AuthState({
    this.isLoading = false, 
    this.errorMessage, 
    this.isAuthenticated = false
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,  // Set to null if not provided
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;

  AuthNotifier(this._signInUseCase, this._signOutUseCase) : super(AuthState());

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _signInUseCase.execute(email: email, password: password);
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: e.toString(),
        isAuthenticated: false
      );
    }
  }

  Future<void> signOut() async {
    await _signOutUseCase.execute();
    state = AuthState(); // reset state
  }
}