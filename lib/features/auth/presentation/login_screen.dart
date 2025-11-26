import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/custom_button.dart';
import 'auth_controller.dart';
import '../data/user_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

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
    )..repeat(reverse: true); // ⚠️ HANYA INI YANG LOOPING

    _breathingAnim = Tween<double>(begin: 0.8, end: 1.15).animate(
      CurvedAnimation(parent: _backgroundCtrl, curve: Curves.easeInOut),
    );

    // --- SETUP KONTEN (Jalan 1 Kali Saja) ---
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Animasi Fade In (Opacity 0 -> 1)
    _fadeAnim = CurvedAnimation(
      parent: _entryCtrl, 
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );

    // Animasi Logo Pop Up (Scale 0 -> 1)
    _scaleLogoAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut),
    );

    // Jalankan animasi masuk SEKALI saja
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _backgroundCtrl.dispose();
    _entryCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(authControllerProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    
    ref.listen<AsyncValue<User?>>(authControllerProvider, (previous, next) {
      if (next is AsyncError) {
        String errorText = next.error.toString();
        if (errorText.startsWith("Exception: ")) errorText = errorText.substring(11);
        if (errorText.toLowerCase().contains("null") || errorText.isEmpty) errorText = "Login gagal.";

        AppSnackBars.show(context, errorText, isError: true);
      } else if (next is AsyncData && next.value != null) {
        AppSnackBars.show(context, "Login Berhasil", isError: false);
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- LAYER 1: BACKGROUND & LOGO ---
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // 🔵 LINGKARAN BIRU (LOOPING)
                          // Menggunakan AnimatedBuilder ke _backgroundCtrl
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
                                        color: Colors.lightBlueAccent.withValues(alpha: 0.45),
                                        blurRadius: 85,
                                        spreadRadius: 35,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // 📍 ICON LOGO (SATU KALI MUNCUL)
                          // Menggunakan ScaleTransition dari _entryCtrl
                          ScaleTransition(
                            scale: _scaleLogoAnim,
                            child: const Icon(Icons.location_on_outlined, color: Colors.white, size: 85),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      
                      // --- LAYER 2: FORM INPUT (SATU KALI MUNCUL) ---
                      // Menggunakan FadeTransition dari _entryCtrl (BUKAN _backgroundCtrl)
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Column(
                          children: [
                            const Text(
                              "Masuk Akun",
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                              child: const Text(
                                "Belum punya akun? Daftar",
                                style: TextStyle(color: Colors.white70, fontSize: 14, decoration: TextDecoration.underline),
                              ),
                            ),
                            
                            const SizedBox(height: 25),

                            CustomTextField(
                              controller: _emailController,
                              hint: 'Email',
                              prefixIcon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (val) => (val == null || val.isEmpty) ? 'Wajib diisi' : null,
                            ),
                            const SizedBox(height: 12),

                            CustomTextField(
                              controller: _passwordController,
                              hint: 'Kata Sandi',
                              prefixIcon: Icons.lock,
                              obscure: !_isPasswordVisible,
                              textInputAction: TextInputAction.done,
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              ),
                              validator: (val) => (val == null || val.isEmpty) ? 'Wajib diisi' : null,
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                                child: const Text("Lupa kata sandi?", style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline)),
                              ),
                            ),
                            const SizedBox(height: 10),

                            authState.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : CustomButton(
                                    text: 'Masuk',
                                    onPressed: _onLoginPressed,
                                    width: MediaQuery.of(context).size.width * 0.7,
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
        ),
      ),
    );
  }
}