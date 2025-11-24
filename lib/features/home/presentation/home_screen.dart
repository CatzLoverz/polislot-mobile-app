import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// ✅ Import Controller Auth & User Model
import '../../auth/presentation/auth_controller.dart';
import '../../auth/data/user_model.dart';
// import '../../../core/routes/app_routes.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  Timer? _timer;

  final List<String> _slideTexts = [
    "Selamat Datang di Aplikasi PoliSlot! Temukan slot parkir terbaikmu.",
    "Ayo klaim validasi harian untuk dapatkan poin!💪",
    "Kumpulkan streak untuk jadi pemenang mingguan!🔥",
    "Selesaikan misi dan rebut posisi top leaderboard!🎯",
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll logic (Sama seperti lama)
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      int nextPage = (_pageController.page?.toInt() ?? 0) + 1;
      if (nextPage >= _slideTexts.length) nextPage = 0;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Pemberitahuan Penting",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1352C8),
            ),
          ),
          content: const Text(
            "Pada Hari Selasa, 08 Oktober akan diberlakukan peraturan wajib helm bagi seluruh pengguna kendaraan roda dua di area kampus.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Tutup", style: TextStyle(color: Color(0xFF1352C8))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ AMBIL DATA USER DARI RIVERPOD
    final authState = ref.watch(authControllerProvider);
    final User? user = authState.value; 

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Home',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A253A),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Greeting Card (Dinamis Name)
                _buildGreetingCard(user?.name ?? "Mahasiswa"),
                
                const SizedBox(height: 16),
                _buildParkingCard(),
                const SizedBox(height: 16),
                
                InkWell(
                  onTap: () => _showInfoDialog(context),
                  borderRadius: BorderRadius.circular(16),
                  child: _buildInfoBoard(),
                ),
                
                const SizedBox(height: 16),
                _buildDailyMissionCard(),
                const SizedBox(height: 16),
                _buildLeaderboardCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== KOMPONEN UI =====================

  Widget _buildGreetingCard(String userName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hai, $userName 👋", // ✅ Nama Dinamis
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slideTexts.length,
              itemBuilder: (context, index) {
                return Text(
                  _slideTexts[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SmoothPageIndicator(
            controller: _pageController,
            count: _slideTexts.length,
            effect: const WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: Colors.white,
              dotColor: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingCard() {
    return InkWell(
      onTap: () {
        // Navigasi ke Parkir (Nanti diganti dengan route named)
        // Navigator.pushNamed(context, AppRoutes.parkir);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fitur Parkir sedang direfactor")),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.local_parking, color: Colors.white, size: 28),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "127 Slot Parkir",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Text(
                      "3 Area Tersedia",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBoard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFE0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Color(0xFFFFA500),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Pada Hari Selasa tanggal 08 Oktober akan diberlakukan peraturan wajib helm...",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Color(0xFF454F63)),
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              size: 16, color: Colors.black38),
        ],
      ),
    );
  }

  Widget _buildDailyMissionCard() {
    return _customCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.assignment_rounded, color: Color(0xFF1352C8)),
              SizedBox(width: 8),
              Text(
                "Misi Harian Ini",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF1A253A)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Selesaikan misi hari ini untuk mendapatkan poin tambahan!",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          _missionTile(Icons.local_parking, "Validasi Parkiran", 0.7, "+30",
              Colors.blue),
          const SizedBox(height: 12),
          _missionTile(Icons.local_fire_department, "Streak Master", 0.85,
              "+50", Colors.orange),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                // Navigasi ke Misi
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1352C8),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Validasi",
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard() {
    // Data dummy leaderboard (Nanti bisa dari API)
    final leaders = [
      {"rank": 1, "name": "Andri Yani Meuraxa", "validasi": "98"},
      {"rank": 2, "name": "Alndea Resta Amaira", "validasi": "91"},
      {"rank": 3, "name": "Ardila Putri", "validasi": "87"},
    ];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Navigasi ke Leaderboard
      },
      child: _customCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.emoji_events_rounded, color: Color(0xFF1352C8)),
                SizedBox(width: 8),
                Text(
                  "Peringkat Teratas",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF1A253A),
                  ),
                ),
                Spacer(),
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black38),
              ],
            ),
            const Divider(),
            Column(
              children: leaders.map((l) {
                return _leaderRow(
                  l["rank"] as int,
                  l["name"] as String,
                  l["validasi"] as String,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leaderRow(int rank, String name, String validasi) {
    late Color tierColor;
    late IconData tierIcon;

    if (rank == 1) {
      tierColor = Colors.amber; 
      tierIcon = Icons.emoji_events;
    } else if (rank == 2) {
      tierColor = const Color(0xFFC0C0C0); 
      tierIcon = Icons.emoji_events;
    } else {
      tierColor = const Color(0xFFCD7F32);
      tierIcon = Icons.emoji_events;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: tierColor.withValues(alpha: 0.15),
                child: Icon(tierIcon, color: tierColor, size: 24),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  child: Text(
                    "#$rank",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, color: tierColor, size: 18),
              const SizedBox(width: 4),
              Text(
                "$validasi Validasi",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _missionTile(
      IconData icon, String title, double progress, String points, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15))),
            Text(points,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withValues(alpha: 0.2),
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _customCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}