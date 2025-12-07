import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import '../../../core/routes/app_routes.dart';

class MissionScreen extends StatefulWidget {
  final bool initialTabIsMission;

  const MissionScreen({
    super.key,
    this.initialTabIsMission = true,
  });

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> with SingleTickerProviderStateMixin {
  late bool isMissionTab;
  
  // Animation Controllers
  late AnimationController _animController;
  
  // ✅ List Animasi (Profile Style Generator)
  // Kita siapkan list animasi untuk Misi dan Leaderboard
  late List<Animation<double>> _missionFadeAnims;
  late List<Animation<Offset>> _missionSlideAnims;
  late List<Animation<double>> _leaderboardFadeAnims;
  late List<Animation<Offset>> _leaderboardSlideAnims;

  // Placeholder Data
  final int _totalValidasi = 24;
  final int _totalPoints = 480;

  final List<Map<String, dynamic>> _missions = [
    {
      "title": "Validasi Parkiran",
      "points": "+30 koin",
      "desc": "Selesaikan 3 kali validasi lokasi parkir hari ini untuk bonus tambahan.",
      "progress": 0.66,
      "icon": FontAwesomeIcons.squareCheck,
      "color": const Color(0xFF1352C8),
    },
    {
      "title": "Streak Master",
      "points": "+50 koin",
      "desc": "Pertahankan streak validasi selama 7 hari berturut-turut untuk poin ekstra.",
      "progress": 0.85,
      "icon": FontAwesomeIcons.fire,
      "color": Colors.orange,
    },
    {
      "title": "Kontributor Hebat",
      "points": "+300 koin",
      "desc": "Lengkapi 10 validasi selama minggu ini untuk jadi kontributor terbaik.",
      "progress": 0.98,
      "icon": FontAwesomeIcons.award,
      "color": Colors.amber,
    },
    {
      "title": "Eksplorer Parkir",
      "points": "+200 poin",
      "desc": "Temukan dan validasi 5 area parkir baru selama minggu ini.",
      "progress": 0.66,
      "icon": FontAwesomeIcons.mapLocationDot,
      "color": Colors.green,
    },
  ];

  final List<Map<String, dynamic>> _leaderboardData = List.generate(
    20,
    (i) => {
      "name": [
        "Andri Yani Meuraxa", "Alndea Resta Amaira", "Ardila Putri", "Rafi Putra", "Nanda Azizah",
        "Dimas Hidayat", "Putri Maharani", "Rizki Fadillah", "Aulia Rahman", "Febrianti Sari",
        "Bayu Saputra", "Tania Marlina", "Yusuf Alamsyah", "Citra Ayu", "Wahyu Nugraha",
        "Lina Oktaviani", "Fajar Ramadhan", "Siska Amelia", "Gilang Permana", "Rara Nurhaliza"
      ][i],
      "validasi": 98 - i * 2,
      "points": (98 - i * 2) * 10,
      "isCurrentUser": i == 0, 
    },
  );

  @override
  void initState() {
    super.initState();
    isMissionTab = widget.initialTabIsMission;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Sedikit dipercepat agar snappy
    );

    // ✅ GENERATE ANIMASI MISI (Style Profile)
    _missionFadeAnims = List.generate(_missions.length, (i) {
      // Delay bertahap (Staggered)
      final start = 0.1 + (i * 0.1); 
      final end = start + 0.5;
      return CurvedAnimation(
        parent: _animController,
        // Clamp agar tidak error jika durasi melebihi 1.0
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOut),
      );
    });

    _missionSlideAnims = List.generate(_missions.length, (i) {
      final start = 0.1 + (i * 0.1);
      final end = start + 0.5;
      return Tween<Offset>(
        begin: const Offset(0, 0.2), // Slide dari bawah (0.2) ke posisi asli (0)
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ));
    });

    // ✅ GENERATE ANIMASI LEADERBOARD (Limit 10 item awal agar tidak berat)
    int leaderCount = _leaderboardData.length;
    _leaderboardFadeAnims = List.generate(leaderCount, (i) {
      final start = 0.2 + (i * 0.05); // Lebih cepat delay-nya karena item banyak
      final end = start + 0.5;
      return CurvedAnimation(
        parent: _animController,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOut),
      );
    });

    _leaderboardSlideAnims = List.generate(leaderCount, (i) {
      final start = 0.2 + (i * 0.05);
      final end = start + 0.5;
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ));
    });

    // ❌ HAPUS: Animasi Tween Angka (Total Misi & Koin) dihapus sesuai request

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToParkir() {
    // Navigator.pushNamed(context, AppRoutes.parkir);
  }

  // Widget Helper Animasi Sederhana untuk elemen tunggal (Header/Tab)
  Widget _fadeSlideSingle(Widget child, {double delay = 0.0}) {
    final fade = CurvedAnimation(
      parent: _animController,
      curve: Interval(delay, (delay + 0.5).clamp(1.0, 1.0), curve: Curves.easeIn),
    );
    final slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Interval(delay, (delay + 0.5).clamp(1.0, 1.0), curve: Curves.easeOut),
      ),
    );
    return FadeTransition(opacity: fade, child: SlideTransition(position: slide, child: child));
  }

  @override
  Widget build(BuildContext context) {
    final currentUserData = _leaderboardData.firstWhere(
      (element) => element['isCurrentUser'] == true, 
      orElse: () => _leaderboardData[0]
    );
    final currentUserRank = _leaderboardData.indexOf(currentUserData) + 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF3F6FB), // Match background
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Misi & Leaderboard",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fadeSlideSingle(_topStatsCard(), delay: 0.0),
                const SizedBox(height: 20),
                
                // TAB BAR
                _fadeSlideSingle(_animatedTabs(), delay: 0.1),
                
                const SizedBox(height: 20),
                
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isMissionTab 
                      ? _buildMissionsList() 
                      : _buildLeaderboard(),
                ),
              ],
            ),
          ),

          if (!isMissionTab)
            Positioned(
              left: 0, 
              right: 0, 
              bottom: 0,
              child: _buildUserPositionCard(currentUserRank, currentUserData),
            ),
        ],
      ),
    );
  }

  Widget _topStatsCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ✅ HAPUS ANIMASI ANGKA: Tampilkan langsung nilainya
          _statBox(
            icon: Icons.verified_rounded,
            color: Colors.amber,
            title: "Total Misi Selesai",
            value: _totalValidasi.toString(), 
          ),
          Container(width: 1, height: 50, color: Colors.white24),
          _statBox(
            icon: Icons.monetization_on_rounded,
            color: Colors.greenAccent,
            title: "Lifetime Koin",
            value: _totalPoints.toString(),
          ),
        ],
      ),
    );
  }

  Widget _statBox({required IconData icon, required Color color, required String title, required String value}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
        Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
      ],
    );
  }

  Widget _animatedTabs() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: isMissionTab ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.45,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1565C0).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isMissionTab = true),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text("Misi", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isMissionTab ? Colors.white : Colors.grey[600])),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isMissionTab = false),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text("Leaderboard", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: !isMissionTab ? Colors.white : Colors.grey[600])),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ BUILDER MISI (Menggunakan Animasi Generate Profile Style)
  Widget _buildMissionsList() {
    return Column(
      key: const ValueKey('MissionsList'), 
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Daftar Misi Kamu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 14),
        
        // Loop sesuai data database
        for (int i = 0; i < _missions.length; i++)
          // Gunakan animasi dari List yang sudah digenerate di InitState
          FadeTransition(
            opacity: _missionFadeAnims[i],
            child: SlideTransition(
              position: _missionSlideAnims[i],
              child: _missionCard(_missions[i]),
            ),
          ),
      ],
    );
  }

  Widget _missionCard(Map<String, dynamic> m) {
    // Isi Card tidak diubah sesuai instruksi
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: (m['color'] as Color).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(m['icon'] as IconData, color: m['color'] as Color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(m['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              Text(m['points'] as String, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(m['desc'] as String, style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: m['progress'] as double, backgroundColor: const Color(0xFFE0E0E0), color: m['color'] as Color, minHeight: 6))),
              const SizedBox(width: 10),
              Text("${((m['progress'] as double) * 100).toInt()}%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: m['color'] as Color)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _navigateToParkir,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1352C8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text("Mulai Validasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ BUILDER LEADERBOARD (Menggunakan Animasi Generate Profile Style)
  Widget _buildLeaderboard() {
    final top3 = _leaderboardData.take(3).toList();
    final rest = _leaderboardData.skip(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPodium(top3),
        const SizedBox(height: 16),
        _buildTierHeader("Peringkat Lainnya"),
        const SizedBox(height: 10),
        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6)],
          ),
          child: Column(
            children: [
              // Loop sisa leaderboard dengan animasi staggered
              for (int i = 0; i < rest.length; i++)
                // Cek index aman (karena list animasi di-init sejumlah data)
                if (i < _leaderboardFadeAnims.length)
                  FadeTransition(
                    opacity: _leaderboardFadeAnims[i],
                    child: SlideTransition(
                      position: _leaderboardSlideAnims[i],
                      child: _leaderboardTile(i + 3, rest[i]),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> top3) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (top3.length > 1) Expanded(child: _podiumItem(top3[1], 2, 140, Colors.grey.shade400)),
          const SizedBox(width: 8),
          Expanded(child: _podiumItem(top3[0], 1, 180, Colors.amber)),
          const SizedBox(width: 8),
          if (top3.length > 2) Expanded(child: _podiumItem(top3[2], 3, 110, Colors.brown.shade400)),
        ],
      ),
    );
  }

  Widget _podiumItem(Map<String, dynamic> user, int rank, double height, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: rank == 1 ? 32 : 26, backgroundColor: color.withValues(alpha: 0.2), child: Text(user['name'][0], style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20))),
        const SizedBox(height: 8),
        Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text("${user['validasi']} Val", style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity, height: height,
          decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))]),
          child: Center(child: Text("#$rank", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
        ),
      ],
    );
  }

  Widget _leaderboardTile(int index, Map<String, dynamic> user) {
    final rank = index + 1;
    final isCurrentUser = user['isCurrentUser'] == true;
    final bgColor = isCurrentUser ? const Color(0xFF1352C8).withValues(alpha: 0.2) : Colors.transparent;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text("#$rank", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey))),
          const SizedBox(width: 10),
          CircleAvatar(radius: 18, backgroundColor: Colors.grey.shade200, child: Text(user['name'][0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
          const SizedBox(width: 12),
          Expanded(child: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          Text("${user['validasi']} Val", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1352C8))),
        ],
      ),
    );
  }

  Widget _buildTierHeader(String title) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))),
        const Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
      ],
    );
  }

  Widget _buildUserPositionCard(int rank, Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF2196F3)]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0x44000000), blurRadius: 12, offset: const Offset(0, -2))]),
      child: Row(
        children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: Center(child: Text("#$rank", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Posisi Kamu", style: TextStyle(color: Colors.white70, fontSize: 12)), Text(user['name'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis), Text("${user['validasi']} Validasi", style: const TextStyle(color: Colors.white, fontSize: 14))])),
        ],
      ),
    );
  }
}