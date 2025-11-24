import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/routes/app_routes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _shimmerController;
  late AnimationController _glowPulseController;

  late Animation<double> _fadeLogo;
  late Animation<double> _scaleLogo;
  late Animation<Offset> _slideText;
  late Animation<double> _fadeText;
  late Animation<double> _fadeSubtitle;
  late Animation<double> _pulseScaleAnim;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _glowPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseScaleAnim = Tween<double>(begin: 0.8, end: 1.15).animate(
      CurvedAnimation(parent: _glowPulseController, curve: Curves.easeInOut),
    );

    _fadeLogo = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    _scaleLogo = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
      ),
    );

    _fadeText = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.45, 0.75, curve: Curves.easeIn),
    );

    _slideText = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.45, 0.75, curve: Curves.easeOutBack),
      ),
    );

    _fadeSubtitle = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
    );

    _mainController.addListener(() {
      if (_mainController.value > 0.45 && !_shimmerController.isAnimating) {
        _shimmerController.repeat();
      }
    });

    _mainController.forward();
    _startApp();
  }

  Future<void> _startApp() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.loginRegis);
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _shimmerController.dispose();
    _glowPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _glowPulseController,
        builder: (context, _) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0D47A1),
                  Color.lerp(
                    const Color(0xFF1976D2),
                    const Color(0xFF42A5F5),
                    _glowPulseController.value,
                  )!,
                  const Color(0xFF64B5F6),
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.38,
                  child: AnimatedBuilder(
                    animation: _fadeLogo,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseScaleAnim.value,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.lightBlueAccent.withValues(
                                  alpha: (0.5 * _fadeLogo.value).clamp(0.0, 1.0),
                                ),
                                blurRadius: 90,
                                spreadRadius: 40,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fadeLogo,
                      child: ScaleTransition(
                        scale: _scaleLogo,
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white,
                          size: 85,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // ✨ TEKS "PoliSlot" (FIXED: Menggunakan LayoutBuilder)
                    SlideTransition(
                      position: _slideText,
                      child: FadeTransition(
                        opacity: _fadeText,
                        child: AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return _GradientText(
                              text: "PoliSlot",
                              shimmerValue: _shimmerController.value,
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.4,
                                fontFamily: 'Roboto',
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    FadeTransition(
                      opacity: _fadeSubtitle,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Cari Slot Parkirmu di Politeknik Negeri Batam",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =========================================================
// 🛠️ CUSTOM WIDGET: GRADIENT TEXT (FIXED)
// =========================================================
class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double shimmerValue;

  const _GradientText({
    required this.text,
    required this.style,
    required this.shimmerValue,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 SOLUSI LAYAR MERAH: Gunakan LayoutBuilder
    // LayoutBuilder memberikan kita 'constraints' (ukuran yang tersedia)
    // sebelum widget digambar, jadi kita bisa membuat shader dengan aman.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Kita hitung perkiraan lebar teks atau gunakan maxWidth
        final estimatedWidth = constraints.maxWidth > 300 ? 300.0 : constraints.maxWidth;
        
        return Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..shader = _createShimmerShader(Size(estimatedWidth, 50)),
          ),
        );
      },
    );
  }

  Shader _createShimmerShader(Size size) {
    const gradient = LinearGradient(
      colors: [
        Colors.white,
        Colors.cyanAccent,
        Colors.white,
      ],
      stops: [0.0, 0.5, 1.0],
      tileMode: TileMode.clamp,
    );

    final shift = (shimmerValue * 2.5) - 1.0; 
    final double xPos = shift * (size.width + 100); 

    return gradient.createShader(
      Rect.fromLTWH(xPos, 0, size.width, size.height),
    );
  }
}