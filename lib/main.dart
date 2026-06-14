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
import 'features/auth/presentation/auth_controller.dart';
import 'features/info_board/presentation/info_board_controller.dart';
import 'features/mission/presentation/mission_controller.dart';
import 'features/park/presentation/park_controller.dart';
import 'features/reward/presentation/reward_controller.dart';
import 'features/history/presentation/history_controller.dart';
import 'core/services/mqtt_service.dart';


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


class PoliSlotApp extends ConsumerStatefulWidget {
  const PoliSlotApp({super.key});

  @override
  ConsumerState<PoliSlotApp> createState() => _PoliSlotAppState();
}

class _PoliSlotAppState extends ConsumerState<PoliSlotApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Inisialisasi MQTT service sejak awal agar koneksi terbentuk sebelum buka peta
    Future.microtask(() => ref.read(mqttServiceProvider));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // Reconnect MQTT jika koneksi terputus saat di background
      final mqttStatus = ref.read(mqttServiceProvider);
      if (mqttStatus != MqttConnectionStatus.connected &&
          mqttStatus != MqttConnectionStatus.connecting) {
        ref.read(mqttServiceProvider.notifier).reconnect();
      }

      if (isAppInitialized) {
        // Tunggu validasi token selesai terlebih dahulu
        final isValid = await ref.read(authControllerProvider.notifier).checkStartupSession();
        
        // Jika token masih valid, barulah lakukan refresh pada data UI
        // Ini mencegah UI menembak request bersamaan yang berujung pada error 401 tumpang tindih
        if (isValid) {
          ref.invalidate(infoBoardControllerProvider);
          ref.invalidate(missionControllerProvider);
          ref.read(parkAreaListControllerProvider.notifier).refreshData();
          ref.invalidate(rewardControllerProvider);
          ref.invalidate(historyControllerProvider);
          ref.invalidate(rewardHistoryControllerProvider);
        }
      }
    }
  }

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
