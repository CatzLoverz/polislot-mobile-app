import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'faq_controller.dart';
import '../../../core/providers/connection_status_provider.dart';

class FaqScreen extends ConsumerWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faqState = ref.watch(faqControllerProvider);
    final connectionState = ref.watch(connectionStatusProvider);
    final Color primaryColor = const Color(0xFF1565C0);

    final bool isOffline = connectionState != ConnectionStateType.online;
    final bool isServerErr = connectionState == ConnectionStateType.serverUnreachable;

    // Ambil FAQs dari controller berdasarkan status koneksi
    final faqController = ref.read(faqControllerProvider.notifier);
    final fallbackFaqs = isServerErr
        ? faqController.getServerErrorFaqs()
        : faqController.getOfflineFaqs();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        title: const Text(
          "Pusat Bantuan (FAQ)",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(connectionStatusProvider.notifier).setOnline();
          try {
            final _ = await ref.refresh(faqControllerProvider.future);
          } catch (_) {}
        },
        child: isOffline
            ? _buildOfflineFaqList(fallbackFaqs, primaryColor, connectionState)
            : faqState.when(
                loading: () => _buildLoadingPlaceholder(),
                error: (err, stack) => _buildOfflineFaqList(fallbackFaqs, primaryColor, connectionState),
                data: (faqs) {
                  if (faqs.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(child: Text("Belum ada pertanyaan saat ini.")),
                      ],
                    );
                  }
                  return _buildFaqList(faqs, primaryColor);
                },
              ),
      ),
    );
  }

  /// Daftar FAQ saat online (dari API)
  Widget _buildFaqList(List<dynamic> faqs, Color primaryColor) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: faqs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildFaqTile(
          context: context,
          question: faqs[index].question,
          answer: faqs[index].answer,
          primaryColor: primaryColor,
        );
      },
    );
  }

  /// Daftar FAQ saat offline (hardcoded, topik jaringan)
  Widget _buildOfflineFaqList(List<dynamic> faqs, Color primaryColor, ConnectionStateType connectionState) {
    final bool isError = connectionState == ConnectionStateType.online;
    final bool isServerErr = connectionState == ConnectionStateType.serverUnreachable;

    return Column(
      children: [
        // Banner offline
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: isServerErr ? Colors.orange.shade50 : Colors.red.shade50,
          child: Row(
            children: [
              Icon(
                isServerErr ? Icons.dns_rounded : (isError ? Icons.error_outline_rounded : Icons.wifi_off_rounded),
                size: 18,
                color: isServerErr ? Colors.orange.shade700 : Colors.red.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isServerErr
                      ? "Server bermasalah.\nTarik layar ke bawah untuk memuat ulang."
                      : (isError ? "Terjadi kesalahan.\nTarik layar ke bawah untuk memuat ulang." : "Anda sedang offline.\nTarik layar ke bawah untuk memuat ulang."),
                  style: TextStyle(
                    fontSize: 13,
                    color: isServerErr ? Colors.orange.shade800 : Colors.red.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: faqs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildFaqTile(
                context: context,
                question: faqs[index].question,
                answer: faqs[index].answer,
                primaryColor: primaryColor,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Tile FAQ yang dipakai bersama (online & offline)
  Widget _buildFaqTile({
    required BuildContext context,
    required String question,
    required String answer,
    required Color primaryColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: primaryColor,
          textColor: primaryColor,
          title: Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(color: Colors.grey[700], height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}