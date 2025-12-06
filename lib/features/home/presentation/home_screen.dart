import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:intl/intl.dart';
// import 'package:intl/date_symbol_data_local.dart';

import '../../auth/presentation/auth_controller.dart';
// import '../../auth/data/user_model.dart';
import '../../info_board/data/info_board_model.dart';
import '../../info_board/presentation/info_board_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  Timer? _slideTimer;
  Timer? _dataRefreshTimer;

  final List<String> _slideTexts = [
    "Selamat Datang di Aplikasi PoliSlot! Temukan slot parkir terbaikmu.",
    "Ayo klaim validasi harian untuk dapatkan poin!💪",
    "Kumpulkan streak untuk jadi pemenang mingguan!🔥",
    "Selesaikan misi dan rebut posisi top leaderboard!🎯",
  ];

  // Data Placeholder Area Parkir
  final List<Map<String, String>> _parkingAreas = [
    {
      "name": "Parkir Tower A",
      "desc": "Pada area ini memiliki 3 sub-area yang dapat anda tempati untuk parkir",
      "code": "TA",
    },
    {
      "name": "Parkir Gedung Utama",
      "desc": "Pada area ini memiliki 2 sub-area yang dapat anda tempati untuk parkir",
      "code": "GU",
    },
    {
      "name": "Parkir Teaching Factory",
      "desc": "Pada area ini memiliki 2 sub-area yang dapat anda tempati untuk parkir",
      "code": "RTF",
    },
    {
      "name": "Parkir Technopreneur",
      "desc": "Pada area ini memiliki 2 sub-area yang dapat anda tempati untuk parkir",
      "code": "TECHNO",
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _slideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page?.toInt() ?? 0) + 1;
        if (nextPage >= _slideTexts.length) nextPage = 0;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _slideTimer?.cancel();
    _dataRefreshTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // 📢 POP-UP DIALOG
  void _showAllInfoDialog(BuildContext context, List<InfoBoard> infoList) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Papan Pemberitahuan",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1352C8)),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: infoList.isEmpty
                ? const Text("Tidak ada pengumuman.")
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: infoList.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final info = infoList[index];
                      String dateStr = '-';
                      if (info.createdAt != null) {
                        try {
                          dateStr = DateFormat('d MMM y, HH:mm', 'id_ID').format(info.createdAt!);
                        } catch (e) {
                          dateStr = info.createdAt.toString();
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            info.content,
                            style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              dateStr,
                              style: TextStyle(color: Colors.grey[600], fontSize: 11, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Tutup", style: TextStyle(color: Color(0xFF1352C8), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;
    final infoBoardAsync = ref.watch(infoBoardControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            return ref.refresh(infoBoardControllerProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Home',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A253A)),
                  ),
                  const SizedBox(height: 16),

                  // 1. Greeting Card
                  _buildGreetingCard(user?.name ?? "Mahasiswa"),
                  const SizedBox(height: 16),

                  // 2. Info Board
                  infoBoardAsync.when(
                    skipLoadingOnRefresh: true,
                    data: (infoList) {
                      if (infoList.isEmpty) {
                        return _buildInfoBoardPlaceholder();
                      }
                      final latestInfo = infoList.first;
                      return InkWell(
                        onTap: () => _showAllInfoDialog(context, infoList),
                        borderRadius: BorderRadius.circular(16),
                        child: _buildInfoBoardCard(latestInfo),
                      );
                    },
                    loading: () => _buildInfoBoardLoading(),
                    error: (err, stack) => _buildInfoBoardPlaceholder(isError: true),
                  ),
                  const SizedBox(height: 24),

                  // 3. Header Summary Area Parkir
                  _buildParkingHeaderCard(),
                  const SizedBox(height: 16),

                  // 4. List Area Parkir
                  ..._parkingAreas.map((area) => _buildParkingAreaItem(area)),
                  const SizedBox(height: 16),

                  // 5. Leaderboard 
                  _buildLeaderboardCard(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= WIDGET BUILDERS =================

  Widget _buildLeaderboardCard() {
    // Data dummy leaderboard
    final leaders = [
      {"rank": 1, "name": "Andri Yani Meuraxa", "validasi": "98"},
      {"rank": 2, "name": "Alndea Resta Amaira", "validasi": "91"},
      {"rank": 3, "name": "Ardila Putri", "validasi": "87"},
    ];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Navigasi ke Leaderboard Detail jika ada
      },
      child: _customCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
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
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
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

  // Helper Card Container
  Widget _customCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // --- Parking Area Widgets ---

  Widget _buildParkingHeaderCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text(
            "P",
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_parkingAreas.length} Area Tersedia",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Jelajahi berbagai area parkir yang tersedia untuk Anda.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildParkingAreaItem(Map<String, String> area) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      area['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A253A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      area['desc']!,
                      style: const TextStyle(
                        color: Color(0xFF454F63),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF1565C0),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "P",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    area['code']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Greeting Card ---
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hai, $userName 👋",
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

  // --- Info Board Widgets ---
  Widget _buildInfoBoardCard(InfoBoard info) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pemberitahuan Terbaru",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A253A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  info.content, 
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF454F63),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26),
        ],
      ),
    );
  }

  Widget _buildInfoBoardPlaceholder({bool isError = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // Saya sesuaikan alpha agar shadow lebih halus (standar 0.05-0.1)
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
              // ✅ Ganti Background: Merah muda saat error, Abu saat kosong
              color: isError ? Colors.red.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              // ✅ Ganti Icon: Wifi Off saat error, Lonceng saat kosong
              isError ? Icons.wifi_off_rounded : Icons.notifications_none_rounded,
              // ✅ Ganti Warna Icon: Merah saat error
              color: isError ? Colors.red.shade400 : Colors.grey.shade400,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Teks Judul
                  isError ? "Anda Sedang Offline" : "Belum ada informasi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    // ✅ Ganti Warna Teks Judul jadi Merah saat error
                    color: isError ? Colors.red.shade700 : const Color(0xFF1A253A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isError
                      ? "Periksa koneksi internet Anda."
                      : "Tidak ada informasi terbaru saat ini.",
                  maxLines: 2,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF454F63),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBoardLoading() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: double.infinity, height: 14, color: Colors.grey[200]),
                const SizedBox(height: 6),
                Container(width: 150, height: 12, color: Colors.grey[200]),
              ],
            ),
          )
        ],
      ),
    );
  }
}