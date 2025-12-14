import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'mission_controller.dart';
import '../data/mission_model.dart';
import '../../../core/providers/connection_status_provider.dart';

class MissionScreen extends ConsumerStatefulWidget {
  final bool initialTabIsMission;

  const MissionScreen({
    super.key,
    this.initialTabIsMission = true,
  });

  @override
  ConsumerState<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends ConsumerState<MissionScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late bool isMissionTab;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    isMissionTab = widget.initialTabIsMission;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animController.forward();

    // ✅ SILENT REFRESH: Trigger fetch saat init tanpa blocking UI
    Future.microtask(() {
      ref.invalidate(missionControllerProvider);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // ✅ SILENT REFRESH: Trigger fetch saat resume tanpa blocking UI
      ref.invalidate(missionControllerProvider);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ✅ Hapus Observer
    _animController.dispose();
    super.dispose();
  }

  IconData _getMissionIcon(String metricCode) {
    switch (metricCode.toUpperCase()) {
      case 'VALIDATION_ACTION': return FontAwesomeIcons.squareCheck;
      case 'PROFILE_UPDATE': return FontAwesomeIcons.userPen;
      case 'LOGIN_ACTION': return FontAwesomeIcons.rightToBracket;
      default: return FontAwesomeIcons.star;
    }
  }

  Color _getProgressColor(double percent) {
    if (percent >= 1.0) return Colors.green;
    if (percent >= 0.5) return Colors.blue;
    return Colors.orange;
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
    final missionDataAsync = ref.watch(missionControllerProvider);
    
    final isOffline = ref.watch(connectionStatusProvider);

    final stats = missionDataAsync.asData?.value.stats ?? 
        UserStats(totalCompleted: 0, lifetimePoints: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF3F6FB),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Misi & Leaderboard",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            // ✅ LOGIKA BARU: Cek Offline & Try-Catch
            onRefresh: () async {
              ref.read(connectionStatusProvider.notifier).setOnline();

              try {
                final _ = await ref.refresh(missionControllerProvider.future);
              } catch (_) {}
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topStatsCard(stats),
                  const SizedBox(height: 20),

                  _animatedTabs(),
                  const SizedBox(height: 20),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isOffline 
                        ? _buildOfflinePlaceholder()
                        : missionDataAsync.when(
                            skipLoadingOnReload: true,
                            skipLoadingOnRefresh: true,
                            data: (data) => isMissionTab 
                                ? _buildMissionsList(data.missions)
                                : _buildLeaderboard(data.leaderboard),
                            
                            error: (err, stack) => _buildOfflinePlaceholder(),
                            
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: CircularProgressIndicator(color: Color(0xFF1352C8)),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),

          if (!isMissionTab && missionDataAsync.asData != null)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: _buildUserPositionCard(missionDataAsync.asData!.value.userRank),
            ),
        ],
      ),
    );
  }

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
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wifi_off_rounded, size: 40, color: Colors.red.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            "Anda Sedang Offline",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade800),
          ),
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

  Widget _topStatsCard(UserStats stats) {
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
          _statBox(
            icon: Icons.verified_rounded,
            color: Colors.amber,
            title: "Total Misi Selesai",
            value: stats.totalCompleted.toString(),
          ),
          Container(width: 1, height: 50, color: Colors.white24),
          _statBox(
            icon: Icons.monetization_on_rounded,
            color: Colors.greenAccent,
            title: "Lifetime Koin",
            value: stats.lifetimePoints.toString(),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
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
                boxShadow: [BoxShadow(color: const Color(0xFF1565C0).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))],
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

  Widget _buildMissionsList(List<MissionItem> missions) {
    if (missions.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("Belum ada misi aktif saat ini.", style: TextStyle(color: Colors.grey)),
      ));
    }
    return Column(
      key: const ValueKey('MissionsList'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Daftar Misi Kamu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 14),
        for (int i = 0; i < missions.length; i++)
          _fadeSlide(_missionCard(missions[i]), i),
      ],
    );
  }

  Widget _missionCard(MissionItem m) {
    final double displayPercent = m.isCompleted ? 1.0 : m.percentage;
    final Color progressColor = _getProgressColor(displayPercent);

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
                decoration: BoxDecoration(color: const Color(0xFF1352C8).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(_getMissionIcon(m.metricCode), color: const Color(0xFF1352C8), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              Text("+${m.points} koin", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(m.description, style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4)),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: displayPercent,
                    backgroundColor: const Color(0xFFE0E0E0),
                    color: progressColor,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text("${(displayPercent * 100).toInt()}%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: progressColor)),
            ],
          ),
          const SizedBox(height: 16),

          if (m.isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      SizedBox(width: 6),
                      Text("Misi Selesai", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (m.completedAt != null)
                    Text("Selesai pada: ${m.completedAt}", style: const TextStyle(color: Colors.green, fontSize: 10)),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildLeaderboard(List<LeaderboardItem> leaderboard) {
    if (leaderboard.isEmpty) { 
      return const Center(child: Padding(
        padding: EdgeInsets.all(20),
        child: Text("Belum ada data leaderboard.", style: TextStyle(color: Colors.grey)),
      ));
    }
    final top3 = leaderboard.take(3).toList();
    final rest = leaderboard.skip(3).toList();

    return Column(
      key: const ValueKey('LeaderboardList'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPodium(top3),
        const SizedBox(height: 16),
        
        if (rest.isNotEmpty) ...[
          _buildTierHeader("Peringkat Lainnya"),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
            ),
            child: Column(
              children: [
                for (int i = 0; i < rest.length; i++)
                  _leaderboardTile(rest[i]),
              ],
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildPodium(List<LeaderboardItem> top3) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (top3.length > 1) Expanded(child: _podiumItem(top3[1], 140, Colors.grey.shade400)),
          const SizedBox(width: 8),
          if (top3.isNotEmpty) Expanded(child: _podiumItem(top3[0], 180, Colors.amber)),
          const SizedBox(width: 8),
          if (top3.length > 2) Expanded(child: _podiumItem(top3[2], 110, Colors.brown.shade400)),
        ],
      ),
    );
  }

  Widget _podiumItem(LeaderboardItem user, double height, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: user.rank == 1 ? 32 : 26,
          backgroundColor: color.withValues(alpha: 0.2),
          backgroundImage: user.fullAvatarUrl.isNotEmpty 
              ? NetworkImage(user.fullAvatarUrl) 
              : null,
          child: user.fullAvatarUrl.isEmpty 
              ? Icon(Icons.person, color: color, size: user.rank == 1 ? 32 : 24)
              : null,
        ),
        const SizedBox(height: 8),
        
        SizedBox(
          height: 20,
          child: _MarqueeText(
            text: user.name, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
          ),
        ),
        
        Text("${user.points} Koin", style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity, height: height,
          decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))]),
          child: Center(child: Text("#${user.rank}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
        ),
      ],
    );
  }

  Widget _leaderboardTile(LeaderboardItem user) {
    final bgColor = user.isCurrentUser ? const Color(0xFF1352C8).withValues(alpha: 0.1) : Colors.transparent;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text("#${user.rank}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey))),
          const SizedBox(width: 10),
          
          CircleAvatar(
            radius: 18, 
            backgroundColor: Colors.grey.shade200,
            backgroundImage: user.fullAvatarUrl.isNotEmpty 
                ? NetworkImage(user.fullAvatarUrl) 
                : null,
            child: user.fullAvatarUrl.isEmpty 
                ? const Icon(Icons.person, color: Colors.black54, size: 20)
                : null,
          ),
          
          const SizedBox(width: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final textSpan = TextSpan(text: user.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14));
                final tp = TextPainter(text: textSpan, maxLines: 1, textDirection: TextDirection.ltr);
                tp.layout(maxWidth: constraints.maxWidth);
                
                if (tp.didExceedMaxLines) {
                  return SizedBox(height: 20, child: _MarqueeText(text: user.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), alignment: Alignment.centerLeft));
                }
                return Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14));
              },
            ),
          ),
          Text("${user.points} Koin", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1352C8))),
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

  Widget _buildUserPositionCard(LeaderboardItem user) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF2196F3)]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0x44000000), blurRadius: 12, offset: const Offset(0, -2))]),
      child: Row(
        children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: Center(child: Text("#${user.rank}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Posisi Kamu", style: TextStyle(color: Colors.white70, fontSize: 12)),
            SizedBox(height: 20, child: _MarqueeText(text: user.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), alignment: Alignment.centerLeft)),
            Text("${user.points} Koin", style: const TextStyle(color: Colors.white, fontSize: 14))
          ])),
        ],
      ),
    );
  }
}

class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Alignment alignment;

  const _MarqueeText({
    required this.text,
    required this.style,
    this.alignment = Alignment.center,
  });

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText> {
  final ScrollController _scrollController = ScrollController();
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_isDisposed) _startMarqueeLoop();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startMarqueeLoop() async {
    while (mounted && !_isDisposed) {
      if (!_scrollController.hasClients) {
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }

      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll <= 0) break; 

      final duration = Duration(milliseconds: (maxScroll * 25).toInt() + 1000);
      try {
        await _scrollController.animateTo(maxScroll, duration: duration, curve: Curves.linear);
      } catch (e) { break; }

      if (!mounted || _isDisposed) break;

      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted || _isDisposed) break;

      try {
        await _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 800), curve: Curves.easeOut);
      } catch (e) { break; }

      if (!mounted || _isDisposed) break;

      await Future.delayed(const Duration(milliseconds: 1500));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Text(widget.text, style: widget.style),
      ),
    );
  }
}