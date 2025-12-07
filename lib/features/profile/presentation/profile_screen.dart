import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/presentation/auth_controller.dart';
// import '../../profile/presentation/providers/profile_ui_provider.dart';
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
    } catch (_) {}
    if (!mounted) return;
    // Keluar dari MainScreen sepenuhnya
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(AppRoutes.loginRegis, (route) => false);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout", style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
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