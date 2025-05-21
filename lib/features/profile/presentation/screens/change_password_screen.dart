import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/common/widgets/custom_app_bar.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/profile/presentation/viewmodels/change_password_viewmodel.dart';

class ChangePasswordScreen extends ConsumerWidget {
  static const route = '/changepassword';

  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(changePwdVMProvider);
    final ctrl = ref.read(changePwdVMProvider.notifier);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Change Password', showBackButton: true),
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Lama',
                border: OutlineInputBorder(),
              ),
              onChanged: ctrl.setCurrentPwd,
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(),
              ),
              onChanged: ctrl.setNewPwd,
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password Baru',
                border: OutlineInputBorder(),
              ),
              onChanged: ctrl.setConfirmPwd,
            ),
            if (vm.error != null) ...[
              const SizedBox(height: 16),
              Text(vm.error!, style: const TextStyle(color: Colors.red)),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        final ok = await ctrl.submit();
                        if (ok && context.mounted) {
                          // 2) tampilkan pop-up sukses:
                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: AppColors.backgroundColor,
                              title: const Text('Berhasil'),
                              content: const Text('Password berhasil diubah'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // close dialog
                                  },
                                  child: const Text('OK', style: TextStyle(color: Colors.black),),
                                ),
                              ],
                            ),
                          );
                          // setelah dialog ditutup, kembali ke screen sebelumnya
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        }
                      },
                child: vm.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Ubah Password',style:
                            TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}