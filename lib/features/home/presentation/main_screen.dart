import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_screen.dart';
import '../../profile/presentation/profile_screen.dart';
// import '../../../core/routes/app_routes.dart';
import '../../profile/presentation/providers/profile_ui_provider.dart';
import '../../mission/presentation/mission_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  int _previousIndex = 0; 
  late final PageController _pageController;
  
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
  }

  @override
  void dispose() {
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
      child: Scaffold(
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
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title; final IconData icon;
  const _PlaceholderScreen({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 80, color: Colors.grey[300]), Text(title)]));
}