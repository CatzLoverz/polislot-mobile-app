import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:polislot_mobile_catz/core/utils/snackbar_utils.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/enums/otp_type.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // 1️⃣ CONTROLLER KHUSUS BACKGROUND (LOOPING)
  late final AnimationController _backgroundCtrl;
  late final Animation<double> _breathingAnim;

  // 2️⃣ CONTROLLER KHUSUS KONTEN (SEKALI JALAN / ONE-SHOT)
  late final AnimationController _entryCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleLogoAnim;

  @override
  void initState() {
    super.initState();

    // --- SETUP BACKGROUND (Berdenyut Terus) ---
    _backgroundCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _breathingAnim = Tween<double>(begin: 0.8, end: 1.15).animate(
      CurvedAnimation(parent: _backgroundCtrl, curve: Curves.easeInOut),
    );

    // --- SETUP KONTEN (Jalan 1 Kali Saja) ---
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Animasi Fade In Form (Opacity 0 -> 1)
    _fadeAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );

    // Animasi Logo Pop Up (Scale 0 -> 1)
    _scaleLogoAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut));

    // Jalankan animasi masuk
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _backgroundCtrl.dispose();
    _entryCtrl.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      AppSnackBars.show(context, "Semua kolom wajib diisi", isError: true);
      return;
    }

    // 1️⃣ Validasi Email (Regex)
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      AppSnackBars.show(
        context,
        "Format email tidak valid",
        isError: true,
      );
      return;
    }

    // 2️⃣ Validasi Password (Client Side - Comprehensive)
    final pass = _passwordController.text;
    final hasMinLength = pass.length >= 8;
    final hasUppercase = pass.contains(RegExp(r'[A-Z]'));
    final hasLowercase = pass.contains(RegExp(r'[a-z]'));
    final hasNumber = pass.contains(RegExp(r'[0-9]'));
    final hasSymbol = pass.contains(RegExp(r'[^a-zA-Z0-9]'));

    if (!hasMinLength ||
        !hasUppercase ||
        !hasLowercase ||
        !hasNumber ||
        !hasSymbol) {
      AppSnackBars.show(
        context,
        "Password harus memiliki minimal 8 karakter, huruf besar, huruf kecil, angka, dan simbol.",
        isError: true,
      );
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      AppSnackBars.show(
        context,
        "Konfirmasi password tidak cocok",
        isError: true,
      );
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmController.text,
        );

    // ✅ FIX ASYNC GAP: Cek mounted sebelum pakai context
    if (!mounted) return;

    if (success) {
      AppSnackBars.show(
        context,
        "Pendaftaran Berhasil! Cek email Anda untuk kode OTP.",
      );

      Navigator.pushNamed(
        context,
        AppRoutes.verifyOtp,
        arguments: {
          'email': _emailController.text.trim(),
          'type': OtpType.register,
        },
      );
    } else {
      final state = ref.read(authControllerProvider);
      if (state.hasError) {
        String msg = state.error.toString().replaceAll('Exception: ', '');
        AppSnackBars.show(context, msg, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30, 20, 30, 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- LAYER 1: BACKGROUND & LOGO ---
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // 🔵 LINGKARAN BIRU (LOOPING)
                      AnimatedBuilder(
                        animation: _backgroundCtrl,
                        builder: (context, _) {
                          return Transform.scale(
                            scale: _breathingAnim.value,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.lightBlueAccent.withValues(
                                      alpha: 0.45,
                                    ),
                                    blurRadius: 85,
                                    spreadRadius: 35,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // 📍 ICON PIN LOGO (POP UP)
                      // Menggunakan ScaleTransition dari _entryCtrl (Bukan _backgroundCtrl)
                      ScaleTransition(
                        scale: _scaleLogoAnim,
                        child: const Icon(
                          Icons
                              .location_on_outlined, // ✅ ICON PIN SESUAI PERMINTAAN
                          color: Colors.white,
                          size: 85,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- LAYER 2: FORM INPUT (FADE IN) ---
                  // FadeTransition menggunakan _entryCtrl (Sekali jalan)
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        const Text(
                          "Daftarkan Akun Baru",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Input Nama
                        CustomTextField(
                          hint: 'Nama Lengkap',
                          prefixIcon: Icons.person, // ✅ Pakai prefixIcon
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        // Input Email
                        CustomTextField(
                          hint: 'Email',
                          prefixIcon: Icons.email, // ✅ Pakai prefixIcon
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        // Input Password
                        CustomTextField(
                          hint: 'Kata Sandi',
                          prefixIcon: Icons.lock, // ✅ Pakai prefixIcon
                          obscure: true,
                          controller: _passwordController,
                          textInputAction: TextInputAction.next,
                        ),

                        // Helper Text
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                              children: const [
                                TextSpan(
                                  text: '* ',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      'Min. 8 karakter, mengandung huruf besar/kecil, angka dan simbol.',
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Konfirmasi Password
                        CustomTextField(
                          hint: 'Konfirmasi Kata Sandi',
                          prefixIcon: Icons.lock_outline, // ✅ Pakai prefixIcon
                          obscure: true,
                          controller: _confirmController,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 25),

                        // Button Daftar
                        isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : CustomButton(
                                text: 'Daftar',
                                onPressed: _registerUser,
                                width: double.infinity,
                              ),

                        const SizedBox(height: 15),

                        // Link Login
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.login),
                          child: const Text(
                            "Sudah punya akun? Masuk",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
