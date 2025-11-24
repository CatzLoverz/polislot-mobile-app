import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/auth_controller.dart';


class ProfileMainSection extends ConsumerStatefulWidget {
  final Function(int) onChangeSection;
  final VoidCallback onLogoutTap;
  final VoidCallback onRewardTap; // ✅ Callback wajib untuk navigasi Reward

  const ProfileMainSection({
    super.key,
    required this.onChangeSection,
    required this.onLogoutTap,
    required this.onRewardTap,
  });

  @override
  ConsumerState<ProfileMainSection> createState() => _ProfileMainSectionState();
}

class _ProfileMainSectionState extends ConsumerState<ProfileMainSection> with TickerProviderStateMixin {
  late final AnimationController _menuAnimCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _menuAnimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _fadeAnims = List.generate(4, (i) {
      final start = i * 0.15;
      final end = start + 0.5;
      return CurvedAnimation(
        parent: _menuAnimCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _slideAnims = List.generate(4, (i) {
      final start = i * 0.15;
      final end = start + 0.5;
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _menuAnimCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    _menuAnimCtrl.forward();
  }

  @override
  void dispose() {
    _menuAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    // Loading state jika data user belum siap
    if (authState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)));
    }

    // ✅ DAFTAR MENU
    // Pastikan urutan parameter _menuButton benar: (Text, Icon, Color, Callback)
    final menuItems = [
      ("Ubah Profil", Icons.edit, Colors.blue, () => widget.onChangeSection(1)),
      ("Riwayat Penukaran", Icons.card_giftcard, Colors.green, widget.onRewardTap), // 👈 Pastikan ini memanggil widget.onRewardTap
      ("Masukan Pengguna", Icons.feedback_outlined, Colors.orange, () => widget.onChangeSection(2)),
      ("Keluar Akun", Icons.logout, Colors.redAccent, widget.onLogoutTap),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // HEADER CARD (INFO USER)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF2196F3)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  // Menggunakan helper fullAvatarUrl dari Model User
                  backgroundImage: (user?.fullAvatarUrl.isNotEmpty ?? false) 
                      ? NetworkImage(user!.fullAvatarUrl) 
                      : null,
                  child: (user?.fullAvatarUrl.isEmpty ?? true) 
                      ? const Icon(Icons.person, size: 40, color: Colors.white) 
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? "Tamu", 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? "-", 
                        style: const TextStyle(color: Colors.white70)
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          
          // RENDER MENU BUTTONS
          ...List.generate(menuItems.length, (i) {
            final m = menuItems[i];
            return FadeTransition(
              opacity: _fadeAnims[i],
              child: SlideTransition(
                position: _slideAnims[i],
                // Panggil fungsi _menuButton dengan urutan yang benar
                child: _menuButton(m.$1, m.$2, m.$3, m.$4),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Helper Widget untuk tombol menu
  Widget _menuButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12), 
                borderRadius: BorderRadius.circular(10)
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16, 
                  color: Colors.black87, 
                  fontWeight: FontWeight.w500
                )
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.black45, size: 18),
          ],
        ),
      ),
    );
  }
}