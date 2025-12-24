// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/security/key_manager.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/utils/navigator_key.dart';

void main() async {
  // 1. Wajib: Binding Widget
  WidgetsFlutterBinding.ensureInitialized();

  // FIX: Force Hybrid Composition for Android Maps to prevent "Blank Map" issues on some devices
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }

  try {
    // A. Load Environment Variables
    await dotenv.load(fileName: ".env");

    // B. Load RSA Public Key (Ini yang sering bikin crash kalau file tidak ada)
    await KeyManager.loadPublicKey();

    // C. Inisialisasi lokal tanggal untuk Indonesia
    await initializeDateFormatting('id_ID', null);

    // D. Jika sukses, jalankan aplikasi normal
    runApp(const ProviderScope(child: PoliSlotApp()));
  } catch (e, stackTrace) {
    debugPrint("🔥 CRITICAL ERROR STARTUP: $e");
    debugPrintStack(stackTrace: stackTrace);

    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red.shade900,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 60,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "GAGAL MEMULAI APLIKASI",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Error: $e",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Tips: Cek file .env dan assets/keys/public_key.pem",
                    style: TextStyle(color: Colors.amber),
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

class PoliSlotApp extends StatelessWidget {
  const PoliSlotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PoliSlot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
