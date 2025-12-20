import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/presentation/auth_controller.dart';

class PrivacyPolicyScreen extends ConsumerStatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  ConsumerState<PrivacyPolicyScreen> createState() =>
      _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends ConsumerState<PrivacyPolicyScreen>
    with TickerProviderStateMixin {
  // 1️⃣ CONTROLLER KHUSUS BACKGROUND (LOOPING) - Same as Login/Register
  late final AnimationController _backgroundCtrl;
  late final Animation<double> _breathingAnim;

  // 2️⃣ CONTROLLER KHUSUS KONTEN (SEKALI JALAN)
  late final AnimationController _entryCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleLogoAnim;

  @override
  void initState() {
    super.initState();

    // --- SETUP BACKGROUND (Breating Animation) ---
    _backgroundCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _breathingAnim = Tween<double>(begin: 0.8, end: 1.15).animate(
      CurvedAnimation(parent: _backgroundCtrl, curve: Curves.easeInOut),
    );

    // --- SETUP KONTEN ---
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );

    _scaleLogoAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut));

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _backgroundCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _onAccept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_privacy_policy', true);

    if (!mounted) return;

    // Check auth status to decide next screen
    final isLoggedIn = await ref
        .read(authControllerProvider.notifier)
        .checkStartupSession();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.loginRegis);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // --- LAYER 1: BACKGROUND & LOGO (Looping) ---
              Positioned(
                top: -50,
                right: -50,
                child: AnimatedBuilder(
                  animation: _backgroundCtrl,
                  builder: (context, _) {
                    return Transform.scale(
                      scale: _breathingAnim.value,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.lightBlueAccent.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 100,
                              spreadRadius: 40,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // --- LAYER 2: CONTENT ---
              FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Header with Icon
                      Center(
                        child: Column(
                          children: [
                            ScaleTransition(
                              scale: _scaleLogoAnim,
                              child: const Icon(
                                Icons.privacy_tip_outlined,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Kebijakan Privasi & Ketentuan",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Scrollable Content
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Selamat datang di PoliSlot Mobile",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Dengan menggunakan aplikasi ini, Anda menyetujui ketentuan berikut:\n",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                _buildSection(
                                  "1. Privasi Data",
                                  "Kami menjaga kerahasiaan data pribadi Anda sesuai dengan peraturan yang berlaku.",
                                ),
                                _buildSection(
                                  "2. Penggunaan Aplikasi",
                                  "Aplikasi ini digunakan untuk memantau ketersediaan slot parkir di lingkungan Politeknik Negeri Batam.",
                                ),
                                _buildSection(
                                  "3. Validasi Area",
                                  "Fitur validasi area digunakan untuk membantu pengguna lain mengetahui kondisi terkini. Harap gunakan dengan bijak dan jujur.",
                                ),
                                _buildSection(
                                  "4. Lokasi",
                                  "Aplikasi mungkin memerlukan akses ke lokasi Anda untuk fitur-fitur tertentu.",
                                ),
                                _buildSection(
                                  "5. Perubahan Ketentuan",
                                  "Kami berhak mengubah ketentuan ini sewaktu-waktu dengan pemberitahuan.",
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Harap baca dengan seksama sebelum melanjutkan.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: "Saya Setuju & Lanjutkan",
                          onPressed: _onAccept,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
            fontFamily: 'Roboto',
          ),
          children: [
            TextSpan(
              text: "$title: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }
}
