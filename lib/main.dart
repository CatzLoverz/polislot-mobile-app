// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/security/key_manager.dart'; 
import 'core/wrapper/connectivity_wrapper.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // 1. Wajib: Binding Widget
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Error Handling Global (Agar tidak layar hitam)
  try {
    // A. Load Environment Variables
    await dotenv.load(fileName: ".env");
    
    // B. Load RSA Public Key (Ini yang sering bikin crash kalau file tidak ada)
    await KeyManager.loadPublicKey();

    // C. Jika sukses, jalankan aplikasi normal
    runApp(
      const ProviderScope(
        child: PoliSlotApp(),
      ),
    );
  } catch (e, stackTrace) {
    // 🛑 JIKA ERROR: Tampilkan layar error merah
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
                  const Icon(Icons.error_outline, color: Colors.white, size: 60),
                  const SizedBox(height: 20),
                  const Text(
                    "GAGAL MEMULAI APLIKASI",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
                  )
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
      
      // Gunakan Wrapper Koneksi yang sudah kita buat sebelumnya
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return AppConnectivityWrapper(child: child);
      },
    );
  }
}