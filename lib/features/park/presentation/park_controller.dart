import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/park_repository.dart';
import '../data/park_model.dart';
import '../../../../core/services/mqtt_service.dart';

part 'park_controller.g.dart';

// Controller List Area
@Riverpod(keepAlive: true)
class ParkAreaListController extends _$ParkAreaListController {
  @override
  Future<List<ParkAreaItem>> build() async {
    final repo = ref.read(parkRepositoryInstanceProvider);
    return await repo.getParkAreas();
  }

  Future<void> refreshData() async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(parkRepositoryInstanceProvider);
      return await repo.getParkAreas();
    });
  }
}

// Controller Data Peta dengan MQTT Realtime
@riverpod
class ParkVisualizationController extends _$ParkVisualizationController {
  Timer? _timer;

  @override
  Future<ParkVisualData> build(String areaId) async {
    final repo = ref.read(parkRepositoryInstanceProvider);
    final data = await repo.getParkVisualization(areaId);

    // Pastikan MQTT service sudah diinisialisasi
    ref.read(mqttServiceProvider);

    // Topic yang diterbitkan server: frontend/parking_area/{parkAreaId} (integer)
    // Topic wildcard yang disubscribe: frontend/parking_area/#
    // Matching: cek apakah segmen terakhir topic == areaId
    final expectedTopic = 'frontend/parking_area/$areaId';

    // Dengarkan pesan MQTT dari service
    final subscription =
        ref.read(mqttServiceProvider.notifier).messages.listen(
      (payload) {
        final topic = payload['_topic'] as String?;
        if (topic == null) return;

        // Strict matching: topic harus persis sama dengan expected topic
        if (topic != expectedTopic) return;

        // Validasi state sebelum update
        if (!state.hasValue) return;

        final subareaIdRaw = payload['parkSubareaId'];
        final newStatus = payload['status']?.toString();

        if (subareaIdRaw == null || newStatus == null) {
          return;
        }

        final subareaId = _parseInt(subareaIdRaw, -1);
        if (subareaId == -1) return;

        final currentData = state.value!;

        final newSubareas = currentData.subareas.map((sub) {
          if (sub.id == subareaId) {
            return sub.copyWith(
              status: newStatus,
              isValidated: _parseBool(payload['isValidated'], sub.isValidated),
              hasUserReport:
                  _parseBool(payload['hasUserReport'], sub.hasUserReport),
              currentCount:
                  _parseInt(payload['currentCount'], sub.currentCount),
              maxSlots: _parseInt(payload['maxSlots'], sub.maxSlots),
              validationExpiresAt: payload['validationExpiresAt']?.toString(),
              lastValidationTime: payload['lastValidationTime']?.toString(),
              validationRemainingSeconds: _parseInt(
                payload['validationRemainingSeconds'],
                0,
              ),
              fallbackStatus:
                  payload['fallbackStatus']?.toString() ?? sub.fallbackStatus,
              fallbackStatusColor: payload['fallbackStatusColor']?.toString() ??
                  sub.fallbackStatusColor,
              commentCount: _parseInt(payload['commentCount'], sub.commentCount),
            );
          }
          return sub;
        }).toList();

        state = AsyncData(currentData.copyWith(subareas: newSubareas));

        // Sinkronkan selectedSubarea jika subarea yang diupdate sedang dipilih
        final selected = ref.read(selectedSubareaProvider);
        if (selected != null && selected.id == subareaId) {
          try {
            final updatedSelected =
                newSubareas.firstWhere((s) => s.id == subareaId);
            ref.read(selectedSubareaProvider.notifier).set(updatedSelected);
          } catch (_) {}
        }
      },
      onError: (e) {
        // Log error tapi jangan crash
      },
    );

    // Timer untuk countdown validasi (setiap 1 detik)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.hasValue) return;
      final currentData = state.value!;
      bool changed = false;

      // 1. Decrement cooldown subareas (validasi dari user lain/aktif)
      final newSubareas = currentData.subareas.map((sub) {
        if (sub.validationRemainingSeconds > 0) {
          changed = true;
          final newRemaining = sub.validationRemainingSeconds - 1;

          if (newRemaining <= 0) {
            // Validasi habis, kembalikan ke fallback status
            return sub.copyWith(
              status: sub.fallbackStatus,
              isValidated: false,
              hasUserReport: false,
              validationExpiresAt: null,
              lastValidationTime: null,
              validationRemainingSeconds: 0,
            );
          } else {
            return sub.copyWith(validationRemainingSeconds: newRemaining);
          }
        }
        return sub;
      }).toList();

      // 2. Decrement cooldown user saat ini (untuk tombol validasi)
      ValidationCooldown? updatedCooldown = currentData.cooldown;
      if (updatedCooldown != null && updatedCooldown.remainingSeconds > 0) {
        changed = true;
        final newRemaining = updatedCooldown.remainingSeconds - 1;
        if (newRemaining <= 0) {
          updatedCooldown = updatedCooldown.copyWith(
            canValidate: true,
            remainingSeconds: 0,
            waitMinutes: 0,
          );
        } else {
          updatedCooldown = updatedCooldown.copyWith(
            remainingSeconds: newRemaining,
            waitMinutes: (newRemaining / 60).ceil(),
          );
        }
      }

      if (changed) {
        state = AsyncData(currentData.copyWith(
          subareas: newSubareas,
          cooldown: updatedCooldown,
        ));

        // Sinkronkan selectedSubarea saat countdown berubah
        final selected = ref.read(selectedSubareaProvider);
        if (selected != null) {
          try {
            final updatedSelected =
                newSubareas.firstWhere((s) => s.id == selected.id);
            if (updatedSelected.validationRemainingSeconds !=
                    selected.validationRemainingSeconds ||
                updatedSelected.status != selected.status) {
              ref.read(selectedSubareaProvider.notifier).set(updatedSelected);
            }
          } catch (_) {}
        }
      }
    });

    ref.onDispose(() {
      subscription.cancel();
      _timer?.cancel();
    });

    return data;
  }

  // Helper: parse bool dari berbagai tipe data
  static bool _parseBool(dynamic val, bool def) {
    if (val == null) return def;
    if (val is bool) return val;
    if (val is num) return val == 1;
    if (val is String) return val.toLowerCase() == 'true' || val == '1';
    return def;
  }

  // Helper: parse int dari berbagai tipe data
  static int _parseInt(dynamic val, int def) {
    if (val == null) return def;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? def;
    return def;
  }
}

// Controller Aksi Validasi
@riverpod
class ValidationActionController extends _$ValidationActionController {
  @override
  FutureOr<void> build() {}

  Future<(bool, String)> submitValidation(
    int subareaId,
    String status, {
    double? lat,
    double? lng,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(parkRepositoryInstanceProvider);
      final message = await repo.sendValidation(
        subareaId,
        status,
        lat: lat,
        lng: lng,
      );
      state = const AsyncData(null);
      return (true, message);
    } catch (e, st) {
      state = AsyncError(e, st);
      String errorMsg = "Gagal mengirim validasi.";
      if (e.toString().startsWith("Exception: ")) {
        errorMsg = e.toString().substring(11);
      }
      return (false, errorMsg);
    }
  }
}

// State Provider untuk Subarea yang dipilih user di Peta
@riverpod
class SelectedSubarea extends _$SelectedSubarea {
  @override
  ParkSubareaVisual? build() {
    return null;
  }

  /// Mengubah subarea yang sedang dipilih.
  void set(ParkSubareaVisual? value) {
    state = value;
  }
}
