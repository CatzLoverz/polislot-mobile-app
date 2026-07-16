import 'package:flutter/material.dart';

/// Semua token warna diekstrak dari screen yang sudah ada.
/// JANGAN tambah warna baru di sini tanpa ada referensi di screen.
class AppColors {
  AppColors._();

  // ── Brand Blues ──────────────────────────────────────────────────────────────
  /// Biru dominan di hampir semua screen (feedback, park, profile, home, dll)
  static const Color primary = Color(0xFF1565C0);

  /// Stop akhir gradient horizontal AppBar
  static const Color primaryGradientEnd = Color(0xFF2196F3);

  /// Biru lebih gelap: verify_otp, reward dialog, mission leaderboard
  static const Color primaryDark = Color(0xFF1352C8);

  /// Biru paling gelap: splash, reset_password, app_theme lama
  static const Color primaryVariant = Color(0xFF0D47A1);

  // ── Backgrounds ──────────────────────────────────────────────────────────────
  /// Background scaffold semua tab screen
  static const Color scaffold = Color(0xFFF3F6FB);

  /// Background card / surface
  static const Color surface = Colors.white;

  // ── Text ─────────────────────────────────────────────────────────────────────
  /// Heading / judul di atas card
  static const Color textPrimary = Color(0xFF1A253A);

  /// Body / subtitle di card
  static const Color textSecondary = Color(0xFF454F63);

  /// Muted text di screen light (forgot_password, profile menu)
  static const Color textMuted = Color(0xDE000000); // Colors.black87

  // ── On-Primary (text/icon di atas gradient/bg biru) ──────────────────────────
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryMuted = Color(0xB3FFFFFF); // white70
  static const Color onPrimarySubtle = Color(0x8AFFFFFF); // white54

  // ── Status ───────────────────────────────────────────────────────────────────
  static const Color accent = Colors.lightBlueAccent; // focus border text field
  static const Color error = Colors.redAccent;
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;

  // ── Misc (dari screen spesifik) ───────────────────────────────────────────────
  /// Nav bar item non-aktif (main_screen)
  static const Color navInactive = Color(0xFF5A6BB5);

  /// Avatar / loader bg (profile_edit)
  static const Color surfaceBlue = Color(0xFFEAF3FF);

  /// Notifikasi icon bg (home)
  static const Color warningLight = Color(0xFFFFEFE0);

  // ── Gradients ─────────────────────────────────────────────────────────────────
  /// Dipakai di AppBar dan header card (horizontal)
  static const LinearGradient primaryGradientH = LinearGradient(
    colors: [primary, primaryGradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Dipakai di splash / login background (vertikal)
  static const LinearGradient primaryGradientV = LinearGradient(
    colors: [primaryVariant, primary, primaryGradientEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
