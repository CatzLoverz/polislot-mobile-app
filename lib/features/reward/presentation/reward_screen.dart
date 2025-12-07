import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RewardScreen extends ConsumerStatefulWidget {
  const RewardScreen({super.key});

  @override
  ConsumerState<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends ConsumerState<RewardScreen> with SingleTickerProviderStateMixin {
  bool isTokoSelected = true;
  
  // Animation Controllers
  late AnimationController _animController;
  
  // List Animasi (Profile/Mission Style)
  late List<Animation<double>> _rewardFadeAnims;
  late List<Animation<Offset>> _rewardSlideAnims;
  late List<Animation<double>> _historyFadeAnims;
  late List<Animation<Offset>> _historySlideAnims;

  // ===========================================================================
  // 💾 DATA PLACEHOLDER (Siap diganti dengan Data API)
  // ===========================================================================

  final int _currentPoints = 1250;

  final List<Map<String, dynamic>> _dummyRewards = [
    {
      "name": "Voucher Kantin Rp 10.000",
      "desc": "Potongan harga untuk semua tenant kantin.",
      "points": 500,
      "type": "voucher",
      "canExchange": true,
    },
    {
      "name": "Tote Bag Eksklusif",
      "desc": "Tas jinjing kanvas dengan logo kampus.",
      "points": 1500,
      "type": "merchandise",
      "canExchange": false,
    },
    {
      "name": "Voucher Parkir Gratis 1 Hari",
      "desc": "Bebas biaya parkir seharian penuh.",
      "points": 300,
      "type": "voucher",
      "canExchange": true,
    },
    {
      "name": "Gantungan Kunci",
      "desc": "Merchandise kecil untuk kenang-kenangan.",
      "points": 200,
      "type": "merchandise",
      "canExchange": true,
    },
  ];

  final List<Map<String, dynamic>> _dummyHistory = [
    {
      "name": "Voucher Kantin Rp 10.000",
      "code": "KANTIN-8821",
      "status": "Dipakai",
      "date": "12 Okt 2025",
      "isPending": false,
    },
    {
      "name": "Voucher Parkir Gratis",
      "code": "PARK-9921",
      "status": "Menunggu",
      "date": "14 Okt 2025",
      "isPending": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // ✅ GENERATE ANIMASI REWARD (Staggered)
    _rewardFadeAnims = List.generate(_dummyRewards.length, (i) {
      final start = 0.1 + (i * 0.1); 
      final end = start + 0.5;
      return CurvedAnimation(
        parent: _animController,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOut),
      );
    });

    _rewardSlideAnims = List.generate(_dummyRewards.length, (i) {
      final start = 0.1 + (i * 0.1);
      final end = start + 0.5;
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ));
    });

    // ✅ GENERATE ANIMASI HISTORY
    _historyFadeAnims = List.generate(_dummyHistory.length, (i) {
      final start = 0.1 + (i * 0.1); 
      final end = start + 0.5;
      return CurvedAnimation(
        parent: _animController,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOut),
      );
    });

    _historySlideAnims = List.generate(_dummyHistory.length, (i) {
      final start = 0.1 + (i * 0.1);
      final end = start + 0.5;
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ));
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F6FB),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Reward & Penukaran",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  // 1. Header Poin
                  _fadeSlideSingle(_buildHeaderCard(), delay: 0.0),
                  const SizedBox(height: 18),
                  
                  // 2. Tab Bar
                  _fadeSlideSingle(_buildTabBar(), delay: 0.1),
                ],
              ),
            ),
            
            // 3. Content Switcher
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isTokoSelected
                    ? _buildRewardList()
                    : _buildHistoryList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET BUILDERS =================

  // 1️⃣ Header Card
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Total Koin Kamu", style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                "$_currentPoints Koin",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Info Cara Penukaran")));
            },
            icon: const Icon(Icons.info_outline, color: Colors.white, size: 18),
            label: const Text("Info", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white24,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          )
        ],
      ),
    );
  }

  // 2️⃣ Tab Bar
  Widget _buildTabBar() {
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
            alignment: isTokoSelected ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.45 - 16,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              _tabButton("Toko Hadiah", isTokoSelected, () => setState(() => isTokoSelected = true)),
              _tabButton("Riwayat", !isTokoSelected, () => setState(() => isTokoSelected = false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // 3️⃣ List Toko (Rewards)
  Widget _buildRewardList() {
    return ListView.builder(
      key: const ValueKey('RewardList'),
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _dummyRewards.length,
      itemBuilder: (context, index) {
        final item = _dummyRewards[index];
        // Menggunakan animasi generate
        return FadeTransition(
          opacity: _rewardFadeAnims[index],
          child: SlideTransition(
            position: _rewardSlideAnims[index],
            child: RepaintBoundary(child: _rewardCard(item)),
          ),
        );
      },
    );
  }

  Widget _rewardCard(Map<String, dynamic> item) {
    final bool canExchange = item['canExchange'];
    final IconData icon = item['type'] == 'voucher' ? FontAwesomeIcons.ticket : FontAwesomeIcons.gift;
    final Color color = item['type'] == 'voucher' ? Colors.green : Colors.deepOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Icon(icon, color: color, size: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A253A)),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "${item['points']} Koin",
                  style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canExchange ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size(60, 36),
            ),
            child: const Text("Tukar", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // 4️⃣ List Riwayat
  Widget _buildHistoryList() {
    return ListView.builder(
      key: const ValueKey('HistoryList'),
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _dummyHistory.length,
      itemBuilder: (context, index) {
        final item = _dummyHistory[index];
        // Menggunakan animasi generate
        return FadeTransition(
          opacity: _historyFadeAnims[index],
          child: SlideTransition(
            position: _historySlideAnims[index],
            child: RepaintBoundary(child: _historyCard(item)),
          ),
        );
      },
    );
  }

  Widget _historyCard(Map<String, dynamic> item) {
    final bool isPending = item['isPending'];
    final Color statusColor = isPending ? Colors.orange : Colors.green;
    final IconData statusIcon = isPending ? Icons.access_time_rounded : Icons.check_circle_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A253A)),
                ),
                const SizedBox(height: 4),
                Text(
                  "Kode: ${item['code']}",
                  style: const TextStyle(color: Colors.black54, fontSize: 12, fontFamily: 'Monospace'),
                ),
                const SizedBox(height: 2),
                Text(
                  item['date'],
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item['status'],
              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}