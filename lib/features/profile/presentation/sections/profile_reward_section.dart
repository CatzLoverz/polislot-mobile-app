import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../reward/presentation/reward_controller.dart';
import '../../../reward/data/reward_model.dart';
import '../../../../core/providers/connection_status_provider.dart';

class ProfileRewardSection extends ConsumerStatefulWidget {
  const ProfileRewardSection({super.key});

  @override
  ConsumerState<ProfileRewardSection> createState() => _ProfileRewardSectionState();
}

class _ProfileRewardSectionState extends ConsumerState<ProfileRewardSection> {
  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(rewardHistoryControllerProvider);
    final isOffline = ref.watch(connectionStatusProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text(
          "Riwayat Penukaran",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          return ref.refresh(rewardHistoryControllerProvider.future);
        },
        child: isOffline
            ? _buildOfflinePlaceholder()
            : historyAsync.when(
                data: (history) {
                  if (history.isEmpty) {
                    // Gunakan ListView agar tetap bisa di-refresh saat kosong
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        const Center(child: Text("Belum ada riwayat penukaran.")),
                      ],
                    );
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.all(20),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      return _buildHistoryCard(history[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => _buildOfflinePlaceholder(),
              ),
      ),
    );
  }

  // ✅ Widget Offline / Error (Sama dengan Reward & Mission Screen)
  Widget _buildOfflinePlaceholder() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryCard(UserRewardHistoryItem item) {
    final IconData icon = item.type == 'Voucher' ? FontAwesomeIcons.ticket : FontAwesomeIcons.gift;
    
    // Status Logic
    IconData statusIcon;
    Color statusColor;
    String dateLabel = "Dibuat: ${item.createdAt}";

    if (item.status == 'accepted') {
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
      dateLabel = "Diterima: ${item.updatedAt}";
    } else if (item.status == 'rejected') {
      statusIcon = Icons.cancel;
      statusColor = Colors.red;
      dateLabel = "Ditolak: ${item.updatedAt}";
    } else {
      statusIcon = Icons.access_time_filled;
      statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1565C0), size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  "Kode: ${item.code}",
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13),
                ),
                Text(
                  dateLabel,
                  style: const TextStyle(color: Colors.black54, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(statusIcon, color: statusColor, size: 26),
              const SizedBox(height: 4),
              Text(
                item.status.toUpperCase(),
                style: TextStyle(fontSize: 9, color: statusColor, fontWeight: FontWeight.bold),
              )
            ],
          )
        ],
      ),
    );
  }
}