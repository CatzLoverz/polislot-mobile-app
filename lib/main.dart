import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/wrapper/connectivity_wrapper.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      
      // ✅ GUNAKAN WRAPPER DISINI
      // Wrapper ini akan otomatis membungkus semua halaman yang dibuka
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return AppConnectivityWrapper(child: child);
      },
    );
  }
}