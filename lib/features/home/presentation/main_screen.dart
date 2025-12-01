import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; 

import 'home_screen.dart';
import '../../profile/presentation/profile_screen.dart';
// import '../../../core/routes/app_routes.dart';
import '../../profile/presentation/providers/profile_ui_provider.dart';
import '../../mission/presentation/mission_screen.dart';
import '../../auth/presentation/auth_controller.dart'; 

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  int _previousIndex = 0; 
  late final PageController _pageController;
  
  // Status Offline & Timer
  bool _isOffline = false;
  Timer? _retryTimer; // Timer untuk cek ulang koneksi
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final List<Widget> _pages = [
    const HomeScreen(),
    const MissionScreen(), 
    const _PlaceholderScreen(title: "Reward Screen", icon: Icons.card_giftcard),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() async {
    // Cek awal
    final initialResults = await Connectivity().checkConnectivity();
    _handleConnectivityChange(initialResults);

    // Listen perubahan
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      _handleConnectivityChange(results);
    });
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    // 1. Cek Koneksi Fisik (WiFi/Mobile)
    final hasNetwork = !results.contains(ConnectivityResult.none);

    if (!hasNetwork) {
      // Jika Fisik Mati -> Pasti Offline
      _setOffline(true);
      _stopRetryTimer(); // Tidak usah ping server kalau fisik mati
    } else {
      // Jika Fisik Hidup -> Cek Server
      _checkServerConnection();
    }
  }

  // ✅ LOGIKA UTAMA: Cek Server & Retry
  Future<void> _checkServerConnection() async {
    final isReachable = await ref.read(authControllerProvider.notifier).isServerReachable();
    
    if (isReachable) {
      // Server OK -> Online
      _setOffline(false);
      _stopRetryTimer(); // Berhenti cek ulang
      
      // Sync Data User (Karena baru online lagi)
      ref.read(authControllerProvider.notifier).checkAuthSession();
    } else {
      // Server Gagal -> Offline
      _setOffline(true);
      
      // Mulai Timer untuk cek ulang otomatis (Self-Healing)
      _startRetryTimer();
    }
  }

  void _startRetryTimer() {
    if (_retryTimer != null && _retryTimer!.isActive) return;
    
    // Coba ping server setiap 5 detik
    _retryTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkServerConnection();
    });
  }

  void _stopRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  void _setOffline(bool value) {
    if (_isOffline != value && mounted) {
      setState(() => _isOffline = value);
    }
  }

  @override
  void dispose() {
    _stopRetryTimer();
    _connectivitySubscription.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (index == _selectedIndex) return;
    if (_selectedIndex == 3) {
      ref.read(profileSectionProvider.notifier).setSection(0);
    }
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<bool> _showExitConfirmDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Keluar Aplikasi", style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin menutup aplikasi?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Keluar"),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (_selectedIndex == 3) {
          final currentSection = ref.read(profileSectionProvider);
          if (currentSection != 0) {
            ref.read(profileSectionProvider.notifier).setSection(0);
            return;
          }
        }
        if (_selectedIndex != 0) {
          setState(() {
            if (_previousIndex != 0) { _selectedIndex = _previousIndex; _previousIndex = 0; }
            else { _selectedIndex = 0; }
            _pageController.animateToPage(_selectedIndex, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          });
          return;
        }
        final shouldExit = await _showExitConfirmDialog();
        if (shouldExit) SystemNavigator.pop();
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: const Color(0xFFF3F6FB),
            body: RepaintBoundary(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: _pages,
              ),
            ),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(blurRadius: 10, color: Color.fromARGB(40, 0, 0, 0), offset: Offset(0, -3))],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: GNav(
                    gap: 8,
                    color: const Color(0xFF5A6BB5),
                    activeColor: Colors.white,
                    textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
                    iconSize: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                    duration: const Duration(milliseconds: 300),
                    tabBackgroundGradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    tabs: const [
                      GButton(icon: Icons.home_rounded, text: 'Home'),
                      GButton(icon: Icons.flag_outlined, text: 'Misi'),
                      GButton(icon: Icons.card_giftcard_rounded, text: 'Reward'),
                      GButton(icon: Icons.person_outline_rounded, text: 'Profil'),
                    ],
                    selectedIndex: _selectedIndex,
                    onTabChange: _onTabChanged,
                  ),
                ),
              ),
            ),
          ),

          // ✅ NOTIFIKASI OFFLINE (MERAH KECIL)
          if (_isOffline)
            Positioned(
              bottom: 90, 
              right: 20,
              child: Tooltip(
                message: "Anda sedang Offline (Tidak terhubung ke server)",
                triggerMode: TooltipTriggerMode.tap,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  const _PlaceholderScreen({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 80, color: Colors.grey[300]), Text(title)]));
}