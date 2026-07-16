import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/connection_status_provider.dart';
import 'custom_card.dart';

enum EmptyStateLayout { row, center }

class EmptyStateWidget extends StatelessWidget {
  final ConnectionStateType connectionState;
  final bool isApiError;
  final String? emptyDataMessage;
  final String? customTitle;
  final EmptyStateLayout layout;

  const EmptyStateWidget({
    super.key,
    this.connectionState = ConnectionStateType.online,
    this.isApiError = false,
    this.emptyDataMessage,
    this.customTitle,
    this.layout = EmptyStateLayout.row,
  });

  @override
  Widget build(BuildContext context) {
    final bool isServerErr = connectionState == ConnectionStateType.serverUnreachable;
    final bool isOfflineError = connectionState == ConnectionStateType.noInternet;
    final bool isError = isServerErr || isOfflineError || isApiError;

    // Tentukan Warna & Icon
    final Color bgColor = isServerErr
        ? Colors.orange.shade50
        : (isError ? Colors.red.shade50 : Colors.grey.shade100);
    final Color iconColor = isServerErr
        ? AppColors.warning
        : (isError ? AppColors.error : Colors.grey.shade400);
    final IconData iconData = isServerErr
        ? Icons.dns_rounded
        : (isError
            ? (isApiError ? Icons.error_outline_rounded : Icons.wifi_off_rounded)
            : (emptyDataMessage != null ? Icons.folder_open_rounded : Icons.notifications_none_rounded));

    // Tentukan Teks
    final String title = customTitle ??
        (isServerErr
            ? "Server Bermasalah"
            : (isError
                ? (isApiError ? "Terjadi Kesalahan" : "Anda Sedang Offline")
                : "Tidak Ada Data"));

    final String subtitle = isServerErr
        ? "Sistem sedang dalam perbaikan.\nTarik layar ke bawah untuk memuat ulang."
        : (isError
            ? (isApiError
                ? "Gagal memuat data.\nTarik layar ke bawah untuk memuat ulang."
                : "Pastikan internet Anda aktif.\nTarik layar ke bawah untuk memuat ulang.")
            : (emptyDataMessage ?? "Tidak ada data saat ini."));

    if (layout == EmptyStateLayout.center) {
      return CustomCard(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Icon(iconData, color: iconColor, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isServerErr
                      ? Colors.orange.shade700
                      : (isError ? Colors.red.shade700 : AppColors.textPrimary),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return CustomCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isServerErr
                        ? Colors.orange.shade700
                        : (isError ? Colors.red.shade700 : AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
