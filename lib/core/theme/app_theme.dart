// File: lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor agar class ini tidak bisa di-instansiasi
  AppTheme._();

  // 🎨 PALET WARNA (Definisi warna statis)
  static const Color primaryColor = Color(0xFF1976D2);    // Biru Utama (dari main.dart lama)
  static const Color secondaryColor = Color(0xFF2196F3);  // Biru Sekunder
  
  // Variasi warna untuk kebutuhan UI (Button, Text, dll)
  static const Color primaryDark = Color(0xFF0D47A1);     // Biru Gelap
  static const Color primaryLight = Color(0xFF64B5F6);    // Biru Terang
  static const Color white = Colors.white;
  static const Color error = Colors.redAccent;

  // 🌈 GRADIENTS (Digunakan di background Login/Register)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      primaryColor,   // Atas: Biru agak gelap
      Color(0xFF42A5F5), // Bawah: Biru cerah
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 🎭 THEME DATA (Konfigurasi Global Material 3)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: white,

      // Konfigurasi Skema Warna Global
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: error,
        brightness: Brightness.light,
      ),

      // Konfigurasi AppBar (Header)
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: white,
        ),
      ),

      // Konfigurasi Tombol ElevatedButton Default
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: white,
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),

      // Konfigurasi Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: white,
      ),

      // Konfigurasi Input Decoration (Opsional, agar TextField konsisten)
      // Kita biarkan kosong jika Anda ingin kontrol penuh lewat CustomTextField
    );
  }
}