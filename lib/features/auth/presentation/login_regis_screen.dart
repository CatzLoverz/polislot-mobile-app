import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';

class LoginRegisScreen extends StatefulWidget {
  const LoginRegisScreen({super.key});

  @override
  State<LoginRegisScreen> createState() => _LoginRegisScreenState();
}

class _LoginRegisScreenState extends State<LoginRegisScreen> with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final AnimationController _glowCtrl;

  // Animation Variables
  late final Animation<double> _scaleLogo; // 🆕 Ganti Fade jadi Scale
  late final Animation<double> _fadeSub;
  late final Animation<double> _fadeButtons;
  late final Animation<Offset> _slideSub;
  late final Animation<double> _pulseAnimation; 

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Animasi Denyut (Pulse)
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.15).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    // --- Sequence ---
    
    // 1. LOGO: Scale 0 -> 1 (Zoom In). JANGAN PAKAI FADE.
    _scaleLogo = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // 2. Subtitle: Fade & Slide (Teks aman di-fade)
    _fadeSub = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
    );

    _slideSub = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 0.75, curve: Curves.easeOutBack),
      ),
    );

    // 3. Buttons: Fade (Button aman di-fade)
    _fadeButtons = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✨ GLOW & LOGO AREA (FIXED: Hapus FadeTransition)
                  AnimatedBuilder(
                    animation: _glowCtrl,
                    builder: (context, _) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          ScaleTransition(
                            scale: _scaleLogo,
                            child: Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.lightBlueAccent.withValues(alpha: 0.5),
                                      blurRadius: 80,
                                      spreadRadius: 35,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // ICON LOGO
                          ScaleTransition(
                            scale: _scaleLogo, // Animasi Muncul (Zoom In)
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                              size: 85,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ✨ Teks Utama (Slide & Fade aman untuk teks)
                  SlideTransition(
                    position: _slideSub,
                    child: FadeTransition(
                      opacity: _fadeSub,
                      child: const Text(
                        "Dimana Slot Parkir Kosong?",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  
                  FadeTransition(
                    opacity: _fadeSub,
                    child: const Text(
                      "Masuk atau daftarkan akunmu",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.06),

                  // 🟩 Tombol Navigasi
                  FadeTransition(
                    opacity: _fadeButtons,
                    child: Column(
                      children: [
                        CustomButton(
                          text: 'Masuk',
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                          width: size.width * 0.72,
                          height: 48,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "atau",
                          style: TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 10),
                        CustomButton(
                          text: 'Daftar',
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                          outlined: true,
                          width: size.width * 0.72,
                          height: 48,
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