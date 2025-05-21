import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pantau_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:pantau_app/features/profile/domain/usecases/update_profile_usecase.dart';

/// State holder untuk Edit Profile
class EditProfileState {
  final String name;
  final File? imageFile;
  final String? imageUrl;
  final bool isLoading;
  final String? error;

  EditProfileState({
    this.name = '',
    this.imageFile,
    this.imageUrl,
    this.isLoading = false,
    this.error,
  });

  EditProfileState copyWith({
    String? name,
    File? imageFile,
    String? imageUrl,
    bool? isLoading,
    String? error,
  }) {
    return EditProfileState(
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      imageFile: imageFile ?? this.imageFile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EditProfileViewModel extends StateNotifier<EditProfileState> {
  final ProfileRepository _repo;
  final ImagePicker _picker = ImagePicker();

  EditProfileViewModel(this._repo) : super(EditProfileState()) {
    _loadInitialProfile();
  }

  Future<void> _loadInitialProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final data = await _repo.getTechnicianProfile(user.email!);
    // misalnya field foto di response bernama 'photo_url'
    final url = data?['photo_url'] as String?;
    state = state.copyWith(
      name: data?['name'] ?? '',
      imageUrl: url,
    );
  }

  Future<void> pickImage() async {
    final result = await _picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      state = state.copyWith(imageFile: File(result.path));
    }
  }

  Future<bool> saveChanges() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || state.imageFile == null || state.name.trim().isEmpty) {
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await UpdateProfileUseCase(_repo).execute(
        email: user.email!,
        name: state.name.trim(),
        image: state.imageFile!,
        userId: user.id,
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