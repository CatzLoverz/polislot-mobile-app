
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../profile/presentation/providers/profile_ui_provider.dart';
import '../../profile/presentation/sections/profile_main_section.dart';
import '../../profile/presentation/sections/profile_edit_section.dart';
import '../../profile/presentation/sections/profile_feedback_section.dart';
import '../../profile/presentation/sections/profile_reward_section.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  
  // ❌ HAPUS: int _sectionIndex = 0; (Diganti Provider)

  void _changeSection(int index) {
    // ✅ GANTI JADI: Update Provider
    ref.read(profileSectionProvider.notifier).setSection(index);
  }

  // ... (Method _handleLogout & _showLogoutDialog SAMA SEPERTI SEBELUMNYA, tidak berubah)
  Future<void> _handleLogout() async {
    try {
      await ref.read(authControllerProvider.notifier).logout();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(AppRoutes.loginRegis, (route) => false);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout", style: TextStyle(color: Color(0xFF1565C0))),
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
    // ✅ WATCH PROVIDER: Agar UI berubah saat section diganti dari luar
    final sectionIndex = ref.watch(profileSectionProvider);

    Widget body;
    switch (sectionIndex) {
      case 1:
        body = ProfileEditSection(onCancel: () => _changeSection(0));
        break;
      case 2:
        body = ProfileFeedbackSection(onCancel: () => _changeSection(0));
        break;
      default:
        body = ProfileMainSection(
          onChangeSection: _changeSection,
          onLogoutTap: _showLogoutDialog,
          onRewardTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const ProfileRewardSection())
              );
          },
        );
    }

    // ❌ HAPUS PopScope DARI SINI. 
    // Kita serahkan urusan Back Button sepenuhnya ke MainScreen.
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        flexibleSpace: sectionIndex != 0
            ? Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF2196F3)])))
            : null,
        backgroundColor: sectionIndex == 0 ? Colors.white : null,
        elevation: 2,
        centerTitle: true,
        leading: sectionIndex != 0
            ? IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => _changeSection(0))
            : null,
        title: Text(
          sectionIndex == 0 ? 'Profil' : sectionIndex == 1 ? 'Ubah Profil' : 'Masukan Pengguna',
          style: TextStyle(color: sectionIndex == 0 ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: body,
    );
  }
}