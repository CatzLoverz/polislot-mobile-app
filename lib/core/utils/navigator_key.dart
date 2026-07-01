import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool isAppInitialized = false;

/// Menyimpan sementara argumen Deep Link yang diterima sebelum Splash selesai.
/// Setelah Splash selesai, nilai ini akan dikonsumsi untuk navigasi.
Map<String, String>? pendingDeepLink;