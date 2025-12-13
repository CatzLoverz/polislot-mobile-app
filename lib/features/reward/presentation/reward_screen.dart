import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'reward_controller.dart';
import '../data/reward_model.dart';
import '../../../core/providers/connection_status_provider.dart';

class RewardScreen extends ConsumerStatefulWidget {
  const RewardScreen({super.key});

  @override
  ConsumerState<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends ConsumerState<RewardScreen> with SingleTickerProviderStateMixin {
  bool isRewardTab = true;
  
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _fadeSlide(Widget child, int index) {
    final start = (index * 0.1).clamp(0.0, 1.0);
    final end = (start + 0.5).clamp(0.0, 1.0);
    
    final slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Interval(start, end, curve: Curves.easeOut)),
    );
    final fade = CurvedAnimation(parent: _animController, curve: Interval(start, end, curve: Curves.easeIn));

    return SlideTransition(
      position: slide,
      child: FadeTransition(opacity: fade, child: RepaintBoundary(child: child)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rewardDataAsync = ref.watch(rewardControllerProvider);
    final isOffline = ref.watch(connectionStatusProvider);

    final currentPoints = rewardDataAsync.asData?.value.currentPoints ?? 0;

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
        // ✅ REVISI: RefreshIndicator membungkus SingleChildScrollView (Keseluruhan Layar)
        child: RefreshIndicator(
          onRefresh: () async {
            return ref.refresh(rewardControllerProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              children: [
                // 1. Header & Tabs (Ikut ter-scroll dan refresh)
                _buildHeaderCard(currentPoints),
                const SizedBox(height: 18),
                _buildTabBar(),
                const SizedBox(height: 18),

                // 2. Konten
                isOffline
                    ? _buildOfflinePlaceholder()
                    : rewardDataAsync.when(
                        data: (data) => isRewardTab 
                            ? _buildRewardList(data.rewards, currentPoints)
                            : _buildCoinHistoryPlaceholder(),
                        loading: () => const Padding(
                          padding: EdgeInsets.only(top: 50.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, stack) => _buildOfflinePlaceholder(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1️⃣ Header Card
  Widget _buildHeaderCard(int points) {
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
                "$points Koin",
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
            onPressed: () => _showInfoDialog(),
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
            alignment: isRewardTab ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
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
          ),
          Row(
            children: [
              _tabButton("Toko Hadiah", isRewardTab, () => setState(() => isRewardTab = true)),
              _tabButton("Riwayat Koin", !isRewardTab, () => setState(() => isRewardTab = false)),
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
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: active ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }

  // 3️⃣ List Reward (Menggunakan Column Loop agar fit di SingleChildScrollView)
  Widget _buildRewardList(List<RewardItem> rewards, int currentPoints) {
    if (rewards.isEmpty) {
      return const Center(child: Padding( 
        padding: EdgeInsets.all(20.0),
        child: Text("Belum ada hadiah tersedia.", style: TextStyle(color: Colors.grey)),
      ));
    }

    return Column(
      key: const ValueKey('RewardsList'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Daftar Reward", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 14),
        for (int i = 0; i < rewards.length; i++)
          _fadeSlide(_rewardCard(rewards[i], currentPoints), i),
      ],
    );
  }

  Widget _rewardCard(RewardItem item, int currentPoints) {
    final bool canExchange = currentPoints >= item.pointsRequired;
    final IconData icon = item.type == 'Voucher' ? FontAwesomeIcons.ticket : FontAwesomeIcons.gift;
    final Color color = item.type == 'Voucher' ? Colors.green : Colors.deepOrange;

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
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A253A)),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "${item.pointsRequired} Koin",
                  style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canExchange ? () => _showRedeemConfirmation(item) : null,
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

  // 4️⃣ Placeholder Riwayat Koin
  Widget _buildCoinHistoryPlaceholder() {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Riwayat Koin",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            "Fitur ini akan segera tersedia.",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ✅ Offline Placeholder (Sama dengan Mission Screen & Statis karena sudah di dalam ScrollView)
  Widget _buildOfflinePlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
            child: Icon(Icons.wifi_off_rounded, size: 40, color: Colors.red.shade400),
          ),
          const SizedBox(height: 16),
          Text("Anda Sedang Offline", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade800)),
          const SizedBox(height: 8),
          Text(
            "Tarik ke bawah untuk memuat ulang.\nPastikan internet Anda aktif.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // --- DIALOGS ---

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Cara Penukaran Hadiah", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1352C8))),
          content: const Text(
            "Tukar hadiah di pusat informasi kampus dengan voucher kamu.\nPenukaran bisa dilakukan pukul 08.00 - 16.00.",
            textAlign: TextAlign.justify,
            style: TextStyle(height: 1.5),
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

  void _showRedeemConfirmation(RewardItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.fullImageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.fullImageUrl,
                      height: 150,
                      width: double.maxFinite, 
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => Container(
                        height: 120,
                        width: double.maxFinite,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text("Konfirmasi Penukaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Text("Tukar ${item.pointsRequired} poin untuk ${item.name}?", textAlign: TextAlign.center),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _processRedeem(item);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1352C8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text("Ya, Tukar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processRedeem(RewardItem item) async {
    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));

    try {
      final code = await ref.read(rewardControllerProvider.notifier).redeem(item.id);
      if (mounted) {
        Navigator.pop(context); 
        _showSuccessDialog(code!, item.name);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
      }
    }
  }

  void _showSuccessDialog(String code, String rewardName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              const Text("Penukaran Berhasil!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text("Selamat! Anda mendapatkan $rewardName", textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                child: Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 8),
              const Text("Tunjukkan kode ini di pusat informasi.", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup", style: TextStyle(color: Color(0xFF1352C8))),
            ),
          ],
        );
      },
    );
  }
}