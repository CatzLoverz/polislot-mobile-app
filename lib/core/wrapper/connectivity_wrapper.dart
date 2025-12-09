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
    final isOffline = ref.watch(connectionStatusProvider);

    return Stack(
      children: [
        // Halaman Utama
        child,

        // Indikator Offline
        if (isOffline)
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
                  AppSnackBars.show(
                    context, 
                    "Tidak dapat terhubung ke server.\nPeriksa internet Anda dan lakukan refresh.", 
                    isError: true
                  );
                },
                customBorder: const CircleBorder(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
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