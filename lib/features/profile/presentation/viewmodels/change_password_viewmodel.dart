import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:pantau_app/features/profile/presentation/providers/technician_profile_provider.dart';

class ChangePasswordState {
  final String currentPwd;
  final String newPwd;
  final String confirmPwd;
  final bool isLoading;
  final String? error;

  ChangePasswordState({
    this.currentPwd = '',
    this.newPwd = '',
    this.confirmPwd = '',
    this.isLoading = false,
    this.error,
  });

  ChangePasswordState copyWith({
    String? currentPwd,
    String? newPwd,
    String? confirmPwd,
    bool? isLoading,
    String? error,
  }) {
    return ChangePasswordState(
      currentPwd: currentPwd ?? this.currentPwd,
      newPwd: newPwd ?? this.newPwd,
      confirmPwd: confirmPwd ?? this.confirmPwd,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final changePwdVMProvider = StateNotifierProvider<
    ChangePasswordViewModel, ChangePasswordState>(
  (ref) {
    final repo = ref.watch(profileRepositoryProvider);
    return ChangePasswordViewModel(ChangePasswordUseCase(repo));
  },
);

class ChangePasswordViewModel extends StateNotifier<ChangePasswordState> {
  final ChangePasswordUseCase _usecase;

  ChangePasswordViewModel(this._usecase) : super(ChangePasswordState());

  void setCurrentPwd(String v) =>
      state = state.copyWith(currentPwd: v, error: null);
  void setNewPwd(String v) =>
      state = state.copyWith(newPwd: v, error: null);
  void setConfirmPwd(String v) =>
      state = state.copyWith(confirmPwd: v, error: null);

  Future<bool> submit() async {
    if (state.newPwd != state.confirmPwd) {
      state = state.copyWith(error: 'Password baru tidak cocok');
      return false;
    }
    if (state.newPwd.length < 6) {
      state = state.copyWith(error: 'Password minimal 6 karakter');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _usecase.execute(
        currentPassword: state.currentPwd,
        newPassword: state.newPwd,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
