import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/snackbar_utils.dart';
import '../providers/connection_status_provider.dart';

class AppConnectivityWrapper extends ConsumerWidget {
  final Widget child;
  const AppConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pantau status koneksi global dari provider
    final connectionState = ref.watch(connectionStatusProvider);

    return Stack(
      children: [
        // Halaman Utama
        child,

        // Indikator Offline/Server Error
        if (connectionState != ConnectionStateType.online)
          Positioned(
            bottom: 100,
            right: 20,
            child: Material(
              color: Colors.transparent,
              elevation: 4,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () {
                  // ✅ Tap hanya memunculkan SnackBar
                  String message = connectionState == ConnectionStateType.noInternet
                      ? "Koneksi internet terputus.\nPeriksa WiFi atau data seluler Anda."
                      : "Server sedang mengalami gangguan.\nSilakan coba beberapa saat lagi.";
                      
                  AppSnackBars.show(
                    context, 
                    message, 
                    isError: true
                  );
                },
                customBorder: const CircleBorder(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: connectionState == ConnectionStateType.noInternet ? Colors.redAccent : Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Icon(
                    connectionState == ConnectionStateType.noInternet ? Icons.wifi_off_rounded : Icons.dns_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}