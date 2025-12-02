import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/auth_controller.dart';

class AppConnectivityWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const AppConnectivityWrapper({super.key, required this.child});

  @override
  ConsumerState<AppConnectivityWrapper> createState() => _AppConnectivityWrapperState();
}

class _AppConnectivityWrapperState extends ConsumerState<AppConnectivityWrapper> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  Timer? _heartbeatTimer;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    // 1. Cek status awal
    _initConnectivity();
    
    // 2. Monitor perubahan jaringan
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      _handleConnectivityChange(results);
    });

    // 3. Mulai Heartbeat (Cek server berkala)
    _startHeartbeat();
  }

  void _initConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _handleConnectivityChange(results);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final hasNetwork = !results.contains(ConnectivityResult.none);
    
    if (!hasNetwork) {
      // Fisik mati -> Pasti Offline
      _setOffline(true);
    } else {
      // Fisik nyala -> Cek Server
      _checkServerConnection();
    }
  }

  Future<void> _checkServerConnection() async {
    // Ping server via Controller
    // Pastikan authController memiliki method isServerReachable()
    final isReachable = await ref.read(authControllerProvider.notifier).isServerReachable();
    
    if (isReachable) {
      _setOffline(false);
      // Jika server nyambung, cek validitas token (Session)
      // Ini berjalan di background (Async), tidak memblokir UI
      ref.read(authControllerProvider.notifier).checkAuthSession();
    } else {
      _setOffline(true);
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      // Hanya cek jika kita merasa "Online" untuk memastikan sesi tetap valid
      if (!_isOffline) {
        debugPrint("💓 Heartbeat: Checking Server & Session...");
        _checkServerConnection();
      }
    });
  }

  void _setOffline(bool value) {
    if (_isOffline != value && mounted) {
      setState(() => _isOffline = value);
    }
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Halaman Aplikasi (Child)
        widget.child,

        // 2. Indikator Offline (Overlay)
        if (_isOffline)
          Positioned(
            bottom: 120, // Posisi di atas navbar
            right: 20,
            child: Material(
              color: Colors.transparent,
              elevation: 4,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () {
                  // Saat diklik, coba cek koneksi manual
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Anda sedang Offline. Mencoba menghubungkan...", style: TextStyle(fontWeight: FontWeight.w600)),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                  );
                  _checkServerConnection();
                },
                customBorder: const CircleBorder(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
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