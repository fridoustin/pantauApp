import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau_app/common/widgets/custom_app_bar.dart';
import 'package:pantau_app/common/widgets/layout/app_scaffold.dart';
import 'package:pantau_app/core/constant/colors.dart';
import 'package:pantau_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:pantau_app/features/profile/presentation/providers/technician_profile_provider.dart';
import 'package:pantau_app/features/profile/presentation/widget/profile_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  static const String route = '/profile';

  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh data profil saat layar dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(technicianProfileProvider);
    });
  }

  @override
  Widget build(BuildContext context) { 
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? "Unknown";
    final profileData = ref.watch(technicianProfileProvider);

    return AppScaffold(
      appBar: const CustomAppBar(title: 'Profile'),
      currentIndex: 3,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RefreshIndicator(
                onRefresh: () async {
                  // Refresh data saat user menarik layar ke bawah
                  ref.invalidate(technicianProfileProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Profile avatar
                      profileData.when(
                        data: (data) {
                          final photoUrl = data?['photo_url'] as String?;
                          return Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                              image: photoUrl != null && photoUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(photoUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: photoUrl == null || photoUrl.isEmpty
                                ? const Icon(Icons.person, size: 100, color: Colors.grey)
                                : null,
                          );
                        },
                        loading: () => Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (e, _) => Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.error, color: Colors.red, size: 60),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Name
                      profileData.when(
                        data: (data) => Text(
                          data?['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) => const Text(
                          'Gagal memuat nama',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Email
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Stats row
                      Row(
                        children: [
                          // Completed works
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primaryColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Selesai :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        '12',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          'wo',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Pending works
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                border: Border.all(color:AppColors.primaryColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Pending/Belum :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        '12',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          'wo',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Profile options
                      ProfileOption(
                        icon: 'assets/icons/edit.svg',
                        label: 'Edit Profile',
                        onTap: () async {
                          // Navigasi dengan menunggu hasil
                          final result = await Navigator.pushNamed(context, '/edit-profile');
                          if (result == true) {
                            // Profile telah diupdate, refresh data
                            ref.invalidate(technicianProfileProvider);
                          }
                        },
                      ),
                      const Divider(),
                      const ProfileOption(
                        icon: 'assets/icons/lock.svg',
                        label: 'Change Password',
                      ),
                      const Divider(),
                      const ProfileOption(
                        icon: 'assets/icons/settings.svg',
                        label: 'Settings',
                      ),
                      const SizedBox(height: 40),
                      // Logout button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () async {
                            final authNotifier = ref.read(authStateProvider.notifier);
                            await authNotifier.signOut();
                            // ignore: use_build_context_synchronously
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}