import 'package:flutter/material.dart';

import '../enums/otp_type.dart';

// Import Screen
import '../../core/wrapper/connectivity_wrapper.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/splash/presentation/privacy_policy_screen.dart';
import '../../features/auth/presentation/login_regis_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/verify_otp_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/home/presentation/main_screen.dart';
import '../../features/profile/presentation/sections/profile_edit_section.dart';
import '../../features/feedback/presentation/feedback_screen.dart';
import '../../features/profile/presentation/sections/profile_reward_section.dart';

class AppRoutes {
  // ===========================================================================
  // 📍 DAFTAR NAMA ROUTE
  // ===========================================================================
  static const String splash = '/';
  static const String privacyPolicy = '/privacyPolicy';
  static const String loginRegis =
      '/loginRegis'; // Halaman Pilihan (Masuk/Daftar)
  static const String login = '/login';
  static const String register = '/register';

  // Route OTP (Reusable untuk Register & Forgot Password)
  static const String verifyOtp = '/verifyOtp';

  // Forgot Password
  static const String forgotPassword = '/forgotPassword';
  static const String resetPassword = '/resetPassword';

  static const String main = '/main'; // Home / Dashboard

  static const String profileEdit = '/profile/edit';
  static const String feedback = '/feedback';
  static const String profileReward = '/profile/reward';

  // ===========================================================================
  // 🚦 ROUTE GENERATOR
  // ===========================================================================
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // --- SPLASH ---
      case splash:
        return _materialRoute(const SplashScreen());

      case privacyPolicy:
        return _materialRoute(const PrivacyPolicyScreen());

      // --- PILIHAN AUTH ---
      case loginRegis:
        return _slideRoute(const LoginRegisScreen());

      // --- LOGIN ---
      case login:
        return _slideRoute(const LoginScreen());

      // --- REGISTER ---
      case register:
        return _slideRoute(const RegisterScreen());

      // --- VERIFY OTP (Reusable) ---
      case verifyOtp:
        // Ambil argument yang dikirim dari RegisterScreen atau ForgotPasswordScreen
        final args = settings.arguments as Map<String, dynamic>?;

        return _slideRoute(
          VerifyOtpScreen(
            email: args?['email'],
            // Default ke register jika tidak ada tipe yang dikirim
            otpType: args?['type'] ?? OtpType.register,
          ),
        );

      // --- FORGOT PASSWORD ---
      case forgotPassword:
        return _slideRoute(const ForgotPasswordScreen());

      // --- RESET PASSWORD ---
      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        // Nanti bisa kirim email/token ke sini
        return _slideRoute(ResetPasswordScreen(email: args?['email']));

      // --- MAIN / HOME ---
      case main:
        return _materialRoute(
          const AppConnectivityWrapper(child: MainScreen()),
        );

      case profileEdit:
        return _slideRoute(const ProfileEditSection());
      case feedback:
        return _slideRoute(const FeedbackScreen());
      case profileReward:
        return _slideRoute(const ProfileRewardSection());

      // --- DEFAULT / 404 ---
      default:
        return _materialRoute(
          Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(
              child: Text('Route tidak ditemukan: ${settings.name}'),
            ),
          ),
        );
    }
  }

  // ===========================================================================
  // 🛠️ HELPER METHODS (TRANSISI)
  // ===========================================================================

  // Transisi Standar (Material / Fade halus)
  static MaterialPageRoute _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }

  // Transisi Slide (Kanan ke Kiri)
  static PageRouteBuilder _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Muncul dari kanan
        const end = Offset.zero;
        const curve = Curves.easeOutQuart; // Kurva halus

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  // Halaman Sementara untuk fitur yang belum jadi
  // static Widget _buildPlaceholder(String title) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(title, style: const TextStyle(color: Colors.white)),
  //       backgroundColor: const Color(0xFF1565C0),
  //       iconTheme: const IconThemeData(color: Colors.white),
  //     ),
  //     body: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           const Icon(Icons.construction, size: 80, color: Colors.grey),
  //           const SizedBox(height: 20),
  //           Text(
  //             "$title\n(Sedang dalam pengembangan)",
  //             textAlign: TextAlign.center,
  //             style: const TextStyle(fontSize: 16, color: Colors.grey),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
