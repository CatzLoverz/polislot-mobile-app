import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  runApp(
    // Wajib ProviderScope untuk Riverpod
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
      
      // Gunakan tema global
      theme: AppTheme.lightTheme,

      // ✅ Mulai dari Splash Screen
      initialRoute: AppRoutes.splash, 
      
      // Gunakan sistem routing baru
      onGenerateRoute: AppRoutes.onGenerateRoute, 
    );
  }
}