import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/common/widgets/custom_app_bar.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/profile/presentation/providers/technician_profile_provider.dart';

class EditProfileScreen extends ConsumerWidget {
  static const route = '/edit-profile';

  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(editProfileVMProvider);
    final ctrl = ref.read(editProfileVMProvider.notifier);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Profile', showBackButton: true),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // Avatar + Edit Icon
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: vm.imageFile != null
                    ? FileImage(vm.imageFile!) as ImageProvider
                    : (vm.imageUrl != null
                        ? NetworkImage(vm.imageUrl!)
                        : null),
                ),
                GestureDetector(
                  onTap: ctrl.pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nama Input
            TextFormField(
              initialValue: vm.name,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) =>
                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                  ctrl.state = ctrl.state.copyWith(name: v),
            ),
            const SizedBox(height: 32),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        final success = await ctrl.saveChanges();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Profil berhasil diperbarui')),
                          );
                          Navigator.pop(context, true);
                        } else if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(vm.error ??
                                    'Gagal memperbarui profil')),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: vm.isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text(
                        'Simpan Perubahan',
                        style:
                            TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
