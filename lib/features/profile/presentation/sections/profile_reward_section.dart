import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../reward/presentation/reward_controller.dart';
import '../../../reward/data/reward_model.dart';
import '../../../../core/providers/connection_status_provider.dart';

class ProfileRewardSection extends ConsumerStatefulWidget {
  const ProfileRewardSection({super.key});

  @override
  ConsumerState<ProfileRewardSection> createState() =>
      _ProfileRewardSectionState();
}

class _ProfileRewardSectionState extends ConsumerState<ProfileRewardSection>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ SILENT REFRESH: Trigger fetch saat init tanpa blocking UI
    Future.microtask(() {
      ref.invalidate(rewardHistoryControllerProvider);
    });
  }



  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(rewardHistoryControllerProvider);
    final isOffline = ref.watch(connectionStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CustomAppBar(
        title: const Text("Riwayat Penukaran"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        // ✅ LOGIKA BARU: Cek Offline & Try-Catch
        onRefresh: () async {
          ref.read(connectionStatusProvider.notifier).setOnline();

          try {
            final _ = await ref.refresh(rewardHistoryControllerProvider.future);
          } catch (_) {}
        },
        child: isOffline != ConnectionStateType.online
            ? _buildOfflinePlaceholder(isOffline)
            : switch (historyAsync) {
                // Skip loading saat reload: jika data sudah ada, tampilkan data lama
                AsyncData(:final value) when value.isEmpty =>
                  ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                      ),
                      const Center(
                        child: Text("Belum ada riwayat penukaran."),
                      ),
                    ],
                  ),
                AsyncData(:final value) => ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(20),
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return _buildHistoryCard(value[index]);
                    },
                  ),
                AsyncError() => _buildOfflinePlaceholder(isOffline),
                _ => _buildHistoryLoading(),
              },
      ),
    );
  }

  // ✅ Widget Offline / Error (Konsisten dengan Screen Lain)
  Widget _buildOfflinePlaceholder(ConnectionStateType connectionState) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: EmptyStateWidget(
                  connectionState: connectionState,
                  layout: EmptyStateLayout.center,
                  emptyDataMessage: "Gagal memuat riwayat penukaran.\nTarik layar ke bawah untuk memuat ulang.",
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryCard(UserRewardHistoryItem item) {
    final icon = item.type == 'Voucher'
        ? FontAwesomeIcons.ticket
        : FontAwesomeIcons.gift;

    // Status Logic
    IconData statusIcon;  // Material Icons — gunakan Icon(), bukan FaIcon()
    Color statusColor;
    String statusText;
    String dateLabel = "Dibuat: ${item.createdAt}";

    if (item.status == 'accepted') {
      statusIcon = Icons.check_circle_rounded;
      statusColor = Colors.green;
      statusText = "DITERIMA";
      dateLabel = "Diterima: ${item.updatedAt}";
    } else if (item.status == 'rejected') {
      statusIcon = Icons.cancel_rounded;
      statusColor = Colors.red;
      statusText = "DITOLAK";
      dateLabel = "Ditolak: ${item.updatedAt}";
    } else {
      statusIcon = Icons.access_time_filled_rounded;
      statusColor = Colors.orange;
      statusText = "MENUNGGU";
    }

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Kode: ${item.code}",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
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
              Icon(statusIcon, color: statusColor, size: 28),
              const SizedBox(height: 4),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 9,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 4,
      itemBuilder: (context, index) {
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
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 150,
                      height: 13,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 100,
                      height: 11,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 40,
                    height: 9,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
