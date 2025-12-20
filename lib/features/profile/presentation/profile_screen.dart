import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../home/presentation/main_screen.dart'; // Import MainScreen Providers
import '../../mission/presentation/mission_controller.dart'; // Import Mission Providers
import '../../reward/presentation/reward_controller.dart'; // Import Reward Providers
import '../../profile/presentation/sections/profile_main_section.dart';

// Kita tidak perlu import edit/feedback section disini karena sudah via routes

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Logic Logout Global
  Future<void> _handleLogout() async {
    try {
      await ref.read(authControllerProvider.notifier).logout();

      // ✅ RESET SEMUA STATE NAVIGASI & TAB
      ref.invalidate(bottomNavIndexProvider); // Reset Tab Bawah ke Home
      ref.invalidate(missionTabStateProvider); // Reset Tab Misi ke Default
      ref.invalidate(rewardTabStateProvider); // Reset Tab Reward ke Default
      // ref.invalidate(profileSectionProvider); // Reset Section Profile (jika perlu)
    } catch (_) {}
    if (!mounted) return;
    // Keluar dari MainScreen sepenuhnya
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(AppRoutes.loginRegis, (route) => false);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Konfirmasi Logout",
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _handleLogout();
            },
            child: const Text("Ya, Keluar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ CUKUP TAMPILKAN MENU UTAMA
    // Navigasi ke Edit/Feedback sekarang via Navigator.pushNamed (Slide Animation)
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ProfileMainSection(
        // Ganti parameter ini agar memanggil Navigator
        onChangeSection: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.profileEdit);
          } else if (index == 2) {
            Navigator.pushNamed(context, AppRoutes.feedback);
          }
        },
        onLogoutTap: _showLogoutDialog,
        onRewardTap: () {
          Navigator.pushNamed(context, AppRoutes.profileReward);
        },
      ),
    );
  }
}
