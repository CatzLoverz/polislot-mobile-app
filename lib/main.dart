import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

// Global Key untuk navigasi tanpa context (dipakai di Dio Interceptor)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load Environment Variables
  await dotenv.load(fileName: ".env");

  runApp(
    const ProviderScope(
      child: PoliSlotApp(),
    ),
  );
}

class PoliSlotApp extends StatelessWidget {
  const PoliSlotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PoliSlot',
      debugShowCheckedModeBanner: false,
      
      // Setup Tema
      theme: AppTheme.lightTheme,

      // Setup Navigasi
      navigatorKey: navigatorKey, // 👈 Penting untuk Logout Otomatis
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}